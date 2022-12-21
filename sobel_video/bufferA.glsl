#iChannel0 "file://assets/sample.jpg"
#include "common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //fragColor = texture(iChannel0, UV);
    fragColor = texture(iChannel0, UV-0.05*cos(iTime)*sin(iTime));
}