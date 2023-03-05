#include "common.glsl"

#define N 10
#define ZOOM 1.
#define SEED 2

#define POINTS 1

vec2 get_coord(in vec2 p){
    // scale pixel to fractal coords
    p = vec2(scale(p.x, iResolution.x, -1., .25),
             scale(p.y, iResolution.y, 0., 1.));
    
    //p += roots[0]; //relative to root
    p += vec2(.75, 0.);

    return 1./ZOOM * p;
}

vec2 roots(int offset) {
    if (offset == -1) return iMouse.xy;
    
    float s = rand(offset);
    return vec2(0.5+sin(iTime)*rand(SEED*offset), 0.5+cos(iTime)*rand(SEED*offset+1));
}


int get_nearest_root(vec2 z){
    int index = 0;
    float dist = 100.;
    for(int i = 0; i < N; i++){
        float d = cms(z - roots(i));
        if(d < dist){
            dist = d;
            index = i;
        }
    }
    if (cms(z - iMouse.xy) < dist) {
        return -1;
    }
    return index;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 col = vec3(0.);
    
    #if POINTS
    for(int i=0;i<N;i++){
        col = draw_point(col, get_coord(fragCoord.xy), roots(i), 0.00001);
    }
    #endif
    
    col += vec3(roots(get_nearest_root(get_coord(fragCoord.xy))), 0.);
    
    fragColor = vec4(col,1.0);
}