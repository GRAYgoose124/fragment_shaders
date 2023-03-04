#iChannel0 "file://bufferA.glsl"
#iChannel1 "self"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 blurred = filter3x3(P, GAUSSIAN, iChannel0, RES); 
    fragColor = vec4((blurred.x + blurred.y + blurred.z) * 0.3333);
}