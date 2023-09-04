#define MAX_ITERATIONS 256
#define SCALE 1.0

vec2 hash2(vec2 p) {
    vec2 o = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(o) * 43758.5453123);
}

vec2 voronoi(vec2 x) {
    vec2 p = floor(x),
     f = fract(x),
     res = vec2(8.);
     
    for(int j=-1; j<=1; j++) {
        for(int i=-1; i<=1; i++) {
            vec2 b = vec2(i,j),
             r = vec2(b) - f + hash2(p + b);
            float d = dot(r, r);

            if(d < res.x) {
                res.y = res.x;
                res.x = d;
            }
            else if(d < res.y) {
                res.y = d;
            }
        }
    }
    return sqrt(res);
}

void mainImage(out vec4 O, in vec2 U) {
    vec2 p = 0.5 + (U/iResolution.xy-0.5)*2.0,
     w = p, d;
     
    for(int i=0; i<MAX_ITERATIONS; i++) {
        d = voronoi(p);
        w += 0.5*(d.x+d.y)*p;
    }
    
    O = vec4(0.5 + 0.5*cos(iTime + w.xyx + vec3(0,2,4)),1.0);
}
