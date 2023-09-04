#define N 9
#define FREQ_SCALE 1.

float frequencies[N] = float[N](1.0, 3.0, 5.0, 7.0, 9.0, 11., 13., 15., 17.);
float[N] redPatterns;
float[N] greenPatterns;
float[N] bluePatterns;

float[N] redFrequencies;
float[N] greenFrequencies;
float[N] blueFrequencies;

void update_frequencies() {
    for (int i = 0; i < N; i++) {
        redFrequencies[i] = frequencies[i] + sin(iTime + float(i)) * FREQ_SCALE;
        greenFrequencies[i] = frequencies[i] + sin(iTime + float(i) + 0.333) * FREQ_SCALE;
        blueFrequencies[i] = frequencies[i] + sin(iTime + float(i) + 0.666) * FREQ_SCALE;
    }
}

void create_patterns(vec2 uv, float[N] frequencies, out float[N] patterns) {
    vec2 polar = vec2(length(uv+cos(iTime)), atan(uv.y, uv.x));
    for (int i = 0; i < N; i++) {
        patterns[i] = sin(frequencies[i] * (polar.x + polar.y + cos(iTime * 0.5)));
        patterns[i] += sin(iTime * 0.5 + uv.x + uv.y * float(i) / float(N));
    }
}

vec3 calculateMoirePattern(float[N] redPatterns, float[N] greenPatterns, float[N] bluePatterns) {
    vec3 colorSum = vec3(0.0);
    for (int i = 0; i < N; i++) {
        colorSum.r += redPatterns[i];
        colorSum.g += greenPatterns[i];
        colorSum.b += bluePatterns[i];
    }
    return fract(colorSum / float(N));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    update_frequencies();
    create_patterns(uv, redFrequencies, redPatterns);
    create_patterns(uv, greenFrequencies, greenPatterns);
    create_patterns(uv, blueFrequencies, bluePatterns);

    vec3 moirePattern = calculateMoirePattern(redPatterns, greenPatterns, bluePatterns);

    vec3 color = vec3(0.5) + 0.5 * moirePattern;
    color *= smoothstep(vec3(0.0), vec3(1.0), color);

    fragColor = vec4(color, 1.0);
}
