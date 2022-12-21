#iChannel0 "file://bufferA.glsl"
#iChannel1 "self"
#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = filter3x3(P, LAPLACIAN, iChannel0, RES)+filter3x3(P, GAUSSIAN, iChannel1, RES);    
}