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
    return wrapped;
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

vec4 gauss(in sampler2D c, in vec2 p, in vec2 r) {
    vec4 sum = vec4(0.0);

    vec2 wrapped = wrap(p, r);
    vec2 texelSize = 1. / r;

    // Corner (Diagonal) elements
    sum += 0.0625 * texture(c, wrapped + vec2(-texelSize.x, -texelSize.y));
    sum += 0.0625 * texture(c, wrapped + vec2(-texelSize.x, texelSize.y));
    sum += 0.0625 * texture(c, wrapped + vec2(texelSize.x, -texelSize.y));
    sum += 0.0625 * texture(c, wrapped + vec2(texelSize.x, texelSize.y));
    
    // Side elements
    sum += 0.125 * texture(c, wrapped + vec2(0.0, -texelSize.y));
    sum += 0.125 * texture(c, wrapped + vec2(-texelSize.x, 0.0));
    sum += 0.125 * texture(c, wrapped + vec2(texelSize.x, 0.0));
    sum += 0.125 * texture(c, wrapped + vec2(0.0, texelSize.y));

    // Center element
    sum += 0.25 * texture(c, wrapped);

    return sum;
}

