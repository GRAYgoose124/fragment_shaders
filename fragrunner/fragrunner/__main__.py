from pathlib import Path
import arcade
import argparse
import logging
import os
import time


logger = logging.getLogger(__name__)


class FragRunner(arcade.Window):
    def __init__(self, width, height, title):
        super().__init__(width, height, title)
        arcade.set_background_color(arcade.color.BANGLADESH_GREEN)
        self.shader_root = Path(__file__).parent / "shaders"


        self.start_time = time.time()
        self.iMouse = [0, 0, 0, 0]

        self.quad_fs = arcade.gl.geometry.quad_2d_fs()
        self.passes = {}

    def setup(self, shader_root: Path):
        self.shader_root = shader_root
        
        self.__build_passes(self.shader_root)

        return self
         
    def on_draw(self):
        arcade.start_render()

        # Run the shader passes
        for k, sp in sorted(self.passes.items()):
            prog = sp['prog']

            # Update the uniforms
            self.__update_default_uniforms(sp)

       
            # bind the framebuffer for this pass
            with self.passes[k]['fbo']:
                # bind the textures channels for this pass
                for id, name in enumerate(self.passes[k]['channels']):
                    self.passes[name]['fbo'].color_attachments[0].use(id)
                    
                # render current pass to it's framebuffer
                self.quad_fs.render(prog)

        # render the final image to the screen
        self.ctx.copy_framebuffer(self.passes['image']['fbo'], self.ctx.screen)
    
    def on_mouse_motion(self, x, y, dx, dy):
        self.iMouse = [x, y, self.iMouse[2], self.iMouse[3]]
    
    def on_mouse_press(self, x, y, button, modifiers):
        self.iMouse = [x, y, button, modifiers]

    def on_resize(self, width, height):
        super().on_resize(width, height)

        self.__build_passes(self.shader_root)

    def __update_default_uniforms(self, shaderpass):
        try:
            shaderpass['prog']['iTime'] = (time.time() - self.start_time)
            shaderpass['prog']['iFrame'] += 1
            shaderpass['prog']['iMouse'] = self.iMouse
        except:
            pass

        return shaderpass

    def __add_default_uniforms(self, shaderpass):
        try:
            shaderpass['prog']['iTime'] = - self.start_time
            shaderpass['prog']['iResolution'] = (self.width, self.height)
            shaderpass['prog']['iFrame'] = 0
            shaderpass['prog']['iMouse'] = [0, 0, 0, 0]

            # TODO Need to vary these in update_uniforms
            for n, v in shaderpass['uniforms']:
                shaderpass['prog'][n] = v
        except KeyError as e:
            logger.debug(f"Pass {shaderpass} has missing uniforms: {e}")

        return shaderpass
    
    def __build_passes(self, shader_root):
        # Default vertex shader, just pass through the vertex data.
        vertex_shader = Path(__file__).parent / "default_vert.glsl"

        # the main image pass is always named "image", it's technically a frag pass.
        image_shader = shader_root / "image.glsl"
        passes = FragRunner.__parse_image_passes(image_shader)
        logger.debug(f"Passes: {list(passes.keys())} {len(passes)}\n{[(k, v['textures']) for k, v in passes.items()]}")

        # Create the main program - each pass should be a new program with textures bound appropriately on draw.
        for k, v in passes.items():
            program = self.ctx.program(
                vertex_shader=vertex_shader.read_text(),
                fragment_shader=v['source'],
            )

            self.passes[k] = {'prog': program,
                              'fbo': self.ctx.framebuffer(color_attachments=[self.ctx.texture((self.width, self.height))]),
                              'channels': list(v['textures'].values())}

            logger.debug(f"Created pass {k} with channels {self.passes[k]['channels']} and program {program}")

        # Set the default uniforms
        for p in self.passes.values():
            self.__add_default_uniforms(p)

    @staticmethod
    def __parse_image_passes(shader: Path, passes=None, visited=None) -> dict:
        """ Parse a shader file and return a dictionary of passes. 
        
        Each pass is a dictionary with the following keys:
            textures: A dictionary of iChannelN -> path
            source: The source code of the shader

        A pass is a fragment shader which uses a predefined vertex shader to render a quad.
        Each pass uses a series of iChannels to pass textures to the shader for rendering.

        The first pass is always the main image pass, and is named "image". The rest of the passes
        are generated from the iChannels in the main image pass
        """
        if passes is None:
            passes = {}
        if visited is None:
            visited = set()

        if shader.stem not in passes:
            passes[shader.stem] = {
                'textures': {},
                'uniforms': {},
                'source': None,
            }

        valid_shader = "#version 430\n\n"
        # default uniforms
        valid_shader += "uniform float iTime;\n"
        valid_shader += "uniform vec2 iResolution;\n"
        valid_shader += "uniform int iFrame;\n"
        valid_shader += "uniform vec4 iMouse;\n\n"
        # extra uniforms

        # parse source pass
        for line in shader.read_text().splitlines():
            if "fragCoord" in line:
                line = line.replace("fragCoord", "gl_FragCoord")

            if line.lstrip().startswith("#iChannel"):
                # Parse out iChannels for texture uniforms binding.
                logger.debug(f"Found iChannel in {shader.stem}: {line}")

                channel, path = line.split(" ", 1)
                path = path.strip('"')
                if path.startswith("file://"):
                    if path[7:] not in visited:
                        visited.add(path[7:])
                        FragRunner.__parse_image_passes(shader.parent / path[7:], passes, visited)
            
                    passes[shader.stem]['textures'][int(channel[-1])] = path[7:].split(".")[0]
                else:
                    logger.debug(f"Incompatible iChannel pre-processor: {shader.stem} {line}")

                valid_shader += f"\nuniform sampler2D {channel[1:]};\n"

            elif line.lstrip().startswith("#include"):
                # Include shader "headers" - GLSL has no #include directive.

                # TODO: Need to handle recursive includes - for now we're just assuming a common.glsl 
                # include and no others - like Shadertoy.
                logger.debug(f"Found include: {shader.stem} {line}")
                include = shader.parent / line.split(" ", 1)[1].strip('"')
                # TODO: Need to factor out parse_image_passes from actual shader parsing..
                guard_str = lambda body: f"\n#ifndef {include.stem.upper()}_H\n#define {include.stem.upper()}_H\n\n{body}\n\n#endif\n"
                valid_shader += guard_str(include.read_text())
            
            elif line.lstrip().startswith("#iUniform"):
                # These are directives that the VScode shadertoy extension uses to define sliders.
                # We will just define the uniforms and ignore the rest.
                logger.debug(f"Found iUniform: {shader.stem} {line}")
                #iUniform float hisT_offset = 0.50 in { 1.0, 100.0 } 
                _, ty, label_and_val = line.split(" ", 2)
                name = label_and_val.split(" ", 1)[0]
                value = label_and_val.split("=", 1)[1].split(" ", 1)[0]
                if ty == "color3":
                    ty = "vec3"
                    value = (float(v.strip(" "))for v in value.split(","))
                # add to the uniform dict for updating later
                passes[shader.stem]['uniforms'][name] = value

                valid_shader += f"uniform {ty} {name};\n"

            elif line.lstrip().startswith("void mainImage("):
                # Replace the mainImage function with the main function.
                # This helps ensures well-formed source code for each pass and conforms to ShaderToy's API.
                # TODO: Right now there is a hidden uv that can be used, but it's not obvious
                #  - most shadertoy code goes fragCoord / iRes... We're also not using the defined IO in mainImage yet.
                logger.debug(f"Found mainImage: {shader.stem} {line}")
                valid_shader += "in vec2 uv;\nout vec4 fragColor;\n"
                valid_shader += "void main()" + ("{\n" if "{" in line else "\n")
                
            else:
                # Just emit the line as-is.
                valid_shader += f"{line}\n"

        passes[shader.stem]['source'] = valid_shader

        return passes
     

def argparser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=str, help="The root directory of the program to run", default=os.getcwd(), dest="program_root")
    return parser


def main():
    args = argparser().parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.getLogger("arcade").setLevel(logging.WARNING)
    logging.getLogger("PIL").setLevel(logging.WARNING)

    shader_root = Path(args.program_root)

    app = FragRunner(1920, 1080, "FragRunner")
    app.setup(shader_root)

    arcade.run()


if __name__ == "__main__":
    main()