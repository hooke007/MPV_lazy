// 文档 https://github.com/hooke007/MPV_lazy/wiki/4_GLSL


//!PARAM SHARP
//!TYPE float
//!MINIMUM -10.0
//!MAXIMUM 10.0
1.0

//!DESC [unsharp_masking_RT]
//!HOOK SCALED
//!BIND HOOKED
//!WHEN SHARP 0.0 = !

vec4 hook()
{
    const float st1 = 1.2;
    vec4 p = HOOKED_tex(HOOKED_pos);
    vec4 sum1 = HOOKED_texOff(st1 * vec2(+1, +1))
              + HOOKED_texOff(st1 * vec2(+1, -1))
              + HOOKED_texOff(st1 * vec2(-1, +1))
              + HOOKED_texOff(st1 * vec2(-1, -1));
    const float st2 = 1.5;
    vec4 sum2 = HOOKED_texOff(st2 * vec2(+1,  0))
              + HOOKED_texOff(st2 * vec2( 0, +1))
              + HOOKED_texOff(st2 * vec2(-1,  0))
              + HOOKED_texOff(st2 * vec2( 0, -1));
    vec4 t = p * 0.859375 + sum2 * -0.1171875 + sum1 * -0.09765625;
    return p + t * SHARP;
}

