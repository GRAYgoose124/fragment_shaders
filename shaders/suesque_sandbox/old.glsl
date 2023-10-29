#iChannel0 "self"
//#define DRAW
//#define MOUSE
//#define SPONTANEOUS
//#define POSTPROCESS



// Utilities
    // macros
#define RES iResolution.xy
#define P fragCoord.xy
#define UV (fragCoord.xy/iResolution.xy)

    // math
float c_sum(vec4 v) { return v.x + v.y + v.z + v.w; }
float c_magsqrd(vec2 c) { return c.x * c.x + c.y * c.y; }

    // screen
vec2 wrap(in vec2 p, vec2 res) {
    if (p.x > res.x) p.x = mod(p.x, res.x);
    else if (p.x < 0.) p.x = res.x + p.x;
    
    if (p.y > res.y) p.y = mod(p.y, res.y);
    else if (p.y < 0.) p.y = res.y + p.y;
    
    return p;
}
    // input

    // drawing
vec4 draw_point(inout vec4 col, vec2 pos, vec2 pt, float r){
    return c_magsqrd(pos - pt) < r ? vec4(1) : col;
}



// Math
#define GAUSSIAN vec3(.204, .124, .075)
#define LAPLACIAN vec3(-1., .2, 0.05)
vec4 kfilter(in vec2 pos, in sampler2D channel, in vec2 reso, in vec3 kernel) {
    vec4 sum = vec4(0.);
    
    for(int i=-1; i<=1; i++) {
        for(int j=-1; j<=1; j++) {
            float weight = (i==0 && j==0) ? kernel[0] : (abs(i-j) == 1 ? kernel[1] : kernel[2]);
            sum += weight * texelFetch(channel, ivec2(wrap(pos + vec2(i, j), reso)), 0);
        }
    }
    
    return sum;
}

// Scene
#define SRC_SIZE .005
#define SOURCE(p, o, r, col) length(o - p) < r ? col : vec4(0.);
void init_scene(in vec2 uv, inout vec4 col) {
    col += SOURCE(uv, vec2(.33, .33), SRC_SIZE, vec4(1., 0., 0., 0.));
    col += SOURCE(uv, vec2(.5, .75), SRC_SIZE,vec4(0., 1., 0., 0.));
    col += SOURCE(uv, vec2(.66, .33), SRC_SIZE, vec4(0., 0., 1., 0.));
}



    //// Field Parameters
#ifdef MOUSE
#define MU sin(iMouse.x/iResolution.x)
#define RHO cos(iMouse.y/iResolution.y)
#define DECAY .99
#define S1 vec4(cos(iMouse.x/iResolution.y), sin(iMouse.y/iResolution.y), (iMouse.x-iMouse.y)/max(iResolution.x,iResolution.y), 0.)
#define S2 vec4(iMouse.x/iResolution.y, iMouse.y/iResolution.y, (iMouse.y-iMouse.x)/max(iResolution.x,iResolution.y), 0.).yzxw
#define S3 vec4(iMouse.x/iResolution.y, iMouse.y/iResolution.y, (iMouse.y-iMouse.x)/max(iResolution.x,iResolution.y), 0.).yzxw
#else
#ifdef SPONTANEOUS
// Spontaneous used CHG+ACHG and only S1,S2
#define S1 vec4(.87)
#define S2 (vec4(1.)-S1)
#define MU 0.85
#define RHO 1.1
#define DECAY 0.9815
#else
// S1|2|3=.87|.13|.13 -> {1: MU 0.33 RHO 1.0 DECAY 0.9643, 2: MU 0.33 RHO 1.12, DECAY .9812 }
#define MU 0.33
#define RHO 1.12
#define DECAY 0.9812
#define S1 vec4(.87, .87, .87, 0.)
#define S2 vec4(.13, .13, .13, 0.)
#define S3 vec4(.13, .13, .13, 0.)
#endif
#endif



    //// Field Definition
#define OP(a, b, c)    ((a * cos(b)) + (a * sin(c)))
#define OPBAR(a, b, c) ((a * sin(b)) + (a * cos(c)))

#define BR OP(b, r, g)
#define RG OP(r, g, b)
#define GB OP(g, b, r)
#define BRbar OPBAR(r, b, g)
#define RGbar OPBAR(g, r, b)
#define GBbar OPBAR(b, g, r)

#define P1 BR - (RG * MU)
#define P2 RG - (GB * MU)
#define P3 GB - (BR * MU)
#define AP1 BRbar + (RGbar * MU)
#define AP2 RGbar + (GBbar * MU)
#define AP3 GBbar + (BRbar * MU)

#ifdef SPONTANEOUS
#define _CHG (vec4( P1,  P2,  P3, 0.).zxyw * S1)
#define ACHG (vec4(AP1, AP2, AP3, 0.).zxyw * S2)
#define CHG (_CHG + ACHG)
#else
#define PHI 1.0
#define BRCHG (vec4(P1,  P2,  P3, 0.).zxyw * S1 * PHI)
#define RGCHG (vec4(P1,  P2,  P3, 0.).xyzw * S2 * PHI)
#define GBCHG (vec4(P1,  P2,  P3, 0.).yzxw * S3 * PHI)
#define CHG (BRCHG + RGCHG + GBCHG)
#endif



void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    int cFrame;
    vec4 col = texelFetch(iChannel0, ivec2(P), 0);

    // Field Pass - Physics
    vec4 lap = kfilter(P, iChannel0, RES, LAPLACIAN);
    col += lap * RHO;
    
    float r = col.x, g = col.y, b = col.z;
    col += CHG;
    
    
    // Init (Post field so we don't get visual noise while the mouse is held.) 
    #ifdef DRAW
    if (sign(iMouse.z) == 1. ) {
        col += SOURCE(UV, iMouse.xy/iResolution.xy, 0.01, vec4(abs(cos(sin(iTime))), abs(cos(iTime)), abs(sin(iTime)), 0.));
    }
    #endif
    
    #ifndef MOUSE
    if (sign(iMouse.z) == 1.) {
        cFrame = iFrame;
        #ifndef DRAW
        col = vec4(0.);
        #endif
    } 
    #else
    if (iFrame == 0) { cFrame = iFrame; }
    #endif
    if (iFrame - cFrame < 100) init_scene(UV, col);
    
  
    fragColor = col * DECAY;
}