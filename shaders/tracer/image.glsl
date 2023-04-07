
#include "march.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rayDir = normalize(vec3(uv, 1.0));
    fragColor = vec4(traceRay(camOrigin, rayDir, 0), 1.0);
}