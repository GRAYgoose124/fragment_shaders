#include "common.glsl"

#define POINTS 1

#define MOUSE_REL 0
#define RELATIVE 0
#define MASS_REL 0

#define ZOOM 1.
#define NROOTS 15
#define ITER_COUNT 350
#define ERROR 0.000001

vec2 roots[NROOTS];
vec3 colors[NROOTS];

// TODO: Mass relative with just 2 random roots.
vec2 coord(in vec2 p){
    // FS mat2 S = mat2(-1.305, 1.305, -1., 1.);
    mat2 S = mat2(-1.,1.,-1.,1.);
    p = scale(p, iResolution.xy, S);
    //p += vec2(.25, .0);

    #if MOUSE_REL
    p += ZOOM*(Mouse.xy - vec2(.5));
    #endif

    #if RELATIVE
    p += roots[int(floor(mod(cos(uTime*0.05), float(NROOTS))))] + p/2.;
    #endif

    #if MASS_REL
    vec2 off = vec2(0.);
    for (int i=0;i<NROOTS;i++){
        off += roots[i];
    }
    off /= float(NROOTS);
    p += off;
    #endif



    p = 1./ZOOM * p;

    return p;
}

int nearest_root(in vec2 z){
    int index = 0;

    float dist = 100.;
    for(int i = 0; i < NROOTS; i++){
        float d = length(z - roots[i]);

        if(d < dist){
            index = i;
            dist = d;
        }
    }
    
    return index;
}

int[NROOTS] ordered_roots(in vec2 z){
    int minI, maxI;
    float minD = 100.;
    float maxD = 1.;
    float dists[NROOTS];
    int indices[NROOTS];

    for(int i = 0; i < NROOTS; i++){
        float d = length(z - roots[i]);
        dists[i] = d;

        if(d < minD){
            minI = i;
            minD = d;
        }

        if(d > maxD){
            maxI = i;
            maxD = d;
        }
    }

    return indices;
}

vec2 newton_iter(in vec2 z){
    vec2 sum = vec2(0.);

    for(int i = 0; i < NROOTS; i++){
        vec2 dist = z - roots[i];
        float delta = c_magsqrd(dist);
        if (delta < ERROR) return z - delta;//z-delta;
          
        sum += c_conj(dist)/delta;
    }

    return z - c_recip(sum);
}

void setup(){
    for(int i = 0; i < NROOTS; i++){
        float rot = float(i+1) * iTime * 0.01;
        //roots[i] = vec2(rot*sin(rot), rot*cos(rot)); sin(rot+i)
        roots[i] = vec2(sin(rot), cos(rot));

        colors[i] = hueShift(vec3(hash(float(i)),
                                  hash(float(i+1)),
                                  hash(float(i+2))), (float(i)));
    }
}

void gui(inout vec3 col){
    #if POINTS
    for(int i=0;i<NROOTS;i++){
        col = draw_point(col, coord(gl_FragCoord.xy), roots[i], 0.00001);
    }
    //col = draw_point(col, fragCoord.xy, iMouse.xy, 5.);
    #endif
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    setup();

    vec2 orig_z = coord(gl_FragCoord.xy);
    vec2 z = orig_z;

    vec3 col = vec3(0.);
    for (int i = 0; i < ITER_COUNT; i++) {
       z = newton_iter(z);
    }

    //vec3 col;
    col = colors[nearest_root(z)] / (1.+length(z - orig_z));// * (dists[i] / maxD);

    vec2 zoff = (z - orig_z);
    col *= zoff.xxy*zoff.xyy; // UV plane per root frame. - Swizzle it.

    gui(col);
    fragColor = vec4(col, 1.);
}
