Here is a collection of my fragment shaders and glsl library code I have written.

Orginally most of this code was written for Shadertoy.com, however many of these were ported to the VSCode Shadertoy Plugin - which is highly recommend. 
There are a lot of redundant files, as I have not unified a `common.glsl` file.

# Frag Runner 
> In Construction - only works consistently for single files. - `image.glsl`

    cd fragrunner
    poetry install

    cd ../shaders/mandelbrot/psychedelic
    fragrunner
    
![](https://raw.githubusercontent.com/GRAYgoose124/fragment_shaders/main/screenshots/mandel.png)
![](https://raw.githubusercontent.com/GRAYgoose124/fragment_shaders/main/screenshots/bulb.png)
![](https://raw.githubusercontent.com/GRAYgoose124/fragment_shaders/main/screenshots/mc.png)


# Shaders
Unless otherwise stated, most shaders should run with the VSCode Shadertoy currently.

Notes on a selection of shaders:
* mandelbrot (working)
* newton_fractal (working)
* sobel (working - no signal)
* reaction_duffions (partial)
* point_reflection and voronoi (working - very simple shaders)