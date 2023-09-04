#include "march.glsl"

const vec3 camOrigin = vec3(0.0, 0.0, -15.0);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec2 theta = vec2(0.);

    vec3 rayDir = normalize(vec3(uv, 1.0));
    fragColor = vec4(traceRay(camOrigin, rayDir), 1.);  // Pass the rotation matrix
}