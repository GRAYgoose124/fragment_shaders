#include "common.glsl"

#define ITER_MAX 500
#define MOUSE


#define Z_SPD 0.001
#define ZOOM sin(iTime*Z_SPD)

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



float hash(int n){ return fract(sin(float(n))*136.5453123); }

// coloring using iter as a hash into a palette function
vec3 hash_color(int i){
    float max = float(ITER_MAX);
    float r = mod(hash(i), float(ITER_MAX));
    float g = mod(hash(i+1), float(ITER_MAX));
    float b = mod(hash(i+2), float(ITER_MAX));

    return vec3(r, g, b);
}

vec3 lch2rgb(vec3 lch){
    float l = lch.x;
    float c = lch.y;
    float h = lch.z;

    float hrad = h * PI / 180.;
    float a = c * cos(hrad);
    float b = c * sin(hrad);

    float x = l + a * 0.577350269189626;
    float y = l - a * 0.288675134594813 - b * 0.5;
    float z = l - a * 0.288675134594813 + b * 0.5;

    float r = 2.2404542 * x - 1.5371385 * y - 0.4985314 * z;
    float g = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z;
    float B = 0.0556434 * x - 0.2040259 * y + 1.0572252 * z;

    return vec3(r, g, B);
}

vec3 iter2lch(float iter){
    float s = iter/float(ITER_MAX);
    float v = 1.0 - pow(cos(PI * s), 2.0);
    float x_lch = 75. - (75. * v);
    vec3 lch = vec3(x_lch, 28. + x_lch, mod(pow(360. * s, 1.5), 360.));
    return lch;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    // scale math space -1.41855
    vec2 z = scale(fragCoord.xy-iMouse.xy, iResolution.xy, mat2(-2., 0.47, -1.12, 1.12)*ZOOM); 
    z += vec2(-1.45, 0.);
    #ifdef MOUSE
    if (iMouse.z > 0.0) {
        vec2 m = scale(iMouse.xy, iResolution.xy, mat2(-2.*10., 0.47*10., -1.12*5., 1.12*5.)*ZOOM);
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

        iter++;
    }



    // stop for points that don't escape
    if (int(iter) == ITER_MAX) {
        fragColor = vec4(0., 0., 0., 1.);
        return;
    } 
    
    // subiteration
    if (int(iter) < ITER_MAX) {
        float logzn = log(x*x + y*y) * 0.5;
        float nu = log(logzn / log(2.)) / log(2.);
        iter += 1. - nu;
    }

    //smooth coloring
    vec3 lch = iter2lch(iter);
    vec3 rgb = lch2rgb(lch) * 0.00392156862745098;
    
    fragColor = vec4(rgb, 1.);
}