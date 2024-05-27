
#include "common.glsl"
#iChannel0 "file://bufferA.glsl"


// Scene
//// Options
//#define DRAW

//#define XY_MAP
#define tS .5
#define tSplit .5

//#define COLOR_PICKER

//// Constants
#define MU 1.0
#define RHO   .99
#define DECAY 0.9999

//// Setup
#define SRC_SIZE .005
#define SOURCE(p,o,r,F)length(o-p)<r?F:vec4(0.);
void init_scene(in vec2 uv,inout vec4 F){
    F+=SOURCE(uv,vec2(.33,.33),SRC_SIZE,vec4(1.,0.,0.,0.));
    F+=SOURCE(uv,vec2(.5,.75),SRC_SIZE,vec4(0.,1.,0.,0.));
    F+=SOURCE(uv,vec2(.66,.33),SRC_SIZE,vec4(0.,0.,1.,0.));
}
#define _F texelFetch(iChannel0,ivec2(P.xy),0) 
#define LAP (laplacian(P.xy,iChannel0,R.xy)*RHO)

//// Field Parameters
#ifdef XY_MAP
#define Ts (sin(iTime*tS)*tSplit)
#define Tc (cos(iTime*tS)*(1.-tSplit))
#define S1 (vec4(Ts,Tc,P.x,0.)*PHI)
#define S2 (vec4(Ts,Tc,P.y,0.)*PHI)
#define S3 (vec4(P.x,P.y,Ts*Tc,0.)*PHI)
#else
// DEFAULT
#define S1 vec4(.44, .23, .33, 0.)
#define S2 vec4(.22, .44, .33, 0.)
#define S3 vec4(.33, .21, .44, 0.)
#endif

//// Field Definition
#define OP(a, b, c)         ((a * cos(b)) + (a * sin(c)))
#define BR OP(F.b,F.r,F.g)
#define RG OP(F.r,F.g,F.b)
#define GB OP(F.g,F.b,F.r)
#define P1                  (BR) - (RG * MU * cos(BR))
#define P2                  (RG) - (GB * MU * cos(RG))
#define P3                  (GB) - (BR * MU * cos(GB))
#define BRCHG (vec4(P3,  P1,  P2, 0.) * S1)
#define RGCHG (vec4(P1,  P2,  P3, 0.) * S2)
#define GBCHG (vec4(P2,  P3,  P1, 0.) * S3)

#define CLAMP_MIN -10.0
#define CLAMP_MAX  10.0
#define BIAS .0001

// ... (Rest of the field definition remains the same, but clamp the CHG calculation)
#define CHG clamp(BRCHG+RGCHG+GBCHG, CLAMP_MIN, CLAMP_MAX) 




void mainImage(out vec4 fragColor,in vec2 P){
    vec4 F=_F;
    

    F+=CHG+LAP+BIAS;
    
    // Init (Post F so we don't get visual noise while the mouse is held.)
    if(sign(iMouse.z)==1.||iFrame==0){
        F=vec4(0.);
        init_scene(UV, F);
    }
    
    fragColor=F*DECAY;
}