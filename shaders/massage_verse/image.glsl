#define T iTime
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.1 * iResolution.xy) / iResolution.y;

    vec3 accColor = vec3(0.0);
    vec3 curColor;

    int iters = 20;

    for (int i = 0; i < iters; i++) {
        float sign = (i % 2 == 0 ? .1 : -.1); 
        float angFac = 0.1 + 0.05 * length(accColor);

        float angR = sign * T * (.103 + float(i) * angFac);
        float angG = sign * T * (.203 + float(i) * angFac);
        float angB = sign * T * (.303 + float(i) * angFac);

        mat2 rotR = mat2(cos(angR), -sin(angR),
                         sin(angR), cos(angR));
        mat2 rotG = mat2(cos(angG), -sin(angG),
                         sin(angG), cos(angG));
        mat2 rotB = mat2(cos(angB), -sin(angB),
                         sin(angB), cos(angB));

        vec2 pR = rotR * (uv - 0.5) + 0.5;
        vec2 pG = rotG * (uv - 0.5) + 0.5;
        vec2 pB = rotB * (uv - 0.5) + 0.5;
        
        float mixR = 0.75 + 0.25 * sin(T + float(i) * 0.1);
        float mixG = 0.75 + 0.25 * cos(T + float(i) * 0.2);
        float mixB = 0.75 + 0.25 * sin(T + float(i) * 0.3);

        float freqX = 20.0 + 10.0 * sin(0.5 * T + float(i) * 0.1);
        float freqY = 50.0 + 25.0 * cos(0.7 * T + float(i) * 0.1);

        float mixF = 0.5 + 0.5 * length(accColor); 

        float dist = length(uv - .5);
        float focalStr = smoothstep(0.0, 0.2, 0.5 - dist);

        curColor.r = mix(0.5 + 0.5 * cos(freqX * pR.x),
                         0.5 + 0.5 * cos(freqY * pR.y),
                         mixR) * focalStr;
        curColor.g = mix(0.5 + 0.5 * cos(freqX * pG.x),
                         0.5 + 0.5 * cos(freqY * pG.y),
                         mixG) * focalStr;
        curColor.b = mix(0.5 + 0.5 * sin(freqX * pB.x),
                         0.5 + 0.5 * sin(freqY * pB.y),
                         mixB) * focalStr;

        accColor = mix(accColor, curColor, 0.5 / float(i + 1));
    }

    accColor = smoothstep(0.0, 1.0, accColor);

    fragColor = vec4(accColor, 1.0);
}
