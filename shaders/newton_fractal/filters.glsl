#include "common.glsl"

#define GAUSSIAN vec3(.204, .124, .075)
#define LAPLACIAN vec3(-1., .2, .05)
vec4 filter3x3(in vec2 pos, in vec3 kernel, in sampler2D channel, in vec2 reso) {
    vec4 sum = vec4(0.);

    for(int i=-1; i<=1; i++) {
        for(int j=-1; j<=1; j++) {
            float weight = (i==0 && j==0) ? kernel[0] : (abs(i-j) == 1 ? kernel[1] : kernel[2]);

            sum += weight * texelFetch(channel, ivec2(wrap(pos + vec2(i, j), reso)), 0);
        }
    }

    return sum;
}


    // Sobel
#define SOBEL_EDGE_COLOR vec4(0.753,0.380,0.796,1.)
vec4 sobel(in vec2 pos, in sampler2D channel, in vec2 reso) {
    //
    mat3 SX = mat3( 1.0,  2.0,  1.0,
                    0.0,  0.0,  0.0,
                   -1.0, -2.0, -1.0);
    mat3 SY = mat3(1.0, 0.0, -1.0,
                   2.0, 0.0, -2.0,
                   1.0, 0.0, -1.0);

    vec4 T = texelFetch(channel, ivec2(pos), 0);

    mat3 M = mat3(0.);
    for(int i=0; i<3; i++) {
        for(int j=0; j<3; j++) {
            vec4 A = texelFetch(channel, ivec2(pos + vec2(i-1, j-1)), 0);
            M[i][j] = length(A);
        }
    }

    float gx = dot(SX[0], M[0]) + dot(SX[1], M[1]) + dot(SX[2], M[2]);
    float gy = dot(SY[0], M[0]) + dot(SY[1], M[1]) + dot(SY[2], M[2]);


    // TODO factor into float sobel() and move this to a buffer pass.
    float g = sqrt(gx*gx + gy*gy);
    g = smoothstep(0.15, 0.98, g);

    return mix(T, SOBEL_EDGE_COLOR, g);
}
