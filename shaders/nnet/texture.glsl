#ifndef texture_h
#define texture_h

vec2 wrap(in vec2 p, in vec2 res) {
    if (p.x > res.x) p.x = mod(p.x, res.x);
    else if (p.x < 0.) p.x = res.x + p.x;
    
    if (p.y > res.y) p.y = mod(p.y, res.y);
    else if (p.y < 0.) p.y = res.y + p.y;
    
    return p;
}

#define RN_BANKS 4
vec4 get_texture_bank(in sampler2D C, in ivec2 bank, in vec2 rel_pos, in vec2 reso){
    // Divide the texture into an X/Y grid of banks and return 
    // the value of the texture at the given relative position in 
    // the given bank.
    //
    // This is useful to use one texture as a 2D array of texture buffers.
    bank = ivec2(bank.x % RN_BANKS, bank.y % RN_BANKS);
    vec2 bank_size = reso / float(RN_BANKS);
    vec2 actual_pos = vec2(bank) * bank_size + mod(rel_pos, bank_size);
    
    return texelFetch(C, ivec2(actual_pos), 0);
}

#endif