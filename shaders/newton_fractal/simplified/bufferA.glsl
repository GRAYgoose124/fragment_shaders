#include "common.glsl"

int get_nearest_root(vec2 z){
    int index = 0; float dist = 1000.;
    
    for(int i = 0; i < NROOTS; i++){
        float d = length(z - roots[i]);
        if(d < dist){
            index = i; dist = d;
        }
    }
    
    return index;
}

vec2 newton_iter(in vec2 z){
    vec2 sum = vec2(0.);

    for(int j = 0; j < NROOTS; j++){
        vec2 dist = z - roots[j];
        float delta = dist.x*dist.x+dist.y*dist.y;
        if (delta < 0.0001) return z;
        
        sum += vec2(dist.x, -dist.y) / delta;
    }
    
    return z - (vec2(sum.x, -sum.y) / (sum.x*sum.x+sum.y*sum.y));
}


#define ITER_COUNT 15
void mainImage(out vec4 fragColor, in vec2 fragCoord){
    // Roots associated with Polynomial being iterated.
    roots = vec2[NROOTS](vec2(  0.0, -1.+sin(iTime)), 
                         vec2(  0.5,          0.866), 
                         vec2( -0.5,          0.866));

    // scale math space
    vec2 z = scale(fragCoord.xy, iResolution.xy, mat2(-1.25, 1.25, -.5, 1.)); 
    
    // calculate pixel convergence & color
    for(int i = 0; i < ITER_COUNT; i++){
        z = newton_iter(z);
    }
    
    // coloring
    int col_index = get_nearest_root(z);
    vec3 col = vec3(col_index-0==0,col_index-1==0,col_index-2==0);
    
    fragColor = vec4(hueShift(col, cos(iTime)), 1.);
}