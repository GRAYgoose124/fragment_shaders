#ifndef common_h
#define common_h
#include "texture.glsl"
#include "math.glsl"

// Utility macros
    // screeen
#define R iResolution.xy
#define P fragCoord.xy
#define UV (P/R)
#define X (P.x)
#define Y (P.y)
#define A (R.x/R.y)
#define S (sign(UV-.5)*2.)

    // mouse
#define M (iMouse.xy/iResolution.xy).x

    // time
#define T iTime
#define sT(x,y) sin(T*x+y)
#define cT(x,y) cos(T*x+y)
#define csT(x,y) cos(T*x+y)*sin(T*x-y)
#define scT(x,y) sin(T*x+y)*cos(T*x-y)

#endif