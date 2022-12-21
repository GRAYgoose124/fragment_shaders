#include "common.glsl"
// 1 3 1 3 2     | s 0 0 1.5 0 | 40 25
// 1 3 1,2 4 2   | s 0 0 1.5 0 | 40 50 // sick 2pass 'the multiplier' //use high root count 
// 3,* 3,4 1 3 2 | s 1 1 1.5 0 | 20 50 // best demo pass, 
// * * * 2 1     ||
// 1 5 2 4 0,2   || 30 50
// 1 3 2 4 2     || 20 50
// 1 5 1 3 3
// ROT = (0: undef, 1-3: root generation, 4: music/broken)
#define ROT 1
// COLOR = (0: bw, 1-5: colors)
#define COLOR 5
// SMOOTH = (0: NoPatt, 1: ndblend, 2: -ablend/sin(nrdist), 3: none) 
#define SMOOTH 1
// TWOPASS = (0: NoPass, 1: blendmix, 2: blend/nearest_root, 3: trippy/space, 4: space) most distort color todo-v
#define TWOPASS 3
// PAL_SHIFT = (0: NoShift, 1: hsv_distort(broken), 2: hsv_super_sat/timevary, 3: hsv/off/timevary, 4:music/broken)
// If you use music make sure iChannel0 is set, otherwise, don't use music ;)
#define PAL_SHIFT 3

#define ITYPE 0
#define SCALING 0
#define MOUSE 0 
#define POINTS 0
// If you can handle it - high zoom + shutter effect + proper cognitive alignment = :v
#define ZOOM 1.5
#define AA 0

// if lagging <= 12/50
#define NROOTS 20
#define ITER_COUNT 50

vec2 roots[NROOTS];
vec3 colors[NROOTS];
vec2 uv;
// fractal iter & scaling
vec2 newton_iter(in vec2 z){
    vec2 sum = vec2(0.);
    
    for(int j = 0; j < NROOTS; j++){
        vec2 dist = z - roots[j];
        float delta = c_magsqrd(dist);
        if (delta  < ERROR) return z;//+c;
          
        sum += c_conj(dist)/delta;
    }

    return z - c_recip(sum);
}
vec2 get_coord(in vec2 p){
    // scale pixel to fractal coords
    p = vec2(scale(p.x, iResolution.x, -2.5, 1.),
             scale(p.y, iResolution.y, -1., 1.));
    
    //p += roots[0]; //relative to root
    p += vec2(.75, 0.);

    return 1./ZOOM * p;
}
// root dists
int get_nearest_root(vec2 z){
    int index = 0;
    float dist = 1000.;
    for(int i = 0; i < NROOTS; i++){
        float d = c_magsqrd(z - roots[i]);
        if(d < dist){
            dist = d;
            index = i;
        }
    }
    return index;
}
vec3 nearish_roots(vec2 z){
    vec3 color = vec3(1.);
    
    float dist = 10000.;
    for(int i = 0; i < NROOTS; i++){
        float d = c_magsqrd(z - roots[i]);
        if(d < dist) {
            dist = d;
            color += colors[i] / (d);
            color /= 2.;

        }
    }
    
    vec3 final = color;
    
    return scale(final, 100., 0., 1.);
}
vec3 nearish_roots2(vec2 z){
    vec3 color = vec3(1.);
    
    float dist = 10000.;
    for(int i = 0; i < NROOTS; i++){
        float d = c_magsqrd(z - roots[i]);
        if(d < dist) {
            dist = d;
            color += colors[i] / (d) - (colors[i-1] / d);
            color /= 2.;

        }
    }
    
    vec3 final = color;
    
    return scale(final, 100., 0., 1.);
}
vec3 nearish_roots3(vec2 z){
    vec3 color = vec3(1.);
    
    float dist = 10000.;
    for(int i = 0; i < NROOTS; i++){
        float d = c_magsqrd(z - roots[i]);
        if(d < dist) {
            dist = d;
            color += colors[i] / (d) - (colors[i-1] / d);
            color /= 2.;

        }
    }
    
    vec3 final = color;
    
    return scale(final, 100., 0., 1.);
}
// root gens
vec2 generate_root_rot(int offset){
    float rot = 0.1 * iTime * (2./ZOOM) * (float(offset+1)*.1) + float(offset+1)*.5;
    return vec2(sin(rot), cos(rot));
}
vec2 generate_root_rothelix(int offset){
    float rot = 0.1 * iTime * (float(offset+1)*.1) + float(offset+1)*10.;
    return vec2(cos(rot)*sin(rot), sin(cos(rot)));
}
vec2 generate_root_csrot(int offset){
    vec2 new_root;
    
    float rot = 0.1 * iTime * (float(offset+1)*.1) + float(offset+1)*10.;
    return vec2(cos(rot)*1.+sin(float(offset)), sin(cos(rot))*1.+cos(float(offset)));
    
    return 5.*new_root;
}

