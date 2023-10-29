//#define DRAW
#define XY_MAP
//#define COLOR_PICKER

#include "common.glsl"
#iChannel0"file://bufferA.glsl"

// Input Uniforms
#define NU 1.
#define MU .33
#define XI 1.

#define DECAY .01
#define PHI 1.
#define RHO 1.

#define tS .1
#define tSplit .5
#define Ts(sin(iTime*tS)*tSplit)
#define Tc(cos(iTime*tS)*(1.-tSplit))

#define SC1 vec3(1.,.0,.0)
#define SC2 vec3(.0,1.,.0)
#define SC3 vec3(.0,.0,1.)

// Scene
//// Setup
#define SRC_SIZE.005
#define SOURCE(p,o,r,col)length(o-p)<r?col:vec4(0.);
void init_scene(in vec2 uv,inout vec4 col){
    col+=SOURCE(uv,vec2(.33,.33),SRC_SIZE,vec4(1.,0.,0.,0.));
    col+=SOURCE(uv,vec2(.5,.75),SRC_SIZE,vec4(0.,1.,0.,0.));
    col+=SOURCE(uv,vec2(.66,.33),SRC_SIZE,vec4(0.,0.,1.,0.));
}

#define Px fragCoord.x
#define Py fragCoord.y

//// Field Parameters
#ifdef XY_MAP
#define S1(vec4(Ts,Tc,Px,0.)*PHI)
#define S2(vec4(Ts,Tc,Py,0.)*PHI)
#define S3(vec4(Px,Py,Ts*Tc,0.)*PHI)
#else
#ifdef COLOR_PICKER
#define S1 vec4(SC1*PHI,0.)
#define S2 vec4(SC2*PHI,0.)
#define S3 vec4(SC3*PHI,0.)
#else
// DEFAULT
#define S1(vec4(.33,.25,.25,0.)*PHI)
#define S2(vec4(.25,.33,.25,0.)*PHI)
#define S3(vec4(.25,.25,.33,0.)*PHI)
#endif
#endif

//// Field Definition
#define OP(a,b,c)((a*cos(b))+(a*sin(c)))
#define BR OP(b,r,g)
#define RG OP(r,g,b)
#define GB OP(g,b,r)
#define P1(BR*NU)+(cos(RG*MU)*sin(GB*XI))
#define P2(RG*NU)+(cos(GB*MU)*sin(BR*XI))
#define P3(GB*NU)+(cos(BR*MU)*sin(RG*XI))

#define BRCHG(vec4(P1,P2,P3,0.).yzxw*S1)
#define RGCHG(vec4(P1,P2,P3,0.).xyzw*S2)
#define GBCHG(vec4(P1,P2,P3,0.).zxyw*S3)
#define CHG(BRCHG+RGCHG+GBCHG)

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec4 col=texelFetch(iChannel0,ivec2(fragCoord.xy),0);iTime;
    
    vec2 UV=fragCoord.xy/iResolution.xy;
    
    // Field Pass - Physics
    vec4 lap=laplacian(fragCoord.xy,iChannel0,iResolution.xy);
    col+=lap*RHO;
    
    float r=col.x,g=col.y,b=col.z;
    col+=CHG;
    
    // Init (Post field so we don't get visual noise while the mouse is held.)
    if(sign(iMouse.z)==1.||iFrame==0){
        col=vec4(0.);
        init_scene(UV,col);
    }
    
    fragColor=col*(1.-DECAY);
}