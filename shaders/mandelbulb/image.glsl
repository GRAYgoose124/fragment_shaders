//#define MOUSE_ROTATE

#define MAX_ITERATIONS 128
#define BAILOUT 64.0
#define POWER 8.0
#define MINIMUM_RADIUS 0.1
#define ITERATIONS_BEFORE_ESCAPE 256.0

#define MAX_RAY_STEPS 128
#define MAX_RAY_DIST 10.0
#define MIN_RAY_DIST 0.001

#define NORMAL_EPS 0.00001

vec4 fractal(vec3 z) {
    vec3 c = z;
    float r = 0.0;
    float dr = 1.0;
    float trap = 0.0;
    
    for (int i = 0; i < MAX_ITERATIONS; i++) {
        r = length(c);
        if (r > BAILOUT) break;
        
        float theta = acos(c.z / r);
        float phi = atan(c.y, c.x);
        float p = POWER * theta;
        float cp = cos(p);
        float sp = sin(p);
        float cp2 = cos(POWER * phi);
        float sp2 = sin(POWER * phi);
        
        vec3 dz = vec3(
            sp * cp2,
            sp * sp2,
            cp);
        c = pow(r, POWER) * dz + z;
        dr = POWER * pow(r, POWER - 1.0) * dr + 1.0;
        
        if (float(i) > ITERATIONS_BEFORE_ESCAPE) {
            trap += log(r);
        }
    }
    
    float dist = 0.5 * log(r) * r / dr;
    return vec4(c, dist);
}

vec3 estimateNormal(vec3 p) {
    const vec3 dx = vec3(NORMAL_EPS, 0.0, 0.0);
    const vec3 dy = vec3(0.0, NORMAL_EPS, 0.0);
    const vec3 dz = vec3(0.0, 0.0, NORMAL_EPS);
    
    return normalize(vec3(
        fractal(p + dx).w - fractal(p - dx).w,
        fractal(p + dy).w - fractal(p - dy).w,
        fractal(p + dz).w - fractal(p - dz).w)
    );
}


float traceRay(vec3 ro, vec3 rd, out vec3 hit, out vec3 normal) {
    float t = 0.0;
    float d = 0.0;
    for (int i = 0; i < MAX_RAY_STEPS; i++) {
        hit = ro + rd * t;
        d = (fractal(hit)).w;
        if (d < MIN_RAY_DIST) {
            normal = estimateNormal(hit);
            return t;
        }
        t += d;
        if (t > MAX_RAY_DIST) break;
    }
    return -1.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;    
    vec3 ro = vec3(0.0, 0.0, 1.6);
    vec3 rd = normalize(vec3(uv, -1.0));


#ifdef MOUSE_ROTATE
    vec2 mouse = iMouse.xy / iResolution.xy; 
    float theta = mouse.x * 10.0;
#else
    float theta = iTime * 0.1;
#endif

    mat3 rot = mat3(
        vec3(cos(theta), 0.0, sin(theta)),
        vec3(0.0, 1.0, 0.0),
        vec3(-sin(theta), 0.0, cos(theta)));
    rd = rot * rd;
    ro = rot * ro;

    vec3 hit, normal;
    float t = traceRay(ro, rd, hit, normal);

    if (t > 0.0) {
        vec3 color = vec3(0.0);
        vec3 lightDir = normalize(vec3(-1.0, 1.0, -1.0));
        vec3 viewDir = normalize(-hit);
        vec3 reflectDir = reflect(-lightDir, normal);
        float diffuse = max(dot(normal, lightDir), 0.0);
        float specular = pow(max(dot(reflectDir, viewDir), 0.0), 32.0);
        color += vec3(1.0, 0.5, 0.42) * diffuse;
        color += vec3(1.0) * specular;
        fragColor = vec4(color, 1.0);
    } else {
        fragColor = vec4(0.0);
    }
}
