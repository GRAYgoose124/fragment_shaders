#ifndef BALL_AND_STICK_H
#define BALL_AND_STICK_H
#include "sdf.glsl"

// Ball and stick model of an aromatic ring
float AromaticRingSDF(vec3 p, float radius, int nSides) {
    float d = 1e10;
    float spacing = PI / (float(nSides) / 2.0);
    for (int i = 0; i < nSides; i++) {
        float theta = float(i) * spacing;
        vec3 sp = vec3(cos(theta), sin(theta), 0.0);
        d = min(d, sphereSDF(p, sp*radius, 0.5));
        vec3 sp2 = vec3(cos(theta + spacing), sin(theta + spacing), 0.0);
        d = min(d, capsuleSDF(p, sp*radius, sp2*radius, 0.05));
    }
    return d;
}

#define BenzeneSDF(p, radius) AromaticRingSDF(p, radius, 6)

float PyrroleSDF(vec3 p, float radius) {
    // first draw an aromatic ring
    float d = AromaticRingSDF(p, radius, 5);
    // then draw a nitrogen atom
    //d = min(d, sphereSDF(p, vec3(0.0, 0.0, 0.0), 0.6));
    return d;
}

float IndoleSDF(vec3 p, float radius) {
    // first draw Benzene
    float d = BenzeneSDF(p, radius);
    // translate the pyrrole to the right of the benzene
    vec3 p2 = p - vec3(2.0, 1.0, 0.0);
    p2 = rotateZ(p2, PI/4.0);
    d = min(d, PyrroleSDF(p2, radius));

    return d;
}


// Like ChainSDF, but with a complex molecule instead of a linear chain of spheres
float DMTMoleculeSDF(vec3 p) {
    // first draw an aromatic ring
    return 0.;
}
#endif