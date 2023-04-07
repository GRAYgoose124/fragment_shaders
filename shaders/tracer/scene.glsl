#include "sdf.glsl"
#define PI 3.14159265359

float sceneSDF(vec3 p) {
   // Draw 32 spheres, and between them draw 31 capsules
    float d = 10.0;
    for (int i = 0; i < 32; i++) {
        float r = 0.5 + 0.5 * sin(float(i) * 0.1 + iTime);
        float a = float(i) * PI / 16.0 + iTime;
        vec3 center = vec3(cos(a), sin(a), 0.0) * 2.0;
        d = min(d, sphereSDF(p, center, r));
        if (i < 31) {
            float a2 = float(i + 1) * PI / 16.0 + iTime;
            vec3 center2 = vec3(cos(a2), sin(a2), 0.0) * 2.0;
            d = min(d, capsuleSDF(p, center, center2, r));
        }
    }
    return d;
}