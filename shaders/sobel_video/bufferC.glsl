#iChannel0 "file://bufferA.glsl"
#iChannel1 "self"
#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Only want the sobel from this source
    vec4 T = texture(iChannel1, UV);//* filter3x3(P, GAUSSIAN, iChannel0, RES)) * 0.25;
    vec4 sob = sobel(P, iChannel0, RES);
    
    fragColor = sob*sob;
}