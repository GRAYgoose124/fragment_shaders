#iChannel0 "self"

#include "common.glsl"
// Hacked together, could use better color scaling among other things.
// Uncomment mouse to vary patterns interactively. Otherwise, try changing the constants.

//Try ~5 - ~500
#define SCALING 50.

#define VSPD1 1.8459
#define VSPD2 .513

//Change inversely with SCALE.
#define VSPD3 3.956
//#define VSPD3 (iMouse.x / iResolution.x * 2.)


// Carpet constants: ABC:(R, G, B) channels.
    // Try settings like ABC = 2,2,1; across all 3 channels. 
    // Or ABC = 5,15,30; pi,e,phi; Mix and match ABCs. 
    // The fewer common factors across channels, the fewer emergent patterns made of secondary colors.
    // Moirre == Secondary+ patterns
    // The fewer common factors in general, the more aperiodic it will seem.
#define AR (BR * 9.)
#define BR (CR * 4.)
#define CR 36.

#define AG (BG * 3.)
#define BG (CG * 6.)
#define CG 18.

#define AB (BB * 3.)
#define BB (CB * 9.)
#define CB 27.


// Optional:
    // Changes the base coordinate for each pattern at 90* phase offset or mouse.
#define VARYING_COORD
//#define MOUSE_COORD

    // Pan the plane
//#define TIME_DISPLACE

    // Vary carpet pattern factors with the mouse. 
    // With only this enabled, explore the space and notice some factors have more structure.
    // This will not replace varying the carpet constants, as it's only exploring a space within the gratings they define.
//#define MOUSE


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iTime / 30.0;

    #ifdef TIME_DISPLACE
    vec2 pos = vec2(sin(t), cos(t)) * VSPD1;
    #else
    vec2 pos = vec2(0.);
    #endif
    
    vec2 uv = trunc((fragCoord.xy/iResolution.y + pos) * SCALING);
    
    #ifdef VARYING_COORD
    vec2 pos2 = vec2(cos(t) * VSPD1,  sin(t) * VSPD2) * VSPD3;
    vec2 uv2 = trunc((fragCoord.xy/iResolution.y + pos2) * SCALING);
    #else
    vec2 uv2 = uv;
    #endif
    
    #ifdef MOUSE_COORD
    vec2 pos2 = vec2(cos(iMouse.x) * VSPD1, sin(iMouse.y) * VSPD2) * VSPD3;
    uv2 = trunc((fragCoord.xy/iResolution.y + pos2) * SCALING);
    #endif

    #ifdef MOUSE
    float o1 = iMouse.x / iResolution.x; float o2 = iMouse.y / iResolution.y;
    float o3 = (iMouse.x * iMouse.y) / (iResolution.x * iResolution.y);
    #else
    float o1 = 1.;float o2 = 1.;float o3 = 1.;
    #endif
    
    float r = mod(mod(dot(uv, uv2), AR*o1), BR*o2) / (CR*o3);
    float g = mod(mod(dot(uv, uv2), AG*o3), BG*o1) / (CG*o2);
    float b = mod(mod(dot(uv, uv2), AB*o2), BB*o3) / (CB*o1);


    vec4 col = vec4(r*r-g*b, g*g-r*b, b*b-r*g, 1.0);
        
    fragColor = col;//+ (0.8*filter3x3(P, GAUSSIAN, iChannel0, RES));
}

