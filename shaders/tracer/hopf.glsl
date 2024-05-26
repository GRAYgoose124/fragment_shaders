#ifndef HOPF_H
#define HOPF_H
#define TAU 6.2831853
#define MAX_STEPS 128
#define MAX_DIST 100.0
#define EPSILON 0.0001

float sphereSDF(vec3 pos, float r) {
    
    return length(pos) - r;
}

float hopfFibrationSDF(vec3 pos, float offset) {
    float t = TAU * iTime * 0.1;
    float c = cos(t + offset);
    float s = sin(t + offset);

    float r1 = sqrt(dot(pos.xy, pos.xy) + pos.z * pos.z);
    float r2 = sqrt(dot(pos.xz, pos.xz) + pos.y * pos.y);
    float x1 = pos.x * c + pos.y * s;
    float y1 = -pos.x * s + pos.y * c;
    float z1 = pos.z;

    float a = r2 * c + r1 * s;
    float b = r2 * s - r1 * c;
    float x2 = a * cos(t) - b * sin(t);
    float y2 = b * cos(t) + a * sin(t);
    float z2 = pos.z;

    vec3 q = vec3(x2, y2, z2);
    float phi = atan(q.y, q.x);
    float theta = acos(q.z / length(q));
    float r3 = sin(2.0 * theta) * (2.0 + cos(2.0 * phi + t));
    vec3 h = vec3(
        r3 * cos(phi),
        r3 * sin(phi),
        cos(2.0 * theta) * sin(2.0 * phi + t)
    );
    float r = 0.5;
    return sphereSDF(pos - h, r);
}

// Draw the entire knot as a union of hopfFibrationSDFs
float knotSDF(vec3 pos, float offset) {
    float d = 10.0;
    float t = 0.0;
    float step = 0.01;
    for (int i = 0; i < 50; i++) {
        float dist = hopfFibrationSDF(pos, float(i) * TAU / 50.0 + offset);
        d = min(d, dist);
        t += step;
    }
    return d;
}
#endif