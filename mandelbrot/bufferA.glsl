#include "common.glsl"

int get_nearest_root(vec2 z){
    int index = 0; float dist = 1000.;
    
    for(int i = 0; i < NROOTS; i++){
        float d = length(z - roots[i]);
        if(d < dist){
            index = i; dist = d;
        }
    }
    
    return index;
}

#define ITER_MAX 1000
int mandelbrot(vec2 p){
    float x0 = p.x, y0 = p.y;
    float x = 0., y = 0.;

    int iter = 0;
    while(x*x + y*y < 4. && iter < ITER_MAX){    
        float xtemp = x*x - y*y + x0;
        y = 2.*x*y + y0;
        x = xtemp;

        iter++;
    }

    return iter;
}

float hash(int n){ return fract(sin(float(n))*136.5453123); }

// coloring using iter as a hash into a palette function
vec3 hash_color(int i){
    float max = float(ITER_MAX);
    float r = mod(hash(i), float(ITER_MAX));
    float g = mod(hash(i+1), float(ITER_MAX));
    float b = mod(hash(i+2), float(ITER_MAX));

    return vec3(r, g, b);
}

#define Z_SPD 0.1
#define ZOOM sin(iTime*Z_SPD)
void mainImage(out vec4 fragColor, in vec2 fragCoord){
    // scale math space
    vec2 z = vec2(-2.5+ZOOM/sin(iTime*Z_SPD), 0.) + scale(fragCoord.xy, iResolution.xy, mat2(-2., 0.47, -1.12, 1.12)*(.1/ZOOM)); 
    
    // mandelbrot 
    int iter = mandelbrot(z);

    // color
    vec3 col = hash_color(iter);
    fragColor = vec4(col, 1.);
    //fragColor = vec4(hueShift(col, cos(iTime)), 1.);
}