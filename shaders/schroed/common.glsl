// shadertoy common
#define R iResolution
#define UV (U/R.xy)
#define A texture(iChannel0, UV)
#define B texture(iChannel1, UV)
#define C texture(iChannel2, UV)
#define D texture(iChannel3, UV)

// math common
vec2 wrap(in vec2 p, in vec2 res) {
    vec2 wrapped = mod(p, res);
    vec2 stepWrap = step(wrapped, vec2(0.0));
    wrapped += stepWrap * res;
    
    // Smooth interpolation
    vec2 smoothed = mix(wrapped, p, smoothstep(0.0, 1.0, stepWrap));
    return smoothed;
}

vec4 bicubic(sampler2D tex, vec2 uv) {
    vec2 f = 1.0 / iResolution.xy;
    vec2 x = uv * f;
    vec2 i = floor(x);
    vec2 f1 = x - i;
    vec2 f2 = f1 + f1;

    vec4 a = texture(tex, i);
    vec4 b = texture(tex, i + vec2(1, 0));
    vec4 c = texture(tex, i + vec2(0, 1));
    vec4 d = texture(tex, i + vec2(1, 1));

    return mix(mix(a, b, f1.x), mix(c, d, f1.x), f1.y);
}

vec4 lap(in sampler2D c, in vec2 p, in vec2 r) {
    vec4 sum = vec4(0.0);

    vec2 wrapped = wrap(p, r);
    vec2 texelSize = 1. / r;

    sum += texture(c, wrapped + vec2(0.0, -texelSize.y));
    sum += texture(c, wrapped + vec2(-texelSize.x, 0.0));
    sum -= 4.0 * texture(c, wrapped);
    sum += texture(c, wrapped + vec2(texelSize.x, 0.0));
    sum += texture(c, wrapped + vec2(0.0, texelSize.y));

    return sum;
}
