#define NORMAL_COLORS
#define CARLO_RAYMARCH
#include "march.glsl"
#iChannel0 "self"

const vec3 camOrigin = vec3(1.5, 0., -5.0);

void mainImage(out vec4 fragColor, in vec2 Q) {
    vec4 oldColor = texture(iChannel0, Q / iResolution.xy);

    vec2 uv = (Q - 0.5 * iResolution.xy) / iResolution.y;

    vec2 seed = Q / iResolution.xy + vec2(iTime);
    vec3 randomVec = vec3(
        fract(sin(dot(seed, vec2(12.9898, 78.233)))*43758.5453),
        fract(sin(dot(seed, vec2(63.7264, 12.182)))*15275.1234),
        fract(sin(dot(seed, vec2(99.132, 41.253)))*11325.1337)
    );

    vec3 rayDir = normalize(vec3(uv, 1.0) + randomVec * 0.001); 


    fragColor = vec4(mix(oldColor.xyz, traceRay(camOrigin, rayDir), 0.005), 1.0);

}