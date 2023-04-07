#include "sdf.glsl"
#define PI 3.14159265359


float ChainSDF(vec3 p) {
    // draw a web of spheres connected by cylinders
    float d = 1e10;
    for (int i = 0; i < 10; i++) {
        vec3 sp = vec3(float(i) * 1.0, float(i) * 1.0, 0.0);
        d = min(d, sphereSDF(p, sp, 0.5));
        for (int j = 0; j < 10; j++) {
            vec3 sp2 = vec3(0.0, 0.0, float(j) * 1.0);
            d = min(d, capsuleSDF(p, sp, sp2, 0.05));
        }
    }
    return d;
}

float FullerineSDF(vec3 p) {
    // draw spheres on the vertices of a truncated icosahedron connected by cylinders
    float d = 1e10;
    float phi = (1.0 + sqrt(5.0)) / 2.0;
    float a = 1.0 / sqrt(1.0 + phi * (1.0-cos(iTime*phi)));
    float b = sin(iTime*phi) * a * phi;
    vec3 v[12];
    v[0] = vec3( a, b, 0);
    v[1] = vec3(-a, b, 0);
    v[2] = vec3( a,-b, 0);
    v[3] = vec3(-a,-b, 0);
    v[4] = vec3( 0, a, b);
    v[5] = vec3( 0,-a, b);
    v[6] = vec3( 0, a,-b);
    v[7] = vec3( 0,-a,-b);
    v[8] = vec3( b, 0, a);
    v[9] = vec3( b, 0,-a);
    v[10] = vec3(-b, 0, a);
    v[11] = vec3(-b, 0,-a);
    for (int i = 0; i < 12; i++) {
        vec3 sp = v[i] * 2.0 * sin(iTime);
        d = min(d, sphereSDF(p, sp, 0.5));
        // connect each point to 3 other points
        for (int j = 0; j < 2; j++) {
            vec3 sp2 = v[(i + j) % 12] * 2.0;
            d = min(d, capsuleSDF(p, sp, sp2, 0.05));
        }
    }
    return d;
}

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

float sceneSDF(vec3 p) {
    float d = FullerineSDF(p);
    return d;
}