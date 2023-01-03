#iChannel0 "file://bufferA.glsl"
#iChannel1 "file://bufferB.glsl"
#include "common.glsl"
#define STX sin(fragCoord.x*iTime)
#define STY sin(fragCoord.y*iTime)
precision highp float;


//#define TV_COLOR
void mainImage( out vec4 O, in vec2 fragCoord )
{
    vec4 C0 = texelFetch(iChannel0, ivec2(fragCoord.xy), 0);
    vec4 L0 = filter3x3(fragCoord.xy, LAPLACIAN, iChannel0, iResolution.xy);
    vec4 G0 = filter3x3(fragCoord.xy, GAUSSIAN, iChannel0, iResolution.xy);
    vec4 S0 = sobel(fragCoord.xy, iChannel0, iResolution.xy);
    vec4 G1 = filter3x3(fragCoord.xy, GAUSSIAN, iChannel1, iResolution.xy);

    vec4 F0 = -L0 * (2.-C0);
    vec4 col = (sin(iTime*1.1)*0.5)*S0*C0/G0+abs(cos(iTime*0.9))*(F0+G0);
    //col = col + cos(iTime)*C0*((G0 + G1) * 0.5);
    
    #ifdef TV_COLOR
    O = vec4(hueShift(col.xyz, cos(iTime*0.01)), 1.);
    #else
    O = col;
    #endif
}