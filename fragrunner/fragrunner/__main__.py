from pathlib import Path
import arcade
import argparse
import logging
import os


logger = logging.getLogger(__name__)


class ImagePass:
    pass


class FragRunner(arcade.Window):
    def __init__(self, width, height, title):
        super().__init__(width, height, title)        
        arcade.set_background_color(arcade.color.AMAZON)

        self.quad_fs = arcade.gl.geometry.quad_2d_fs()

        self.tex = self.ctx.texture((self.width, self.height))
        self.fbo = self.ctx.framebuffer(color_attachments=[self.tex])

        self.fbo.clear(arcade.color.ALMOND)
        with self.fbo:
            arcade.draw_circle_filled(width // 2, height // 2, 100, arcade.color.AFRICAN_VIOLET)

        self._program = None
            
    def on_draw(self):
        arcade.start_render()

        with self.fbo:
            self.tex.use(0)
            self.quad_fs.render(self.program)

        self.ctx.copy_framebuffer(self.fbo, self.ctx.screen)

    @property
    def program(self):
        return self._program

    @program.setter
    def program(self, prog):
        self._program = prog
    
    def setup(self, passes):
        # Default vertex shader, just pass through the vertex data.
        vertex_shader = Path(__file__).parent / "default_vert.glsl"

        self.program = self.ctx.program(
            vertex_shader=vertex_shader.read_text(),
            fragment_shader=passes['image']['source'],
        )
        return self



def parse_image_passes(shader: Path, passes=None):
    if passes is None:
        passes = {}
    
    if shader.stem not in passes:
        passes[shader.stem] = {
            'textures': {},
            'source': None,
        }

    valid_shader = "#version 430\n"
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
        elif line.lstrip().startswith("void mainImage("):
            logger.debug(f"Found mainImage: {shader.stem} {line}")
            valid_shader += f"{line}\n"
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


    shader_root = Path(args.program_root)
    main_frag = shader_root / "image.glsl"

    passes = parse_image_passes(main_frag)

    logger.debug(f"Passes: {list(passes.keys())} {len(passes)}\n{[(k, v['textures']) for k, v in passes.items()]}")
    
    app = FragRunner(800, 600, "FragRunner")
    app.setup(passes)
    arcade.run()


if __name__ == "__main__":
    main()