// color palettes
vec3 generate_bw(int offset){
    vec3 nc;
    if (mod(float(offset), 2.) == 0. ) {
        return vec3(0.);
    } else {
        return vec3(1.);
    }
}  
vec3 generate_bwg(int offset){
    vec3 new_color = vec3(1. *sin(float(offset)));
    return new_color;
}
vec3 generate_color_rpb(int offset){
    vec3 new_color = vec3(.82 - sin(hash(float(offset))), .534 - cos(hash(float(offset+1))), .231 + tan(hash(float(offset+2))));
    return new_color;
}
vec3 generate_color_lights(int offset){
    vec3 new_color = vec3(.1 * sin(0.16*iTime*float(offset)),
                          .2 * cos(0.13*iTime*float(offset)),
                          .4+.3 * sin(0.32*cos(0.15*iTime*float(offset))));
    new_color += vec3(  cos(0.26*iTime*float(offset)), // also try *=
                            sin(0.22*iTime*float(offset)),
                           cos(0.11*sin(0.15*iTime*float(offset))));
    return new_color / 2.;
}
vec3 generate_color_trippy(int offset){
    vec3 new_color = vec3(.1 * sin(0.16*iTime*float(offset)),
                          .2 * cos(0.13*iTime*float(offset)),
                          .4+.3 * sin(0.32*cos(0.15*iTime*float(offset))));
    new_color -= vec3(  cos(0.26*iTime*float(offset)),
                            sin(0.22*iTime*float(offset)),
                           cos(0.11*sin(0.15*iTime*float(offset))));
    return new_color;
}
vec3 generate_color_bpw(int offset){
    vec3 new_color = vec3(.1 * sin(0.16*iTime*float(offset))* cos(0.13*iTime*float(offset)),
                          .2 * cos(0.13*iTime*float(offset)),
                          .3 * sin(0.32*cos(0.15*iTime*float(offset))));
    new_color -= vec3(  cos(0.26*iTime*float(offset)),
                           sin(0.22*iTime*float(offset)),
                           cos(0.11*sin(0.15*iTime*float(offset))));
    return new_color - sin(new_color);
}
vec3 generate_color_bpwt(int offset){
    vec3 new_color = vec3(.1 * sin(0.16*float(offset))* cos(0.13*float(offset)),
                          .2 * cos(0.13*float(offset)),
                          .3 * sin(0.32*cos(0.15*float(offset))));
    new_color -= vec3(  cos(0.26*float(offset)),
                           sin(0.22*float(offset)),
                           cos(0.11*sin(0.15*float(offset))));
    return new_color - sin(new_color);
}
vec3 generate_color_faulty_wires(int offset){
    vec3 new_color = vec3(.1 * sin(0.16*iTime*float(offset)),
                          .2 * cos(0.13*iTime*float(offset)),
                          .1+.3 * sin(0.32*cos(0.15*iTime*float(offset))));
    new_color /= vec3(  cos(0.26*iTime*float(offset)),
                            0.1*sin(0.22*iTime*float(offset)),
                           cos(0.11*sin(0.15*iTime*float(offset))));
    return sin(new_color);
}
// 2 pass
vec3 p_nr_def(vec2 z){
    return colors[get_nearest_root(z)];
}  
vec3 p_nr_def_AA(vec2 z, vec2 z1, vec2 z2, vec2 z3){
    vec3 col = p_nr_def(z) + p_nr_def(z1) + p_nr_def(z2) + p_nr_def(z3);
    col /= 4.;
    return col; 
}
// color shift
vec3 sc_hsv_distort(in vec3 col){
    col = rgb2hsv(col);
    col = vec3(sin(col.x), cos(col.y), sin(col.z) + cos(col.z));
    col = hsv2rgb(col);
    return col;
}
vec3 pal_shift1(in vec3 col){
    //col = rgb2hsv(col);
    col -= vec3(sin(0.0003*iTime), cos(0.0015*iTime), sin(0.0012*iTime) + cos(0.0013*iTime));
    //col = hsv2rgb(col);
    return col;
}
vec3 pal_shift2(in vec3 col){
    //col = rgb2hsv(col);
    col *= vec3(col.x - sin(0.0003*iTime), col.y - cos(0.0015*iTime), col.z - sin(0.0012*iTime) + cos(0.0013*iTime));
    //col = hsv2rgb(col);
    return 2.*col;
}

    
// Main logic flow
void space_setup(){
    for(int i = 0; i < NROOTS; i++){
        // root init
        #if (ROT == 1)
        roots[i] = generate_root_rot(i);
        #elif (ROT == 2)
        roots[i] = generate_root_rothelix(i);
        #elif (ROT == 3)
        roots[i] = generate_root_csrot(i);
        #elif (ROT == 4)
        roots[i] = generate_root_music(i);
        #endif
        
        // col palette init
        #if (COLOR == 1)
        colors[i] = generate_color_faulty_wires(i); 
        #elif (COLOR == 2)
        colors[i] = generate_color_rpb(i);
        #elif (COLOR == 3)
        colors[i] = generate_color_lights(i);
        #elif (COLOR == 4)
        colors[i] = generate_color_trippy(i);
        #elif (COLOR == 5)
        colors[i] = generate_color_bpw(i);
        #elif (COLOR == 6)
        colors[i] = generate_color_bpwt(i);
        #else
        colors[i] = generate_bwg(i);
        #endif
    }
}
vec3 color_pass(in vec3 col, vec2 z){
    #if (SMOOTH == 1)
    col += nearish_roots(z);
    #elif (SMOOTH == 2)
    col += nearish_roots2(z);
    #elif (SMOOTH == 3)
    col += nearish_roots3(z);
    #elif (SMOOTH == 4) 
    #endif
    
    // color distort
    #if (PAL_SHIFT == 1)
    col = sc_hsv_distort(col);
    #elif (PAL_SHIFT == 2)
    col = pal_shift1(col);
    #elif (PAL_SHIFT == 3)
    col = pal_shift2(col);
    #elif (PAL_SHIFT == 4)
    col = pal_shift_music(col);
    #endif
    
    return col;
}
vec3 two_pass(in vec3 col, vec2 z){
    #if (TWOPASS == 1) 
    // simple blend
    col /= -col + 16.*colors[get_nearest_root(z)];
    #elif (TWOPASS == 2)
    // simple blend2
    col += .4*colors[get_nearest_root(z)];
    // TRIPPY PASS
    #elif (TWOPASS == 3)
    col.yz += 0.25*cos(z);
    col.xy *= sin(z);
    // TRIPPY ORIG
    #elif (TWOPASS == 4)
    col += p_nr_def(z);
    col += col*p_nr_def(z)+sin(0.011*iTime)* (cos(0.02*iTime)*col);
    col.xy /= 5.*cos(z);
    col.z /= 5.*cos(0.031*iTime);
    #elif (TWOPASS == 5)
    col.yz /= .3-cos(z)*col.xz;
    col.xy *= sin(z);
    #elif (TWOPASS == 6)
    // yeah idk
    col /= -col*col / colors[get_nearest_root(z)];
    #endif
    
    return col;
}
vec3 fractal_pass(vec2 pos){
    // set up fractal coordinate system
    vec2 z;
    #if (SCALING < 1)
    z = get_coord(pos);
    #elif (SCALING == 1)
    z = get_coord(pos) + get_coord(root[0]);
    z *= z - get_coord(z);
    #elif (SCALING == 2)
    z = get_coord(pos);
    z *= get_coord(sin(z) * get_coord(cos(z)));
    //z *= get_coord(z);
    #elif (SCALING == 3)
    z = get_coord(pos);
    #endif
    
    #if MOUSE
    if (iMouse.x != 0.) {
    z += vec2(scale(iMouse.x, iResolution.x, -40., 8.)+15.,
              scale(iMouse.y, iResolution.y, -8., 8.));
    } 
    #endif
      
    #if AA
    vec2 z1 = get_coord(pos + vec2(.33, .33));
    vec2 z2 = get_coord(pos + vec2(-.33, -.33));
    vec2 z3 = get_coord(pos + vec2(.33, -.33));
    #endif
    
    // calculate pixel convergence & AA
    for (int i = 0; i < ITER_COUNT; i++) {
       #if (ITYPE == 0)
       z = newton_iter(z);
       #elif (ITYPE == 1)
       z += newton_iter(z) - newton_iter(z*get_coord(z));
       z /= 2.;
       #elif (ITYPE == 2)
       z += z/c_magsqrd(newton_iter(z) - get_coord(pos));
       #endif
       
       #if AA
       z1 = newton_iter(z1);
       z2 = newton_iter(z2);
       z3 = newton_iter(z3);
       #endif
    }
    
    vec3 col;
    // AA
    #if AA
    col = p_nr_def_AA(z, z1, z2, z3);
    #else 
    col = p_nr_def(z);
    #endif
    
    // color by root / TODO: apply 2nd pass AA 
    #if SMOOTH 
    col = color_pass(col, z);
    #endif
    // 2nd pass
    #if TWOPASS
    col = two_pass(col, z);
    #endif
    
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    space_setup();
    
    vec3 col = fractal_pass(fragCoord);
   
    // Add root visualization
    #if POINTS
    for(int i=0;i<NROOTS;i++){
        col = draw_point(col, get_coord(fragCoord), roots[i], 0.00001);
    }
    col = draw_point(col, fragCoord.xy, iMouse.xy, 5.);
    #endif
    
    fragColor = vec4(col, .5);
}