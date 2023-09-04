#include "ballandstick.glsl"
#include "platonic.glsl"


float sceneSDF(vec3 p) {
    if (iMouse.z < 0.0) {
        p = rotateX(p, iTime*0.01);
        p = rotateY(p, iTime*0.01);
        p = rotateZ(p, iTime*0.01);
    }
    else {
        p = rotateX(p, 0.01*iMouse.y);
        p = rotateY(p, 0.01*iMouse.x);
        p = rotateZ(p, 0.01*iMouse.y);
    }

    float d = icosahedronSDF(p, 1.0);

    return d;
}


