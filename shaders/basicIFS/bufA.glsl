#include "common.glsl"
#iChannel0 "self"

#define ITS 1024
#define NT 4
#define NC 5

mat2 TS[NT];
vec3 WS[NT];
vec3 CS[NC]; 

void init() {
    TS = mat2[](
        scale(0.5 + 0.5*sin(.13*T)),   
        rotate(-2.*PI*sin(.12*T)),                       
        squash(2.0*abs(sin(.03*T)*cos(.15*T))),                    
        auger(10.*cos(T*.05), 10.*sin(T*.15))   
    );
    
    WS = vec3[](
        vec3(0.50, 0.65, 1.25),
        vec3(0.60, 0.415, .625),
        vec3(0.117, 0.723, .325),
        vec3(0.356, 0.431, .825)
    );
    
    CS = vec3[](
        vec3(0.878, 0.106, 0.141),
        vec3(0.965, 0.827, 0.176),
        vec3(0.208, 0.518, 0.094),
        vec3(0.569, 0.255, 0.975),
        vec3(0.180, 0.761, 0.494)
    );
}

#define ITERS (ITS/NT)
void mainImage(out vec4 O, in vec2 Q) {
    init();
    Q = SS(Q);    
    vec2 origin = Q, old_Q = Q, dir = vec2(0.), momentum = vec2(0.);
    vec3 colorSum = vec3(0.), ow;
   
    float stepSize = 15., momentumFactor = .1;
    for (int i = 0; i < ITERS; i++) {
        int sel = i % NT, idx;
        
        ow = WS[sel];
        Q = (TS[sel] * Q + ow.xy) * ow.z;

        // Compute movement direction and momentum
        dir = normalize(Q - old_Q) + momentumFactor * momentum;
        momentum = dir;
        
        // Compute distance and color
        float d = length((Q - origin) * -TS[sel]) * stepSize;
        idx = int((atan(dir.y, dir.x) + PI) / (2.0 * PI) * float(NC));
        colorSum += CS[idx % NC] / (d + 1.0);
        
        old_Q = Q;
    }
        
    O = vec4(colorSum / float(ITERS) * 0.5, 1.0);
}