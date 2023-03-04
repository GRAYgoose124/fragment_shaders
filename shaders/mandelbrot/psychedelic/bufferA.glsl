#include "common.glsl"

precision highp float;

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

#define ITER_MAX 500
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

#define PI 3.1415926535


#define MOUSE

#define Z_SPD 0.001
#define Z_SCALE .1
#define ZOOM (cos(iTime*Z_SPD*0.5)*sin(iTime*Z_SPD))*Z_SCALE
#define MZOOM (ZOOM*10.)
void mainImage(out vec4 fragColor, in vec2 fragCoord){
    // scale math space -1.41855
    vec2 z = vec2(-1.711425+ZOOM, 0.) + scale(fragCoord.xy, iResolution.xy, mat2(-2., 0.47, -1.12, 1.12)*ZOOM); 
    #ifdef MOUSE
    if (iMouse.z > 0.0) {
        vec2 m = scale(iMouse.xy, iResolution.xy, mat2(-2., 0.47, -1.12, 1.12)*MZOOM);
        z -= m;
    }
    #endif
    
    // mandelbrot 
    float x0 = z.x, y0 = z.y;
    float x = 0., y = 0.;

    float iter = 0.;
    vec2 zn = vec2(0., 0.);
    while(x*x + y*y < 4. && int(iter) < ITER_MAX){    
        float xtemp = x*x - y*y + x0;
        y = 2.*x*y + y0;
        x = xtemp;

        zn = vec2(x, y);
        iter++;
    }

    // stop for points that don't escape
    if (int(iter) == ITER_MAX) {
        fragColor = vec4(0., 0., 0., 1.);
        return;
    } 
    
    if (int(iter) < ITER_MAX) {
        float logzn = log(zn.x*zn.x + zn.y*zn.y) * 0.5;
        float iter_part = log(logzn / log(2.)) / log(2.);
        iter += 1. - iter_part;
    }

    // color
    vec3 col1 = hash_color(int(iter));
    vec3 col2 = hash_color(int(iter+1.));

    // interpolated color
    vec3 col = mix(col1, col2, fract(float(iter)));

    // smooth coloring
    float S = (cos(iTime*0.12));
    float N = float(ITER_MAX);
    float v = mod(pow(pow((iter/float(ITER_MAX)), S) * N, 1.75), N)/N;


    // color
    fragColor = vec4(col * v, 1.);
    //fragColor = vec4(hueShift(col, cos(iTime)), 1.);
}