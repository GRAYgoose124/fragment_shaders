void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float factor;
    if(iTime>120.)
         factor = 250.*abs(sin(0.001*iTime));
    else
         factor = 100.*abs(sin(0.00018*iTime));
    vec2 uv = fragCoord / iResolution.xy * 2. * factor - vec2(0.6, 1.)* factor;

    // Add some noise to vary the shape
    if(iTime>120.)
        uv += 1.0 * vec2(sin(.01521*iTime + uv.y * 100.0), cos(0.023*iTime + uv.x * 100.0));

    else
        uv += 0.1 * vec2(sin(.01521*iTime + uv.y * 3.0), cos(0.023*iTime + uv.x * 3.0));

    // Rotate UV coordinates over time
    float rotationAngle = 0.000001 * iTime;
    uv = mat2(cos(rotationAngle), -sin(rotationAngle), sin(rotationAngle), cos(rotationAngle)) * uv;

    // Convert to polar coordinates
    float radius = length(uv);
    float angle = atan(uv.y, uv.x);

    // Constants
    float minCircleSize = 0.000022 * sin(0.0000003 * iTime);
    float maxCircleSize = 0.0012 * cos(0.0000111 * iTime);
    float moireFactor = 0.999; // Close to 1.0 to create moiré patterns

    // Modulate the circle size and frequency as a function of the radius
    float circleSize = mix(minCircleSize, maxCircleSize, 1.0 - radius);
    float frequency = 1.0 / circleSize;

    // Create two sets of circles with slightly different frequencies to
    // create moiré patterns
    float circle = 0.5 * sin(frequency * angle - iTime) + 0.5;
    for(int i=0; i<100; i++){
        if(i%2==0)
            circle += sin(moireFactor * frequency * angle - iTime) + 0.5;
        else if(i%3==0)
            circle *= sin(moireFactor * frequency * angle - iTime) + 0.5;
        else if(i%5==0)
            circle *= cos(moireFactor * frequency * angle - iTime) + 0.5;
        else
            circle *= cos(moireFactor*1.01 * frequency * angle - iTime) * sin(moireFactor*.99 * frequency * angle - iTime) + 0.5;
            
        moireFactor -= 0.0001;//*sin(0.01*iTime);
    }

    // Use the moiré pattern to modulate the color
    vec3 color;
    color.r = circle * sin(frequency * angle - iTime * 1.5) + circle * cos(frequency*.99 * angle - iTime * 1.5);
    color.g = circle * sin(1.00017 * frequency * angle - iTime * 1.5) + circle * cos(1.00325 * frequency * angle - iTime * 1.5);
    color.b = circle * sin(1.0025 * frequency * angle - iTime * 1.5) + circle * cos(1.0013 * frequency * angle - iTime * 1.5);


    // Output to screen
    fragColor = vec4(color, 1.0);
}
