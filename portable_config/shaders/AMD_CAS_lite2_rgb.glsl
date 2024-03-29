// LICENSE
// =======
// Copyright (c) 2017-2019 Advanced Micro Devices, Inc. All rights reserved.
// -------
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// -------
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
// -------
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

//Initial port to ReShade: SLSNe	https://gist.github.com/SLSNe/bbaf2d77db0b2a2a0755df581b3cf00c

//Optimizations by Marty McFly:
//	vectorized math, even with scalar gcn hardware this should work
//	out the same, order of operations has not changed
//	For some reason, it went from 64 to 48 instructions, a lot of MOV gone
//	Also modified the way the final window is calculated
//
//	reordered min() and max() operations, from 11 down to 9 registers
//
//	restructured final weighting, 49 -> 48 instructions
//
//	delayed RCP to replace SQRT with RSQRT
//
//	removed the saturate() from the control var as it is clamped
//	by UI manager already, 48 -> 47 instructions
//
//	replaced tex2D with tex2Doffset intrinsic (address offset by immediate integer)
//	47 -> 43 instructions
//	9 -> 8 registers

//Further modified by OopyDoopy and Lord of Lunacy:
//	Changed wording in the UI for the existing variable and added a new variable and relevant code to adjust sharpening strength.

//Fix by Lord of Lunacy:
//	Made the shader use a linear colorspace rather than sRGB, as recommended by the original AMD documentation from FidelityFX.

//Modified by CeeJay.dk:
//	Included a label and tooltip description. I followed AMDs official naming guidelines for FidelityFX.
//
//	Used gather trick to reduce the number of texture operations by one (9 -> 8). It's now 42 -> 51 instructions but still faster
//	because of the texture operation that was optimized away.

//Fix by CeeJay.dk
//	Fixed precision issues with the gather at super high resolutions
//	Also tried to refactor the samples so more work can be done while they are being sampled, but it's not so easy and the gains
//	I'm seeing are so small they might be statistical noise. So it MIGHT be faster - no promises.

//Modified by agyild (JPulowski) for mpv port
// Source version: https://github.com/CeeJayDK/SweetFX/blob/4f1692abdc49fbd582b6ac88dff1833beae2eb38/Shaders/CAS.fx
// Added back clamp mechanism to Saturation since it is no longer clamped by ReShade UI
// Changed lerp to mix
// Changed rsqrt to inversesqrt
// Changed rcp(x) to "1.0 / x"
// Changed saturate(x) to clamp(x, 0.0, 1.0)
// Reimplemented linear colorspace processing as an in-shader operation
// Removed gather performance trick because unlike in ReShade, mpv has transparent content with alpha channels, and the gather trick cannot be adapted to capture the alpha channel wihout making an additional texture lookup which makes the whole trick pointless
// Fragments marked as transparent by their alpha channel is no longer processed as a potential performance gain
// Reverted y-coordinate multiplication since mpv uses DX-like coordinate system
// Changed hooked texture to OUTPUT from SCALED, since apparently the gamma curve is applied at this stage

// Shader code
// Relinearization pass

//!HOOK OUTPUT
//!BIND HOOKED
//!DESC [AMD_CAS_lite2_rgb] Relinearization Pass

vec3 srgb_to_linear(vec3 col) {
	return mix(col * 1.0 / 12.92,  pow((col + 0.055) / 1.055, vec3(2.4)), ivec3(lessThan(vec3(0.04045), col)));
}

vec4 hook()
{
	vec4 col = HOOKED_tex(HOOKED_pos);
	return vec4(srgb_to_linear(col.rgb), col.a);
}

// CAS

//!HOOK OUTPUT
//!BIND HOOKED
//!DESC [AMD_CAS_lite2_rgb] Sharpening + Delinearization Pass

// User variables
#define SHARPENING 1.0 // Sharpening intensity: Adjusts sharpening intensity by averaging the original pixels to the sharpened result.  1.0 is the unmodified default. 0.0 to 1.0.
#define CONTRAST 0.0 // Adjusts the range the shader adapts to high contrast (0 is not all the way off).  Higher values = more high contrast sharpening. 0.0 to 1.0.

vec3 linear_to_srgb(vec3 col) {
	return mix(col * 12.92, 1.055 * pow(col, vec3(1.0 / 2.4)) - 0.055, ivec3(lessThanEqual(vec3(0.0031308), col)));
}

vec4 hook()
{
	// fetch a 3x3 neighborhood around the pixel 'e',
	//  a b c
	//  d(e)f
	//  g h i
	vec4 e = HOOKED_tex(HOOKED_pos);

	// If the current fragment is transparent, skip further processing
	if (e.a == 0.0)
		return vec4(linear_to_srgb(e.rgb), e.a);

	vec3 a = HOOKED_texOff(vec2(-1.0, -1.0)).rgb;
	vec3 b = HOOKED_texOff(vec2( 0.0, -1.0)).rgb;
	vec3 c = HOOKED_texOff(vec2( 1.0, -1.0)).rgb;
	vec3 f = HOOKED_texOff(vec2( 1.0,  0.0)).rgb;
	vec3 g = HOOKED_texOff(vec2(-1.0,  1.0)).rgb;
	vec3 h = HOOKED_texOff(vec2( 0.0,  1.0)).rgb;
	vec3 d = HOOKED_texOff(vec2(-1.0,  0.0)).rgb;
	vec3 i = HOOKED_texOff(vec2( 1.0,  1.0)).rgb;

	// Soft min and max.
	//  a b c			b
	//  d e f * 0.5	+ d e f * 0.5
	//  g h i			h
	// These are 2.0x bigger (factored out the extra multiply).
	vec3 mnRGB = min(min(min(d, e.rgb), min(f, b)), h);
	vec3 mnRGB2 = min(mnRGB, min(min(a, c), min(g, i)));
	mnRGB += mnRGB2;

	vec3 mxRGB = max(max(max(d, e.rgb), max(f, b)), h);
	vec3 mxRGB2 = max(mxRGB, max(max(a, c), max(g, i)));
	mxRGB += mxRGB2;

	// Smooth minimum distance to signal limit divided by smooth max.
	vec3 rcpMRGB = 1.0 / mxRGB;
	vec3 ampRGB = clamp(min(mnRGB, 2.0 - mxRGB) * rcpMRGB, 0.0, 1.0);

	// Shaping amount of sharpening.
	ampRGB = inversesqrt(ampRGB);

	float peak = -3.0 * clamp(CONTRAST, 0.0, 1.0) + 8.0;
	vec3 wRGB = -(1.0 / (ampRGB * peak));

	vec3 rcpWeightRGB = 1.0 / (4.0 * wRGB + 1.0);

	//						0 w 0
	//  Filter shape:		w 1 w
	//						0 w 0
	vec3 window = (b + d) + (f + h);
	vec3 outColor = clamp((window * wRGB + e.rgb) * rcpWeightRGB, 0.0, 1.0);

	// Delinearize
	return vec4(linear_to_srgb(mix(e.rgb, outColor, SHARPENING)), e.a);
}