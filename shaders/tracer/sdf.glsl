// Utils
vec3 rotateX(vec3 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return vec3(p.x, c*p.y - s*p.z, s*p.y + c*p.z);
}

vec3 rotateY(vec3 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return vec3(c*p.x - s*p.z, p.y, s*p.x + c*p.z);
}

vec3 rotateZ(vec3 p, float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return vec3(c*p.x - s*p.y, s*p.x + c*p.y, p.z);
}

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