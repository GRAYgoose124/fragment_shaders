float sphereSDF(vec3 p, vec3 center, float radius) {
    return length(p - center) - radius;
}

float capsuleSDF(vec3 p, vec3 a, vec3 b, float radius) {
    vec3 pa = p - a;
    vec3 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - radius;
}

// float bezierSDF(vec3 pos, vec3 a, vec3 b, vec3 c, vec3 d) {
//     float t = 0.0;
//     float step = 0.1;
//     float minDist = 10000.0;
//     for (int i = 0; i < 100; i++) {
//         vec3 p = pow(1.0 - t, 3.0) * a + 3.0 * pow(1.0 - t, 2.0) * t * b + 3.0 * (1.0 - t) * t * t * c + t * t * t * d;
//         float dist = length(pos - p);
//         minDist = min(minDist, dist);
//         t += step;
//     }
//     return minDist;
// }