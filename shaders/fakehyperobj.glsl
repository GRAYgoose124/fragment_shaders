#define PI 3.1415926
// set to 0 to see the base object being...slice-jected?
#define ENABLE_SLICES 1
#define TICKRATE 1000.0

#define SAMPLES 100
// All iTime constants can be fine-tuned against each other. Also consider tuning the blur strength.
#define BLUR_STR (abs(sin(iTime*0.23)*cos(iTime*0.15)) / float(SAMPLES))

/// varying most constants or holding them produce very interesting sets of dynamics
#define SPOKE_WIDTH 0.033*abs(1.2-abs(sin(iTime*0.27)))
#define SPOKE_SPACING 0.035

// vestigial, behaves as an offset
#define ROTATION_SHUTTER_DIFF 14.0
// mostly a speed factor right now - it's tied to "tickrate"
#define ROTATION_SHUTTER_FACTOR 180.0
#define ROT (ROTATION_SHUTTER_FACTOR - ROTATION_SHUTTER_DIFF) / TICKRATE
#define SPD (ROTATION_SHUTTER_FACTOR + ROTATION_SHUTTER_DIFF) / TICKRATE

// Try float(i) - w/ 1000 samples it is weird, for sure.
#define ROT_ACC_FACT 1.0

vec4 getSpokeColor(vec2 uv, vec2 wheelCenter, float rotation, float wheelRadius) {
    vec2 wheelUV = uv - wheelCenter;
    if (length(wheelUV) < wheelRadius) {
        float normalizedAngle = mod(atan(wheelUV.y, wheelUV.x) + rotation, 2.0 * PI) / (2.0 * PI);
        float spokePattern = mod(normalizedAngle, SPOKE_SPACING) < SPOKE_WIDTH ? 1.0 : 0.0;
        return mix(vec4(0,0,0,1), vec4(1), spokePattern);
    }
    return vec4(0,0,0,1);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy,
     wheelCenter = vec2(0.5);
    float rotation = iTime * ROT * 2.0 * PI,
     shutterPhase = mod(iTime, SPD) / SPD,
     wheelRadius = 0.3;
     

#if ENABLE_SLICES
    vec2 blurDirection = vec2(cos(rotation), sin(rotation)),
     blurAmount = BLUR_STR * blurDirection;
    vec4 blurColor = vec4(0.);
    for (int i = 0; i < SAMPLES; ++i) {
        vec2 offsetUV = uv + blurAmount * float(i - SAMPLES / 2);
        blurColor += getSpokeColor(offsetUV, wheelCenter, rotation / ROT_ACC_FACT, wheelRadius);
    }
    vec4 color = blurColor / float(SAMPLES); // Try dividing samples by 2
#else
    vec4 color = getSpokeColor(uv, wheelCenter, rotation, wheelRadius);
#endif
    fragColor = color;
}


// P.S The tetris-like effect this fairly acutely produces goes freaking hard. 
// If you make sure the spokes never become wide enough to remove all spacing, it will produce a better effect sooner.