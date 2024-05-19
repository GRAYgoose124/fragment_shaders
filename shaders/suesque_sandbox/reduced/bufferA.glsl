//#define DRAW
//#define XY_MAP
//#define COLOR_PICKER

#include "common.glsl"
#iChannel0 "self"

// Input Uniforms
//#iUniform float NU = 1.00 in { -1.0, 1.0 } 
#iUniform float MU = 0.33 in {-1.0, 1.0 } 
//#iUniform float XI = 1.0 in { -1.0, 1.0 }

#iUniform float DECAY = 0.98125 in { 0.00, 1.00 } 
//#iUniform float PHI = 1.0 in { -1.0, 1.0 } 
#iUniform float RHO = 1.12 in { 0.0, 2.0 } 

//#iUniform float tS = 0.1 in { 0.1, 1.0 } 
//#iUniform float tSplit = 0.5 in { 0.1, 1.0 } 
//#define Ts (sin(iTime*tS)*tSplit)
//#define Tc (cos(iTime*tS)*(1.0-tSplit))

// #iUniform color3 S1 = color3(.87, .0, .0)
// #iUniform color3 S2 = color3(.0, .98, .0)
// #iUniform color3 S3 = color3(.0, .0, .87)

/// Scene
    //// Setup
#define SRC_SIZE .015
#define SOURCE(p, o, r, col) length(o - p) < r ? col : vec4(0.);
// void init_scene(in vec2 uv, inout vec4 col) {
//     col += SOURCE(uv, vec2(.25, .25), SRC_SIZE, vec4(1., 0., 0., 0.));
//     col += SOURCE(uv, vec2(.25, .50), SRC_SIZE,vec4(0., 1., 0., 0.));
//     col += SOURCE(uv, vec2(.50, .25), SRC_SIZE, vec4(0., 0., 1., 0.));
// }

void init_scene(in vec2 uv, inout vec4 col) {
    // grid of sources
    for (float x = 0.; x <= 1.; x += 0.1) {
        for (float y = 0.; y <= 1.; y += 0.1) {
            col += SOURCE(uv, vec2(x, y), SRC_SIZE, vec4(mod(x, 1.), mod(y, 1.), mod(x+y, 2.), 0.));
        }   
    }
}

    //// Field Parameters
// S1|2|3=.87|.13|.13 -> {1: NU 1.0 MU 0.33 RHO 1.0 DECAY 0.9643, 2: NU 1.0 MU 0.33 RHO 1.12, DECAY .98125 }
//#define NU 1.0
//#define MU 0.33
//#define RHO 1.12
//#define DECAY 0.98125
//#define PHI 1.0
#define S1 vec3(.87, .87, .87)
#define S2 vec3(.13, .13, .13)
#define S3 vec3(.13, .13, .13)

    //// Field Definition
#define OP(a, b, c) ((a * cos(b)) + (a * sin(c)))
#define BR OP(b, r, g)
#define RG OP(r, g, b)
#define GB OP(g, b, r)
#define P1 (BR - RG * MU)
#define P2 (RG - GB * MU)
#define P3 (GB - BR * MU)

#define BRCHG (vec3(P1,  P2,  P3).zxy * S1)
#define RGCHG (vec3(P1,  P2,  P3).xyz * S2)
#define GBCHG (vec3(P1,  P2,  P3).yzx * S3)
#define CHG (BRCHG + RGCHG + GBCHG)


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec4 col = texelFetch(iChannel0, ivec2(P), 0);

    // Field Pass - Physics
    vec4 lap = laplacian(P, iChannel0, RES);
    col += lap * RHO;
    
    float r = col.x, g = col.y, b = col.z;
    col += vec4(CHG,0.);
    
    
    // Init (Post field so we don't get visual noise while the mouse is held.) 
    if (sign(iMouse.z) == 1. || iFrame == 0) {
        #ifndef DRAW
        col = vec4(0.);
        #else 
        col += SOURCE(UV, iMouse.xy/iResolution.xy, 0.005, vec4(1., abs(cos(iTime)), abs(sin(iTime)), 0.));
        #endif
        
        init_scene(UV, col);
    } 
  
    
  
    fragColor = col * DECAY;
}