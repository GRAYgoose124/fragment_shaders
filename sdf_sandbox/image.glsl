vec2 mul(vec2 v, float s) {
    return vec2(v.x * s, v.y * s);
}

vec2 mul(float s, vec2 v) {
    return vec2(v.x * s, v.y * s);
}

float mag(vec2 v) {
    return v.x * v.x + v.y * v.y;
}

vec3 sdCircle(vec2 pos, vec2 cen, float r) {
    vec2 dist = abs(cen - pos);
    float d = sqrt(dist.x * dist.x + dist.y * dist.y) ;
    
    if (d < r) {
        return vec3(1.);
    } else {
        return vec3(0.);
    }
}

vec3 sdLine(vec2 c, vec2 a, vec2 b, float w){
    float bax = b.x - a.x;
    float bay = b.y - a.y;
    float cay = c.y - a.y;
    float cax = c.x - a.x;
    float A = bax * cay;
    float B = bay * cax;
    float C = sqrt(pow(bax, 2.) + pow(bay, 2.));
    float d = abs(A - B) / C;
 
    if (d < w){
        #ifdef DEBUG
        vec3 sum = vec3(0.);
        if(dot(c, c) <= dot(b, b))
            sum += vec3(1., 0., 1.);
        if(dot(a, a) <= dot(c, c))
            sum += vec3(0, 1., 0.);
        sum += vec3(0., 0., 1.);
        return sum;
        #else
        if(dot(c, c) <= dot(b, b) && dot(a, a) <= dot(c, c))
            return vec3(1.);    
        #endif
    } else {
        return vec3(0.);
    }
}

vec3 sdBox(vec2 p, vec2 a, vec2 b){
    if ((a.x < p.x && p.x < b.x && a.y < p.y && p.y < b.y)) 
         return vec3(1.);
    else return vec3(0.);
}
// vec2 gradient() {}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;
    vec2 pos = fragCoord;
    
    vec3 col = vec3(0.);
    
    vec2 a, b;
    a = vec2(250.) + (vec2(15.)  * (vec2(cos(iTime), cos(iTime)-sin(iTime)) ));
    b = vec2(300.) + (vec2(200.) * (vec2(cos(iTime), cos(iTime)*sin(iTime)) ));
    
    for (int i=1; i<100;i++) {
        col += sdLine(pos, a+vec2(i, 0.), b+vec2(0., i), 25.) * uv.xyx;
    }
    
    col += sdLine(pos, vec2(700., 200.), vec2(750., 250.), 1.) * vec3(0., 1., 0.);
    col += sdBox(pos, vec2(700., 200.), vec2(750., 250.)) * vec3(1., 0., 0.);
    col += sdCircle(pos, vec2(700., 200.), 50.) * vec3(0., 0., 1.);

    
    // Output to screen
    fragColor = vec4(col,1.0);
}
