#include "scene.glsl"

#define MAX_STEPS 32
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.001

const vec3 lightPos = vec3(5.0, 5.0, -5.0);
const vec3 camOrigin = vec3(0.0, 0.0, -10.0);
const float lightIntensity = 10.0;

vec3 estimateNormal(vec3 p) {
    float d = sceneSDF(p);
    vec3 n = vec3(
        d - sceneSDF(vec3(p.x + SURFACE_DISTANCE, p.y, p.z)),
        d - sceneSDF(vec3(p.x, p.y + SURFACE_DISTANCE, p.z)),
        d - sceneSDF(vec3(p.x, p.y, p.z + SURFACE_DISTANCE))
    );
    return normalize(n);
}

vec3 traceRay(vec3 rayOrig, vec3 rayDir, int depth) {
    float t = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 pos = rayOrig + t * rayDir;
        float dist = sceneSDF(pos);
        if (dist < SURFACE_DISTANCE) {
            vec3 normal = estimateNormal(pos);
            vec3 toLight = normalize(lightPos - pos);
            float diffuse = max(dot(normal, toLight), 0.0);
            float specular = pow(max(dot(reflect(-toLight, normal), normalize(rayOrig - pos)), 0.0), 16.0);
            float ambient = 0.1;
            return vec3(diffuse * lightIntensity + ambient) * vec3(1.0, 0.7, 0.5) + vec3(specular);
        }
        t += dist;
        if (t > MAX_DISTANCE) break;
    }
    return vec3(0.0);
}