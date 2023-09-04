vec2 hash2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(1352.1, 2352.53)), 
                          dot(p, vec2(1242.35, 5531.3))))
                                        * 43758.5453123);
}

vec4 voronoi(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    vec4 res = 4.*vec4(vec2(abs(sin(iTime*.1))), vec2(abs(cos(iTime*.15))));

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 b = vec2(i, j);
            vec2 r = vec2(b) - f + hash2(p + b); // change - to * for menagerie
            float d = dot(r, r);

            if (d < res.x)
                res.y = res.x,
                res.x = d;
            else if (d < res.y)
                res.y = d;
        }
    }
    return res / sqrt(res);
}

void mainImage(out vec4 O, in vec2 U) {
    vec2 p = (1. + (U / iResolution.xy - 1.) * 4.0);
    vec4 w = vec4(p, 0.0, 0.0), d;

    for (int i = 0; i < 128; i++) {
        d = voronoi(p);
        w += vec4(p * (d.x - d.y) * sin(d.z) * cos(d.w), d.xy);
    }

    O = vec4(0.5 + 0.5 * cos(w.y - 0.0023 * sin(w.x + w.z)),
             0.5 + 0.5 * sin(w.x + 0.0035 * cos(w.y + w.w)),
             0.5 + 0.5 * cos(w.x + w.z) * sin(w.y + w.w),
             1.0);
}
