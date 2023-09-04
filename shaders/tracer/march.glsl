#include "scene.glsl"

#define MAX_STEPS 256
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.0001

#define DIFFUSE_COLOR vec3(1.0, 0.7, 0.5)
#define SPECULAR_COLOR vec3(1.0, 1.0, 1.0)

const vec3 lightPos = vec3(50.0, 10.0, -20.0);
const float lightIntensity = .8;

vec3 estimateNormal(vec3 p, float d) {
    vec3 n = vec3(
        d - sceneSDF(vec3(p.x + SURFACE_DISTANCE, p.y, p.z)),
        d - sceneSDF(vec3(p.x, p.y + SURFACE_DISTANCE, p.z)),
        d - sceneSDF(vec3(p.x, p.y, p.z + SURFACE_DISTANCE))
    );
    return -normalize(n);
}

vec3 traceRay(vec3 ro, vec3 rd) {
    float t = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 pos = ro + t * rd;
        float dist = sceneSDF(pos);  // Rotate the sample point
        if (dist < SURFACE_DISTANCE) {
            vec3 normal = estimateNormal(pos, dist);  // Normal in rotated space
            //normal = rot * -normal;  // Rotate the normal back to original space

            vec3 toLight = normalize(lightPos - pos);  // Light direction in world space

            float diffuse = max(dot(normal, toLight), 0.0);
            float specular = pow(max(dot(reflect(toLight, normal), rd), 0.0), 16.0);  // View direction remains the same
            
            float ambient = 0.1;
            return vec3(diffuse * lightIntensity + ambient) * DIFFUSE_COLOR + specular * SPECULAR_COLOR;
        }
        t += dist;
        if (t > MAX_DISTANCE) discard;
    }
    return vec3(0.0);
}