#define T iTime
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord) / iResolution.y;

    vec3 accColor = vec3(0.0);

    int iters = 80;

    for (int i = 0; i < iters; i++) {
        float rad = length(uv - 0.5);
        float ang = atan(uv.y - 0.5, uv.x - 0.5);
        float wave = sin(rad * 10.0 + T) * cos(ang * float(i) + T);

        float phase = T * 0.1 + float(i) * rad;
        float freq = 20.0 + 10.0 * rad * sin(phase);

        vec3 waveColor = vec3(sin(freq + phase), cos(freq + phase), sin(freq - phase));
        waveColor = mix(waveColor, vec3(1.0) - waveColor, wave);

        accColor += waveColor / float(iters);
    }

    accColor = clamp(accColor, 0.0, 1.0);
    accColor = pow(accColor, vec3(1.2)); 

    fragColor = vec4(accColor, 1.0);
}
