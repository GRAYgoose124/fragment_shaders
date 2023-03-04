#ifndef math_h
#define math_h
#include "texture.glsl"

vec4 laplacian(in vec2 pos, in sampler2D channel, in vec2 reso){
    vec4 sum = vec4(0.);
    
    for(int i=-1; i<=1; i++) {
        for(int j=-1; j<=1; j++) {
            float weight = (i==0 && j==0) ? -1. : (abs(i-j) == 1 ? .2 : .05);
            sum += weight * texelFetch(channel, ivec2(wrap(pos + vec2(i, j), reso)), 0);
        }
    }
    
    return sum;
}

#endif