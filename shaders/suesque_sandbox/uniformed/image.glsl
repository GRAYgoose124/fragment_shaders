#iChannel0"file://bufferA.glsl"

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    fragColor=texture(iChannel0,fragCoord.xy/iResolution.xy);
}