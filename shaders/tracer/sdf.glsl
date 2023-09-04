#ifndef SDF_H
#define SDF_H
#include "common.glsl"
#include "sdf_utils.glsl"

// SDFs
float sphereSDF(vec3 p, vec3 center, float radius) {
    return length(p - center) - radius;
}

float capsuleSDF(vec3 p, vec3 a, vec3 b, float radius) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - radius;
}

float cylinderSDF(vec3 p, vec3 a, vec3 b, float radius) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - radius;
}

float triangleSDF(vec3 p, vec3 a, vec3 b, vec3 c) {
    vec3 ba = b - a;
    vec3 ca = c - a;
    vec3 pa = p - a;

    vec3 nor = cross(ba, ca);

    float d = abs(dot(nor, pa));
    float l = length(nor);
    float h = d / l;

    float b1 = dot(cross(pa, ca), nor) < 0.0 ? 0.0 : 1.0;
    float b2 = dot(cross(pa, ba), nor) < 0.0 ? 0.0 : 1.0;
    float b3 = 1.0 - b1 - b2;

    vec3 closest = b1 * a + b2 * b + b3 * c;

    return length(p - closest);
}

float planeSDF(vec3 p, vec3 normal, float d) {
    return dot(p, normal) + d;
}

float boxSDF(vec3 p, vec3 size) {
    vec3 d = abs(p) - size;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float boxSDF(vec3 p, vec3 center, vec3 size) {
    vec3 d = abs(p - center) - size;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float torusSDF(vec3 p, vec3 center, float r1, float r2) {
    vec2 q = vec2(length(p.xz - center.xz) - r1, p.y);
    return length(q) - r2;
}

// float bezierSDF(vec3 pos, vec3 a, vec3 b, vec3 c, vec3 d) {
//     float t = 0.0;
//     float step = 0.1;
//     float minDist = 1.0;
//     for (int i = 0; i < 100; i++) {
//         vec3 p = pow(1.0 - t, 3.0) * a + 3.0 * pow(1.0 - t, 2.0) * t * b + 3.0 * (1.0 - t) * t * t * c + t * t * t * d;
//         float dist = length(pos - p);
//         minDist = min(minDist, dist);
//         t += step;
//     }
//     return minDist;
// }


#endif