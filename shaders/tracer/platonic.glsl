#ifndef PLATONIC_H
#define PLATONIC_H
#include "sdf.glsl"

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
#endif