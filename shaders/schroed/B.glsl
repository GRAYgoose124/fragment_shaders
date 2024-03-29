#include "common.glsl"
#iChannel0 "self"
#iChannel1 "A.glsl"

#define K .01
void mainImage(out vec4 Q, in vec2 U) {
    vec4 wave = A, obstacle;

    if (iFrame < 1 || iMouse.z > 0.) {
        wave = vec4(0.);
        wave.zw = vec2(1.0);
        wave.xy = vec2(0.25 * sin(0.1 * length(U - 0.5 * R.xy)), 
                       0.25 * cos(0.1 * length(U - 0.5 * R.xy)));
    }
    
    vec4 L = (lap(iChannel1, UV, R.xy) + lap(iChannel0, UV, R.xy)) / (1.+wave);
    wave += K * vec4((wave.z + L.z),
                     (wave.x + L.x),
                     (wave.y + L.y),
                     (wave.w + L.w));

    
    Q = wave / length(wave);
}
