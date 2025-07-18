// 文档 https://github.com/hooke007/MPV_lazy/wiki/4_GLSL

/* vi: ft=c
 *
 * Copyright (c) 2022 an3223 <ethanr2048@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify it 
 * under the terms of the GNU Lesser General Public License as published by 
 * the Free Software Foundation, either version 2.1 of the License, or (at 
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

// Description: guided_fast.glsl: Fast.

/* The radius can be adjusted with the MEANI stage's downscaling factor. 
 * Higher numbers give a bigger radius.
 *
 * The E variable can be found in the A stage.
 *
 * The subsampling (fast guided filter) can be adjusted with the I stage's 
 * downscaling factor. Higher numbers are faster.
 *
 * The guide's subsampling can be adjusted with the PREI stage's downscaling 
 * factor. Higher numbers downscale more.
 */

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!BIND HOOKED
//!WIDTH HOOKED.w 2 /
//!HEIGHT HOOKED.h 2 /
//!DESC [guided_fast] (I)
//!SAVE I

vec4 hook()
{
	return HOOKED_texOff(0);
}


//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (P)
//!BIND HOOKED
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE P

vec4 hook()
{
	return HOOKED_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (MEANI)
//!BIND I
//!SAVE MEANI
//!WIDTH I.w 1.5 /
//!HEIGHT I.h 1.5 /

vec4 hook()
{
	return I_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (MEANP)
//!BIND P
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANP

vec4 hook()
{
	return P_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (I_SQ)
//!BIND I
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE I_SQ

vec4 hook()
{
	return I_texOff(0) * I_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (IXP)
//!BIND I
//!BIND P
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE IXP

vec4 hook()
{
	return I_texOff(0) * P_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (CORRI)
//!BIND I_SQ
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE CORRI

vec4 hook()
{
	return I_SQ_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (CORRP)
//!BIND IXP
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE CORRP

vec4 hook()
{
	return IXP_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (A)
//!BIND MEANI
//!BIND MEANP
//!BIND CORRI
//!BIND CORRP
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE A

#define E 0.0013

vec4 hook()
{
	vec4 var = CORRI_texOff(0) - MEANI_texOff(0) * MEANI_texOff(0);
	vec4 cov = CORRP_texOff(0) - MEANI_texOff(0) * MEANP_texOff(0);
	return cov / (var + E);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (B)
//!BIND A
//!BIND MEANI
//!BIND MEANP
//!WIDTH I.w
//!HEIGHT I.h
//!SAVE B

vec4 hook()
{
	return MEANP_texOff(0) - A_texOff(0) * MEANI_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (MEANA)
//!BIND A
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANA

vec4 hook()
{
	return A_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast] (MEANB)
//!BIND B
//!WIDTH MEANI.w
//!HEIGHT MEANI.h
//!SAVE MEANB

vec4 hook()
{
	return B_texOff(0);
}

//!HOOK LUMA
//!HOOK CHROMA
//!HOOK RGB
//!DESC [guided_fast]
//!BIND HOOKED
//!BIND MEANA
//!BIND MEANB

vec4 hook()
{
	return MEANA_texOff(0) * HOOKED_texOff(0) + MEANB_texOff(0);
}

