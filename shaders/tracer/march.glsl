#include "all.glsl"

const vec3 DIFFUSE_COLOR = vec3(.5, .3, 0.4);
const vec3 SPECULAR_COLOR = vec3(1.0, 1.0, 1.0);

const vec3 lightColor = vec3(1.0, 1.0, 1.0);
const vec3 lightPos = vec3(50.0, 10.0, -20.0);
const float lightIntensity = .8;


float sceneSDF(vec3 p) {
#ifdef SCENE_ROTATE
    if (iMouse.z < 0.0) {
        p = rotateX(p, iTime*0.01);
        p = rotateY(p, iTime*0.01);
        p = rotateZ(p, iTime*0.01);
    }
    else {
        p = rotateX(p, iMouse.x*0.01);
        p = rotateY(p, iMouse.y*0.01);
        p = rotateZ(p, iMouse.x*0.01);
    }
#endif 

    // Build scene here.
    float d = icosahedronSDF(p, 1.0);

    return d;
}

#define SURFACE_DISTANCE 0.0001
vec3 estimateNormal(vec3 p, float d) {
    vec3 n = vec3(
        d - sceneSDF(vec3(p.x + SURFACE_DISTANCE, p.y, p.z)),
        d - sceneSDF(vec3(p.x, p.y + SURFACE_DISTANCE, p.z)),
        d - sceneSDF(vec3(p.x, p.y, p.z + SURFACE_DISTANCE))
    );
    return -normalize(n);
}

#define MAX_STEPS 256
#define MAX_DISTANCE 100.0
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
            
            return vec3(diffuse * lightIntensity) * DIFFUSE_COLOR * lightColor + specular * SPECULAR_COLOR * lightColor;
            //if (final.x + final.y + final.z > 0.0) return final;
            // else discard;
        }
        t += dist;
        if (t > MAX_DISTANCE) discard;
    }
    return vec3(0.0);
}