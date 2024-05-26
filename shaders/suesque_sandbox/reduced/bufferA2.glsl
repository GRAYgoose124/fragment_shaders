//#define DRAW
//#define XY_MAP
//#define COLOR_PICKER

#include "common.glsl"
#iChannel0 "self"

#define MU .7
#define RHO 1.03
#define DECAY 0.998
#define S1 vec4(0.87, 0.03, 0.03, 0.05)
#define S2 vec4(0.05, 0.87, 0.03, 0.03)
#define S3 vec4(0.03, 0.05, 0.87, 0.03)
#define S4 vec4(0.23, 0.33, 0.3, 0.15)

/// Scene
    //// Setup
#define SRC_SIZE .015
#define SOURCE(p, o, r, col) length(o - p) < r ? col : vec4(0.);

void init_scene(in vec2 uv, inout vec4 col) {
    // grid of sources
    for (float x = 0.; x <= 1.; x += 0.1) {
        for (float y = 0.; y <= 1.; y += 0.1) {
            col += SOURCE(uv, vec2(x, y), SRC_SIZE, vec4(mod(x, 1.), mod(y, 1.), mod(x*y, 2.), mod(x+y, 1.)));
        }   
    }
}

    //// Field Parameters
// S1|2|3|4=.87|.13|.13|.5 -> {1: NU 1.0 MU 0.33 RHO 1.0 DECAY 0.9643, 2: NU 1.0 MU 0.33 RHO 1.12, DECAY .98125 }


    //// Field Definition
#define OP(a, b, c) ((a * cos(b)) + (a * sin(c)))
#define BR OP(b, r, g)
#define RG OP(r, g, b)
#define GB OP(g, b, r)
#define P1 (BR - RG * MU)
#define P2 (RG - GB * MU)
#define P3 (GB - BR * MU)
#define P4 (BR + RG * MU - GB * MU)

#define RGCHG (vec4(P1,  P2,  P3, P4).xyzw * S1)
#define GBCHG (vec4(P1,  P2,  P3, P4).yzxw * S2)
#define BRCHG (vec4(P1,  P2,  P3, P4).zxyw * S3)
#define WCHG  (vec4(P1,  P2,  P3, P4).wzyx * S4)
#define CHG (BRCHG + RGCHG + GBCHG + WCHG)


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec4 col = texelFetch(iChannel0, ivec2(fragCoord), 0);

    // Field Pass - Physics
    vec4 lap = laplacian(fragCoord, iChannel0, iResolution.xy);
    col += lap * RHO;
    
    float r = col.x, g = col.y, b = col.z, w = col.w;
    col += CHG;
    
    // Init (Post field so we don't get visual noise while the mouse is held.) 
    if (sign(iMouse.z) == 1. || iFrame == 0) {
        #ifndef DRAW
        col = vec4(0.);
        #else 
        col += SOURCE(fragCoord / iResolution.xy, iMouse.xy / iResolution.xy, 0.005, vec4(1., abs(cos(iTime)), abs(sin(iTime)), abs(tan(iTime))));
        #endif
        
        init_scene(fragCoord / iResolution.xy, col);
    } 

    fragColor = col * DECAY;
}
