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
#define PyrroleSDF(p, radius) AromaticRingSDF(p, radius, 5)


float IndoleSDF(vec3 p, float radius) {
    // first draw Benzene rotated
    float d = BenzeneSDF(rotateZ(p, PI / 2.0), radius);
    // translate the pyrrole to the right of the benzene
    d = min(d, PyrroleSDF(p - vec3(radius * 1.53, 0.0, 0.0), radius*.835));
    return d;
}    




// Like ChainSDF, but with a complex molecule instead of a linear chain of spheres
float DMTMoleculeSDF(vec3 p) {
    // first draw an aromatic ring
    return 0.;
}
#endif