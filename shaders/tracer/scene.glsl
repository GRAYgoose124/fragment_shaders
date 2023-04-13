#include "common.glsl"
#include "sdf.glsl"
#include "ballandstick.glsl"

const vec3 icosahedron[12] = vec3[](
    vec3(0.000000, 0.000000, 1.175571),
    vec3(1.051462, 0.000000, 0.525731),
    vec3(0.324920, 1.000000, 0.525731),
    vec3(-0.850651, 0.618034, 0.525731),
    vec3(-0.850651, -0.618034, 0.525731),
    vec3(0.324920, -1.000000, 0.525731),
    vec3(0.850651, 0.618034, -0.525731),
    vec3(-0.324920, 1.000000, -0.525731),
    vec3(-1.051462, 0.000000, -0.525731),
    vec3(-0.324920, -1.000000, -0.525731),
    vec3(0.850651, -0.618034, -0.525731),
    vec3(0.000000, 0.000000, -1.175571)
);


float FullereneSDF(vec3 p){
    // stack benzene rings around an icosahedron
    // https://en.wikipedia.org/wiki/Fullerene
    float d = 1e20;
    for (int i = 0; i < 12; i++) {
        d = min(d, BenzeneSDF(p - icosahedron[i], 3.0));
    }
    return d;
}


float sceneSDF(vec3 p) {
    p = rotateY(p, cos(iTime*0.1)*2.0 * PI / 5.0);

    float d = FullereneSDF(p);
    return d;
}