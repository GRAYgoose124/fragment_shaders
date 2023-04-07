#include "march.glsl"

//#define MOUSE_ROTATE

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rayDir = normalize(vec3(uv, 1.0));

    #ifdef MOUSE_ROTATE
        vec2 mouse = iMouse.xy / iResolution.xy; 
        float theta = mouse.x * 10.0;
    #else
        float theta = iTime * 0.1;
    #endif

    mat3 rot = mat3(
        vec3(cos(theta), 0.0, sin(theta)),
        vec3(0.0, 1.0, 0.0),
        vec3(-sin(theta), 0.0, cos(theta))
    );
    rayDir = rot * rayDir;

    fragColor = vec4(traceRay(rot * camOrigin, rayDir, 0), 1.0);
}