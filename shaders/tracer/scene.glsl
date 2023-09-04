#include "common.glsl"
#include "sdf.glsl"
#include "ballandstick.glsl"

const vec3 icosahedron[12] = vec3[](
    vec3(0.000000, 0.000000, 1.175571),
    vec3(1.051462, 0.000000, 2.525731),
    vec3(0.324920, 1.000000, 3.525731),
    vec3(-0.850651, 0.618034, 4.525731),
    vec3(-0.850651, -0.618034, 5.525731),
    vec3(0.324920, -1.000000, 6.525731),
    vec3(0.850651, 0.618034, -1.525731),
    vec3(-0.324920, 1.000000, -2.525731),
    vec3(-1.051462, 0.000000, -3.525731),
    vec3(-0.324920, -1.000000, -4.525731),
    vec3(0.850651, -0.618034, -5.525731),
    vec3(0.000000, 0.000000, -6.175571)
);


float FullereneSDF(vec3 p){
    // stack benzene rings around an icosahedron
    // https://en.wikipedia.org/wiki/Fullerene
    float d = 1e20;

   // rotate p with time and cos

    for (int i = 0; i < 100; i++) {
        if (i % 2 == 0)     
            p = -rotateZ(p, cos(iTime*0.001)*2.0 * PI / 5.0);

        d = min(d, BenzeneSDF(p + sin(iTime+float(i))*icosahedron[i % 12], 3.0));
    }
    return d;
}


float sceneSDF(vec3 p) {
    // if not mouse
    if (iMouse.z < 0.0) {
        p = rotateX(p, iTime);
        p = rotateY(p, iTime);
    }
    else {
        p = rotateX(p, iMouse.y);
        p = rotateY(p, iMouse.x);
    }

    float d = IndoleSDF(p, 2.0);
    return d;
}


