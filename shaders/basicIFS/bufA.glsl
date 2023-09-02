#include "common.glsl"
#iChannel0 "self"

#define ITS 256
#define NT 4
#define NC 5

mat2 TS[NT];
vec3 WS[NT];
vec3 CS[NC]; 

void init() {
    TS = mat2[](
        scale(0.5 + 0.5*sin(T)),   
        rotate(-2.*PI*sin(T)),                       
        swirl(sin(T)*cos(T)),                    
        translate(vec2(10.*cos(T*.5), 10.*sin(T*.5)))   
    );
    
    WS = vec3[](
        vec3(0.00, 0.05, .25),
        vec3(0.00, 0.015, .25),
        vec3(0.017, 0.023, .25),
        vec3(0.056, 0.031, .25)
    );
    
    CS = vec3[](
        vec3(0.878, 0.106, 0.141),
        vec3(0.965, 0.827, 0.176),
        vec3(0.208, 0.518, 0.894),
        vec3(0.569, 0.255, 0.675),
        vec3(0.180, 0.761, 0.494)
    );
}

#define ITERS (ITS/NT)
void mainImage(out vec4 O, in vec2 Q) {
    init();
    Q = SS(Q);    
    vec2 origin = Q, old_Q = Q;
    vec3 colorSum = vec3(0.), ow;
   
    float stepSize = 10.;
    for (int i = 0; i < ITERS; i++) {
        int sel = i % NT, idx;
        
        ow = WS[sel];
        Q = (TS[sel] * Q + ow.xy) * ow.z;

        // Compute angle of movement
        float angle = atan(Q.y - old_Q.y, Q.x - old_Q.x),
         d = length((Q - origin) * -TS[sel]) * stepSize;
        stepSize -= (float(i)/float(ITERS));
        
        // Compute Color from angle + dist
        idx = int((angle + PI) / (2.0 * PI) * float(NC));
        colorSum += CS[idx % NC] / (d + 1.0);
        
        old_Q = Q;
    }
        
    O = vec4(colorSum / float(ITERS) * 0.5, 1.0);
}
