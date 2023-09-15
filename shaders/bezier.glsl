// Calculate the SDF for the Bezier curve.
float bezierSDF(vec2 position, vec2 p0, vec2 p1, vec2 p2, vec2 p3) {
    float t = 0.5; 
    float minDist = 1.; 

    for (int i = 0; i < 16; i++) {
        vec2 bezierPoint = mix(
            mix(mix(p0, p1, t), mix(p1, p2, t), t), 
            mix(mix(p1, p2, t), mix(p2, p3, t), t), 
        t);
        float dist = length(bezierPoint - position);
        minDist = min(minDist, dist);

        vec2 de = 3.0 * pow(1.0 - t, 2.0) * (p1 - p0) + 6.0 * (1.0 - t) * t * (p2 - p1) + 3.0 * t * t * (p3 - p2);
        float dotProd = dot(de, bezierPoint - position);
        t -= dotProd / dot(de, de);
    }

    return minDist;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    vec2 p0 = vec2(-sin(iTime), -cos(iTime));
    vec2 p1 = vec2(-1.0, cos(iTime));
    vec2 p2 = vec2(sin(iTime), -1.0);
    vec2 p3 = vec2(cos(iTime), sin(iTime));

    vec3 color = vec3(smoothstep(0.005, .01, bezierSDF(uv, p0, p1-p0, p2-p0, p3-p0)));

    fragColor = vec4(color, 1.0);
}

