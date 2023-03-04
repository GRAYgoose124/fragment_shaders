#iChannel0 "file://bufferC.glsl"
#include "common.glsl"

// Gray-Scott Diffusion Reaction Config
//     Reference: http://www.karlsims.com/rd.html

#define FEED_RATE 0.0515
#define KILL_RATE 0.0635
#define DIFFUSION_RATE_A 1.
#define DIFFUSION_RATE_B .5
#define dT 1.0


vec4 laplacian(in vec2 pos){
    vec4 sum = vec4(0.);
    float weight;
    
    for(int i=-1; i<=1; i++) {
        for(int j=-1; j<=1; j++) {
            weight = (i==0 && j==0) ? -1. : (abs(i-j) == 1 ? .2 : .05);
            
            sum += weight * texelFetch(iChannel0, ivec2(wrap(pos + vec2(i, j), iResolution.xy)), 0);
        }
    }
    
    return sum;
}


vec2 diffuse_react(in vec2 pos){
    vec2 fluids = texelFetch(iChannel0, ivec2(pos), 0).xz;
    float A = fluids.x, B = fluids.y;
    
    #ifdef MOUSE
        float FR = muv.y*0.05;
        float KR = muv.x*0.05+0.025;
        float F = FR * (1. - A);
        float K = (KR + FR) * B;
    #else
        float F = FEED_RATE * (1. - A);
        float K = (KILL_RATE + FEED_RATE) * B;
    #endif

    vec4 avg = laplacian(pos);
    float DA = DIFFUSION_RATE_A * avg.x;
    float DB = DIFFUSION_RATE_B * avg.z;

    float RE = A * B * B; 
    
    return vec2(clamp(A + (DA - RE + F) * dT, 0., 1.), 
                clamp(B + (DB + RE - K) * dT, 0., 1.));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec4 col = vec4(0.);

    float nA = 0., nB = 0.;
    if (iFrame == 0) {
        nA = 1.; nB = 0.;
        if (150. < p.x && p.x < 200. && 150. < p.y && p.y < 200.) nB = 1.;
        if (350. < p.x && p.x < 400. && 200. < p.y && p.y < 250.) nB = .8;
    }

    #ifdef MOUSE
        if (AREA_CLICKED(7.)) nB += .05;
        draw_point(col, p, iMouse.xy, 1.);
    #endif
      
    col.xz += diffuse_react(p) + vec2(nA, nB);
    fragColor = col;
}