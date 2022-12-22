//#define DRAW

// Utilities
    // macros
#define RES iResolution.xy
#define P fragCoord.xy
#define UV (fragCoord.xy/iResolution.xy)

#define Px (P.x/iResolution.x)
#define Py (P.y/iResolution.y)
#define Mx (iMouse.x/iResolution.x)
#define My (iMouse.y/iResolution.y)
#define Mxy (iMouse.xy/iResolution.xy)


    // screen
vec2 wrap(in vec2 p, in vec2 res) {
    if (p.x > res.x) p.x = mod(p.x, res.x);
    else if (p.x < 0.) p.x = res.x + p.x;
    
    if (p.y > res.y) p.y = mod(p.y, res.y);
    else if (p.y < 0.) p.y = res.y + p.y;
    
    return p;
}
  

    // Math
vec4 laplacian(in vec2 pos, in sampler2D channel, in vec2 reso){
    vec4 sum = vec4(0.);
    
    for(int i=-1; i<=1; i++) {
        for(int j=-1; j<=1; j++) {
            float weight = (i==0 && j==0) ? -1. : (abs(i-j) == 1 ? .2 : .05);
            sum += weight * texelFetch(channel, ivec2(wrap(pos + vec2(i, j), reso)), 0);
        }
    }
    
    return sum;
}