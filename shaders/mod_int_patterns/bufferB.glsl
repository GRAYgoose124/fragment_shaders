#iChannel0 "file://bufferA.glsl"
#iChannel1 "file://bufferB.glsl"

#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = filter3x3(fragCoord.xy, LAPLACIAN, iChannel0, iResolution.xy) + 
                filter3x3(fragCoord.xy, GAUSSIAN, iChannel1, iResolution.xy);    
}