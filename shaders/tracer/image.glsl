#include "march.glsl"


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec2 mouse = iMouse.xy / iResolution.xy; 
    vec2 theta = mouse * 6.3;

    mat3 rot = mat3(
        vec3(cos(theta.x), 0.0, sin(theta.x)),
        vec3(0.0, 1.0, 0.0),
        vec3(-sin(theta.x), 0.0, cos(theta.x))
    ) * mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, cos(theta.y), -sin(theta.y)),
        vec3(0.0, sin(theta.y), cos(theta.y))
    );

    vec3 rayDir = normalize(vec3(uv, 1.0));
    fragColor = vec4(traceRay(camOrigin, rayDir, rot), 1.0);  // Pass the rotation matrix
}