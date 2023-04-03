#define MAX_ITER 50

vec3 getColor(vec3 c) {
    float r = sin(c.x * 10.0 + iTime * 0.1) * 0.5;
    float g = cos(c.y * 10.0 + iTime * 0.2) * 0.5;
    float b = sin(c.z * 10.0 + iTime * 0.3) * 0.5;
    return vec3(r, g, b);
}
vec2 rotate(vec2 p, float a) {
    float s = sin(a);
    float c = cos(a);
    return vec2(p.x*c - p.y*s, p.x*s + p.y*c);
}

vec3 fractalFlame(vec2 p, float time) {
    vec2 c = vec2(sin(time), cos(time)) * 0.5;
    float a = time * 0.1;
    float scale = 20.0;
    float weight = 0.5;
    vec3 sum = vec3(0.0);
    for (int i = 0; i < MAX_ITER; i++) {
        p *= scale;
        p = rotate(p, a);
        p += c;
        if (p.x < 0.0) p.x = -p.x;
        if (p.y < 0.0) p.y = -p.y;
        if (p.x > 1.0) p.x = 2.0 - p.x;
        if (p.y > 1.0) p.y = 2.0 - p.y;
        vec2 q = vec2(p.x - 0.5, p.y - 0.5);
        float r = length(q);
        float a = atan(q.y, q.x) + 2.0 * time;
        vec2 s = vec2(cos(a), sin(a)) * r;
        vec2 t = vec2(cos(a * 2.0), sin(a * 2.0)) * r * 0.5;
        vec3 val = vec3(sin(s.x), cos(t.y), sin(s.y + t.x));
        sum += weight * val;
        weight *= 0.5;
        scale *= 0.5;
    }
    return sum / float(MAX_ITER);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    float time = iTime * 0.1;
    vec3 value = fractalFlame(uv, time);
    fragColor = vec4(getColor(value), 1.0);
}
