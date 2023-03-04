#iChannel0 "file://bufferA.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = fragCoord/iResolution.xy;

    vec3 surface = texelFetch(iChannel0, ivec2(fragCoord), 0).xyz;

    vec3 col = surface.xyz;
    fragColor = vec4(col, 1.);
}