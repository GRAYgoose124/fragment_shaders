#iChannel0 "self"

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

#define PI 3.14159
#define phi 1.618
const vec3 icosahedron[12] = vec3[](
    vec3(-1.0,  phi, 0.0),
    vec3( 1.0,  phi, 0.0),
    vec3(-1.0, -phi, 0.0),
    vec3( 1.0, -phi, 0.0),
    
    vec3(0.0, -1.0,  phi),
    vec3(0.0,  1.0,  phi),
    vec3(0.0, -1.0, -phi),
    vec3(0.0,  1.0, -phi),
    
    vec3( phi, 0.0, -1.0),
    vec3( phi, 0.0,  1.0),
    vec3(-phi, 0.0, -1.0),
    vec3(-phi, 0.0,  1.0)
);

float icosahedronVertsSDF(vec3 p, float sr, float scale){
    float d = 1e10;
    for (int i = 0; i < 12; i++) {
        d = min(d, sphereSDF(p, scale*icosahedron[i], sr));
    }
    return d;
}

float icosahedronEdgesSDF(vec3 p, float sr, float scale){
    float d = 1e10;
    for (int i = 0; i < 12; i+=2) {
        for (int j = i+1; j < 12; j+=3) {
            d = min(d, cylinderSDF(p, scale*icosahedron[i], scale*icosahedron[j], sr));
        }
    }
    return d;
}

float icosahedronFacesSDF(vec3 p, float sr, float scale){
    float d = 1e10;
    for (int i = 0; i < 12; i+=2) {
        d = min(d, triangleSDF(p, scale*icosahedron[i], scale*icosahedron[i+1], scale*icosahedron[(i+2)%12]));
    }
    return d;
}

float icosahedronSDF(vec3 p, float scale){
    float d = 1e10;
    d = min(d, icosahedronVertsSDF(p, 1.0, 2.*scale));
    d = min(d, icosahedronEdgesSDF(p, 0.15, 2.*scale));
    //d = min(d, icosahedronFacesSDF(p, 1.0, 2.*scale));
    return d;
}

const vec3 DIFFUSE_COLOR = vec3(1.,1.,1.);
const vec3 SPECULAR_COLOR = vec3(1.0, 1.0, 1.0);

const vec3 lightColor = vec3(1.0, 1.0, 1.0);
const vec3 lightPos = vec3(00.0, 190.0, -50.0);
const float lightIntensity = 1.0;

//#define SCENE_ROTATE
float sceneSDF(vec3 p) {
#ifdef SCENE_ROTATE
    if (iMouse.z < 0.0) {
        p = rotateX(p, iTime*0.001);
        p = rotateY(p, iTime*0.001);
        p = rotateZ(p, iTime*0.001);
    }
    else {
        p = rotateX(p, -iMouse.y*0.01);
        p = rotateY(p, iMouse.x*0.01);
        p = rotateZ(p, -iMouse.y*0.01);
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

#define MAX_STEPS 64
#define MAX_DISTANCE 150.0
#define MAX_BOUNCES 5
#define SHADOW_DISTANCE .01
#define ATTENUATE_FACTOR .5
vec3 traceRay(vec3 ro, vec3 rd) {
    float t = 0.0;
    vec3 accumulatedColor = vec3(0.0);
    vec3 attenuation = vec3(1.0);
    
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 pos = ro + t * rd;
        float dist = sceneSDF(pos);
        
        if (dist < SURFACE_DISTANCE) {
            for (int bounces = 0; bounces < MAX_BOUNCES; bounces++) {
                vec3 normal = estimateNormal(pos, dist);
                
                float shadowFactor = 1.0;
                vec3 toLight = normalize(lightPos - pos);
                vec3 shadowRayOrigin = pos + SHADOW_DISTANCE * toLight;
                float shadowT = 0.0;
                
                for (int j = 0; j < 2; j++) {
                    vec3 shadowPos = shadowRayOrigin + shadowT * toLight;
                    float shadowDist = sceneSDF(shadowPos);
                    if (shadowDist < SHADOW_DISTANCE) {
                        shadowFactor = 0.0;
                        break;
                    }
                    shadowT += shadowDist;
                    if (shadowT > MAX_DISTANCE) break;
                }
                
                float diffuse = max(dot(-normal, toLight), 0.0);
                float specular = pow(max(dot(reflect(toLight, -normal), -rd), 0.0), 16.0);
                
                vec3 localColor = shadowFactor * vec3(diffuse * lightIntensity) * DIFFUSE_COLOR * lightColor + 
                                  shadowFactor * specular * SPECULAR_COLOR * lightColor;
                
                accumulatedColor += attenuation * localColor;
                
                ro = pos + SURFACE_DISTANCE * normal;
                rd = reflect(rd, normal);
                
                attenuation *= ATTENUATE_FACTOR;
                
                t = 0.0;
                for (int j = 0; j < 64; j++) {
                    pos = ro + t * rd;
                    dist = sceneSDF(pos);
                    if (dist < SURFACE_DISTANCE) {
                        break;
                    }
                    t += dist;
                    if (t > MAX_DISTANCE) break;
                }
            }
            return accumulatedColor;
        }
        
        t += dist;
        if (t > MAX_DISTANCE) break;
    }
    
    return accumulatedColor;
}

const vec3 camOrigin = vec3(1.5, 0., -5.0);

void mainImage(out vec4 fragColor, in vec2 Q) {
    
    vec4 oldColor = texture(iChannel0, Q / iResolution.xy);
    fragColor = oldColor;
    
    if (iTime < 180. || iMouse.z > 0.){
        vec2 uv = (Q - 0.5 * iResolution.xy) / iResolution.y;

        vec2 seed = Q / iResolution.xy + vec2(iTime);
        vec3 randomVec = vec3(
            fract(sin(dot(seed, vec2(12.9898, 78.233)))*43758.5453),
            fract(sin(dot(seed, vec2(63.7264, 12.182)))*15275.1234),
            fract(sin(dot(seed, vec2(99.132, 41.253)))*11325.1337)
        );

        vec3 rayDir = normalize(vec3(uv, 1.0) + randomVec * 0.001); 


        fragColor = vec4(mix(oldColor.xyz, traceRay(camOrigin, rayDir), 0.005), 1.0);
    }
}