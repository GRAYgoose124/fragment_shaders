#define DRAW
#include "common.glsl"
#iChannel0 "self"

// Input Uniforms
#iUniform float NU = 1.00 in { 0.0, 1.0 } // This will expose a slider to edit the value
#iUniform float MU = 0.33 in { 0.0, 1.0 } // This will expose a slider to edit the value
#iUniform float DECAY = 0.99 in { 0.0, 1.0 } // This will expose a slider to edit the value

#iUniform float PHI = 1.0 in { 0.0, 1.0 } // This will expose a slider to edit the value
#iUniform float RHO = 1.0 in { 0.0, 1.0 } // This will expose a slider to edit the value

#iUniform float tS = 0.1 in { 0.1, 1.0 } // This will expose a slider to edit the value
#iUniform float tSplit = 0.39 in { 0.1, 1.0 } // This will expose a slider to edit the value
#define Ts sin(iTime*tSplit*tS)
#define Tc cos(iTime*(1.0-tSplit)*tS)

// Scene
    //// Setup
#define SRC_SIZE .005
#define SOURCE(p, o, r, col) length(o - p) < r ? col : vec4(0.);
void init_scene(in vec2 uv, inout vec4 col) {
    col += SOURCE(uv, vec2(.33, .33), SRC_SIZE, vec4(1., 0., 0., 0.));
    col += SOURCE(uv, vec2(.5, .75), SRC_SIZE,vec4(0., 1., 0., 0.));
    col += SOURCE(uv, vec2(.66, .33), SRC_SIZE, vec4(0., 0., 1., 0.));
}

    //// Field Parameters
// S1|2|3=.87|.13|.13 -> {1: NU 1.0 MU 0.33 RHO 1.0 DECAY 0.9643, 2: NU 1.0 MU 0.33 RHO 1.12, DECAY .98125 }
#define S1 (vec4(Ts, Tc, Px, 0.) * PHI)
#define S2 (vec4(Ts, Tc, Py, 0.) * PHI)
#define S3 (vec4(Px, Py, Ts*Tc, 0.) * PHI)

    //// Field Definition
#define OP(a, b, c) ((a * cos(b)) + (a * sin(c)))
#define BR OP(b, r, g)
#define RG OP(r, g, b)
#define GB OP(g, b, r)
#define P1 (BR * NU) + (cos(RG * MU) * sin(GB * PHI))
#define P2 (RG * NU) + (cos(GB * MU) * sin(BR * PHI))
#define P3 (GB * NU) + (cos(BR * MU) * sin(RG * PHI))

#define BRCHG (vec4(P1,  P2,  P3, 0.).zxyw * S1)
#define RGCHG (vec4(P1,  P2,  P3, 0.).xyzw * S2)
#define GBCHG (vec4(P1,  P2,  P3, 0.).yzxw * S3)
#define CHG (BRCHG + RGCHG + GBCHG)


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec4 col = texelFetch(iChannel0, ivec2(P), 0);

    // Field Pass - Physics
    vec4 lap = laplacian(P, iChannel0, RES);
    col += lap * RHO;
    
    float r = col.x, g = col.y, b = col.z;
    col += CHG;
    
    // Init (Post field so we don't get visual noise while the mouse is held.) 
    if (sign(iMouse.z) == 1. || iFrame == 0) {
        #ifndef DRAW
        col = vec4(0.);
        #else 
        col += SOURCE(UV, Mxy, 0.005, vec4(1., abs(Tc), abs(Ts), 0.));
        #endif
        
        init_scene(UV, col);
    } 
  
    fragColor = col * DECAY;
}