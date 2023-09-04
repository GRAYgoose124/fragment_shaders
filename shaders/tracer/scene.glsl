#include "common.glsl"
#include "sdf.glsl"
#include "ballandstick.glsl"

const float phi = 1.618;
const vec3 icosahedron[12] = vec3[](
    vec3(-1.0,  phi, 0.0),
    vec3( 1.0,  phi, 0.0),
    vec3(-1.0, -phi, 0.0),
    vec3( 1.0, -phi, 0.0),
    
    vec3(0.0, -1.0,  phi),
    vec3(0.0,  1.0,  phi),
    vec3(0.0, -1.0, -phi),
    vec3(0.0,  1.0, -phi),
    
    vec3( phi, 0.0, -1.0),
    vec3( phi, 0.0,  1.0),
    vec3(-phi, 0.0, -1.0),
    vec3(-phi, 0.0,  1.0)
);

float icosahedronVertsSDF(vec3 p, float sr, float scale){
    float d = 1e10;
    for (int i = 0; i < 12; i++) {
        d = min(d, sphereSDF(p, scale*icosahedron[i], sr));
    }
    return d;
}

float icosahedronEdgesSDF(vec3 p, float sr, float scale){
    float d = 1e10;
    for (int i = 0; i < 12; i++) {
        for (int j = i+1; j < 12; j++) {
            d = min(d, cylinderSDF(p, scale*icosahedron[i], scale*icosahedron[j], sr));
        }
    }
    return d;
}

float icosahedronFacesSDF(vec3 p, float sr, float scale){
    float d = 1e10;
    for (int i = 0; i < 12; i+=2) {
        d = min(d, triangleSDF(p, scale*icosahedron[i], scale*icosahedron[i+1], scale*icosahedron[(i+2)%12]));
    }
    return d;
}

float icosahedronSDF(vec3 p, float scale){
    float d = 1e10;
    d = min(d, icosahedronVertsSDF(p, 1.0, 2.*scale));
    d = min(d, icosahedronEdgesSDF(p, 0.1, 2.*scale));
    d = min(d, icosahedronFacesSDF(p, 1.0, 2.*scale));
    return d;
}

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


