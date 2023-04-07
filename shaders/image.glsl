void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Camera parameters
    vec3 cameraPos = vec3(0.0, 0.0, -10.0);
    vec3 cameraDir = normalize(vec3(fragCoord.xy - iResolution.xy / 2.0, iResolution.y));
    vec3 cameraRight = normalize(cross(cameraDir, vec3(0.0, 1.0, 0.0)));
    vec3 cameraUp = cross(cameraRight, cameraDir);
    float cameraFOV = 100.0;
    float cameraAspectRatio = iResolution.x / iResolution.y;

    // Bezier curve parameters
    vec2 p0 = vec2(-1.0, -1.0);
    vec2 p1 = vec2(-1.0, 1.0);
    vec2 p2 = vec2(1.0, 1.0);
    vec2 p3 = vec2(1.0, 0.0);
    float tMax = 1.0;

    // Pathtracer settings
    int maxSteps = 256;
    float epsilon = 0.001;
    float lightIntensity = 1.0;
    vec3 lightPos = vec3(-2.0, 2.0, -2.0);

    // Compute ray direction
    float fovScale = tan(radians(cameraFOV) / 2.0);
    vec3 rayDir = normalize(cameraDir + cameraRight * (fragCoord.x / iResolution.x - 0.5) * cameraAspectRatio * fovScale + cameraUp * (fragCoord.y / iResolution.y - 0.5) * fovScale);

    // Compute intersection with Bezier curve
    float t = cos(iTime);
    float tMin = 0.0;
    float distMin = 0.1;
    for (int i = 0; i < 100; i++) {
        vec2 pos = mix(mix(mix(p0, p1, t), mix(p1, p2, t), t), mix(mix(p1, p2, t), mix(p2, p3, t), t), t);
        vec2 dPos = mix(mix(p1 - p0, p2 - p1, t), mix(p2 - p1, p3 - p2, t), t);
        vec2 ddPos = mix(p2 - 2.0 * p1 + p0, p3 - 2.0 * p2 + p1, t);
        float dist = length(cross(vec3(dPos, 0.0), vec3(pos - vec2(rayDir.xy) * t - cameraPos.xy, 0.0))) / length(vec3(dPos, 0.0));
        float dotProd = dot(vec3(rayDir.xyz), vec3(dPos, 0.0));
        float k = dot(vec3(rayDir.xyz), vec3(ddPos, 0.0)) / pow(length(vec3(dPos, 0.0)), 2.0);
        float a = dotProd * dotProd - dist * dist * length(vec3(dPos, 0.0)) * length(vec3(dPos, 0.0)) * (1.0 - k * k);
        if (a < 0.0) {
            t += tMax / pow(2.0, float(i));
        } else {
            float t1 = (-dotProd + sqrt(a)) / (length(vec3(dPos, 0.0)) * length(vec3(dPos, 0.0)) * (1.0 - k * k));
            float t2 = (-dotProd - sqrt(a)) / (length(vec3(dPos, 0.0)) * length(vec3(dPos, 0.0)) * (1.0 - k * k));
            if (t1 < t2) {
                t = t1;
            } else {
                t = t2;
            }
            if (t < tMin) {
                t += tMax / pow(2.0, float(i));
            } else {
                break;
            }
        }
    }

    // Compute color
    vec3 color = vec3(0.0);
    if (t < tMax) {
        vec2 pos = mix(mix(mix(p0, p1, t), mix(p1, p2, t), t), mix(mix(p1, p2, t), mix(p2, p3, t), t), t);
        vec2 dPos = mix(mix(p1 - p0, p2 - p1, t), mix(p2 - p1, p3 - p2, t), t);
        vec2 ddPos = mix(p2 - 2.0 * p1 + p0, p3 - 2.0 * p2 + p1, t);
        vec3 normal = normalize(vec3(-dPos.y, dPos.x, 0.0));
        vec3 lightDir = normalize(lightPos - vec3(pos, 0.0));
        float lightDist = length(lightPos - vec3(pos, 0.0));
        float lightDot = max(dot(normal, lightDir), 0.0);
        vec3 diffuse = vec3(1.0) * lightDot * lightIntensity / (lightDist * lightDist);
        vec3 ambient = vec3(0.1);
        color = diffuse + ambient;
    }

    // Render
    fragColor = vec4(color, 1.0);
}