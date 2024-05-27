#define SCENE_ROTATE
//#define KALEIDOSCOPE
#include "march.glsl"

const vec3 camOrigin=vec3(0.,0.,-8.);

void mainImage(out vec4 fragColor,in vec2 Q){
    vec2 uv=(Q-.5*iResolution.xy)/iResolution.y;
    
    #ifdef KALEIDOSCOPE
    uv=mod(uv*uv,1.);
    float angle=atan(uv.y,uv.x);
    uv=vec2(cos(angle),sin(angle))*length(uv);
    #endif

    vec2 seed = Q / iResolution.xy + vec2(iTime);
    vec3 randomVec = vec3(
        fract(sin(dot(seed, vec2(12.9898, 78.233)))*43758.5453),
        fract(sin(dot(seed, vec2(63.7264, 12.182)))*15275.1234),
        fract(sin(dot(seed, vec2(99.132, 41.253)))*11325.1337)
    );

    vec3 rayDir = normalize(vec3(uv, 1.0) + randomVec * 0.001); 
    fragColor=vec4(traceRay(camOrigin,rayDir),1.);
}   

