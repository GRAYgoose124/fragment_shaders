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


        self.textures = {}
        self.passes = {}

        self.tex = self.ctx.texture((self.width, self.height))

        self.quad_fs = arcade.gl.geometry.quad_2d_fs()
        self.fbo = self.ctx.framebuffer(color_attachments=[self.tex])

        self.fbo.clear(arcade.color.ALMOND)
        with self.fbo:
            arcade.draw_circle_filled(width // 2, height // 2, 100, arcade.color.AFRICAN_VIOLET)

        self._program = None
            
    def on_draw(self):
        arcade.start_render()

        for k, p in self.passes.items():
            # Update the uniforms
            self.__update_uniforms(p)

        with self.fbo:
            self.tex.use(0)
            self.quad_fs.render(self.passes['image'])



        self.ctx.copy_framebuffer(self.fbo, self.ctx.screen)
    
    def __update_uniforms(self, shader):
        shader['iTime'] = time.time() - self.start_time

        return shader

    def __add_default_uniforms(self, shader):
        shader['iTime'] = time.time() - self.start_time
        shader['iResolution'] = (self.width, self.height)

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

            self.textures[k] = v['textures']
            self.passes[k] = program

        print(passes['image']['source'])

        # Set the default uniforms
        for p in self.passes.values():
            self.__add_default_uniforms(p)

        print(self.passes['image'].uniforms)
        return self


def parse_image_passes(shader: Path, passes=None) -> dict:
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
    
    if shader.stem not in passes:
        passes[shader.stem] = {
            'textures': {},
            'source': None,
        }

    valid_shader = "#version 430\n\n"
    # default uniforms
    valid_shader += "uniform float iTime;\n"
    valid_shader += "uniform vec2 iResolution;\n"
    for line in shader.read_text().splitlines():
        # Parse out iChannels
        if line.lstrip().startswith("#iChannel"):
            logger.debug(f"Found iChannel in {shader.stem}: {line}")

            channel, path = line.split(" ", 1)
            path = path.strip('"')
            if path.startswith("file://"):
                if path[7:] != shader.name:
                    parse_image_passes(shader.parent / path[7:], passes)
                    passes[shader.stem]['textures'][channel] = path[7:]
                else:
                    passes[shader.stem]['textures'][channel] = path[7:]
                    # probably need to use/bind a texture around here (conceptually) still...
                    logger.debug(f"Skipping iChannel: {shader.stem} {line}")
            else:
                logger.debug(f"Incompatible iChannel pre-processor: {shader.stem} {line}")

            valid_shader += f"\nuniform sampler2D {channel[1:]};\n"
        elif line.lstrip().startswith("#include"):
            logger.debug(f"Found include: {shader.stem} {line}")
            include = shader.parent / line.split(" ", 1)[1].strip('"')
            valid_shader += include.read_text() + "\n"
        elif line.lstrip().startswith("void mainImage("):
            logger.debug(f"Found mainImage: {shader.stem} {line}")
            valid_shader += "in vec2 uv;\nout vec4 fragColor;\n"
            valid_shader += "void main()" + ("{\n" if "{" in line else "\n")
        elif "fragCoord" in line:
            valid_shader += f"{line.replace('fragCoord', 'uv')}\n"
        else:
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

    app = FragRunner(800, 600, "FragRunner")
    app.setup(shader_root)

    arcade.run()


if __name__ == "__main__":
    main()