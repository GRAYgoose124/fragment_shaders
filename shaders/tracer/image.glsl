#include "march.glsl"

//#define KALEIDOSCOPE
const vec3 camOrigin = vec3(0.0, 0.0, -10.0);

void mainImage(out vec4 fragColor, in vec2 Q) {
    vec2 uv = (Q - 0.5 * iResolution.xy) / iResolution.y;

#ifdef KALEIDOSCOPE
    uv = mod(uv * uv, 1.0);
    float angle = atan(uv.y, uv.x);
    uv = vec2(cos(angle), sin(angle)) * length(uv);
#endif

    vec3 rayDir = normalize(vec3(uv, 1.0));
    fragColor = vec4(traceRay(camOrigin, rayDir), 1.);
} 