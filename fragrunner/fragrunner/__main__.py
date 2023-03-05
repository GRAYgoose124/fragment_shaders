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
        arcade.set_background_color(arcade.color.AMAZON)

        self.start_time = time.time()
        self.iMouse = [0, 0, 0, 0]

        self.quad_fs = arcade.gl.geometry.quad_2d_fs()
        self.passes = {}
            
    def on_draw(self):
        arcade.start_render()

        # Run the shader passes
        for k, pss in sorted(self.passes.items()):
            prog = pss['prog']

            # Update the uniforms
            self.__update_uniforms(prog)
       
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
        self.iMouse = [x, y, dx, dy]

    def __update_uniforms(self, shader):
        try:
            shader['iTime'] = (time.time() - self.start_time)
            shader['iFrame'] += 1
            shader['iMouse'] = self.iMouse
        except:
            pass

        return shader

    def __add_default_uniforms(self, shader):
        try:
            shader['iTime'] = - self.start_time
            shader['iResolution'] = (self.width, self.height)
            shader['iFrame'] = 0
            shader['iMouse'] = [0, 0, 0, 0]
        except KeyError:
            logger.debug(f"Pass {shader} has no iTime or iResolution uniforms")

        return shader
    
    def setup(self, shader_root: Path):
        # Default vertex shader, just pass through the vertex data.
        vertex_shader = Path(__file__).parent / "default_vert.glsl"

        # the main image pass is always named "image", it's technically a frag pass.
        image_shader = shader_root / "image.glsl"
        passes = parse_image_passes(image_shader)
        logger.debug(f"Passes: {list(passes.keys())} {len(passes)}\n{[(k, v['textures']) for k, v in passes.items()]}")

        # Create the main program - each pass should be a new program with textures bound appropriately on draw.
        for k, v in passes.items():
            program = self.ctx.program(
                vertex_shader=vertex_shader.read_text(),
                fragment_shader=v['source'],
            )

            # self.channels is a list of the names of texture uniforms the pass uses.
            # These texture uniforms are the render targets of the previous pass by the same name.

            # self.passes is a list of real shader `Program`s for each pass. We prob need to create a texture object for each.
            self.passes[k] = {'prog': program,
                              'fbo': self.ctx.framebuffer(color_attachments=[self.ctx.texture((self.width, self.height))]),
                              'channels': list(v['textures'].values())}

            logger.debug(f"Created pass {k} with channels {self.passes[k]}")

        # Set the default uniforms
        for p in self.passes.values():
            self.__add_default_uniforms(p['prog'])

        # init framebuffer

        return self


def parse_image_passes(shader: Path, passes=None, visited=None) -> dict:
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
            'source': None,
        }

    valid_shader = "#version 430\n\n"
    # default uniforms
    valid_shader += "uniform float iTime;\n"
    valid_shader += "uniform vec2 iResolution;\n"
    valid_shader += "uniform int iFrame;\n"
    valid_shader += "uniform vec4 iMouse;\n\n"

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
                    parse_image_passes(shader.parent / path[7:], passes, visited)
          
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
            guard_str = lambda body: f"#ifndef {include.stem.upper()}_H\n#define {include.stem.upper()}_H\n{body}\n\n#endif\n"
            valid_shader += guard_str(include.read_text())

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