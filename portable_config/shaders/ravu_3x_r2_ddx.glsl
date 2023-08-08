// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

//!DESC RAVU-3x (luma, r2)
//!HOOK LUMA
//!BIND HOOKED
//!BIND ravu_3x_lut2
//!WIDTH 3 HOOKED.w *
//!HEIGHT 3 HOOKED.h *
//!WHEN HOOKED.w OUTPUT.w / 0.454545 < HOOKED.h OUTPUT.h / 0.454545 < *
//!COMPUTE 96 24 32 8
shared float inp[340];
void hook() {
ivec2 group_base = ivec2(gl_WorkGroupID) * ivec2(gl_WorkGroupSize);
int local_pos = int(gl_LocalInvocationID.x) * 10 + int(gl_LocalInvocationID.y);
for (int id = int(gl_LocalInvocationIndex); id < 340; id += int(gl_WorkGroupSize.x * gl_WorkGroupSize.y)) {
int x = id / 10, y = id % 10;
inp[id] = HOOKED_tex(HOOKED_pt * vec2(float(group_base.x+x)+(-0.5), float(group_base.y+y)+(-0.5))).x;
}
groupMemoryBarrier();
barrier();
float luma0 = inp[local_pos + 0];
float luma1 = inp[local_pos + 1];
float luma2 = inp[local_pos + 2];
float luma3 = inp[local_pos + 10];
float luma4 = inp[local_pos + 11];
float luma5 = inp[local_pos + 12];
float luma6 = inp[local_pos + 20];
float luma7 = inp[local_pos + 21];
float luma8 = inp[local_pos + 22];
vec3 abd = vec3(0.0);
float gx, gy;
gx = (luma3-luma0);
gy = (luma1-luma0);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
gx = (luma4-luma1);
gy = (luma2-luma0)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
gx = (luma5-luma2);
gy = (luma2-luma1);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
gx = (luma6-luma0)/2.0;
gy = (luma4-luma3);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
gx = (luma7-luma1)/2.0;
gy = (luma5-luma3)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.13080118386382833;
gx = (luma8-luma2)/2.0;
gy = (luma5-luma4);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
gx = (luma6-luma3);
gy = (luma7-luma6);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
gx = (luma7-luma4);
gy = (luma8-luma6)/2.0;
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.11543163961422666;
gx = (luma8-luma5);
gy = (luma8-luma7);
abd += vec3(gx * gx, gx * gy, gy * gy) * 0.1018680644198163;
float a = abd.x, b = abd.y, d = abd.z;
float T = a + d, D = a * d - b * b;
float delta = sqrt(max(T * T / 4.0 - D, 0.0));
float L1 = T / 2.0 + delta, L2 = T / 2.0 - delta;
float sqrtL1 = sqrt(L1), sqrtL2 = sqrt(L2);
float theta = mix(mod(atan(L1 - a, b) + 3.141592653589793, 3.141592653589793), 0.0, abs(b) < 1.192092896e-7);
float lambda = sqrtL1;
float mu = mix((sqrtL1 - sqrtL2) / (sqrtL1 + sqrtL2), 0.0, sqrtL1 + sqrtL2 < 1.192092896e-7);
float angle = floor(theta * 24.0 / 3.141592653589793);
float strength = mix(mix(0.0, 1.0, lambda >= 0.005), 2.0, lambda >= 0.02);
float coherence = mix(mix(0.0, 1.0, mu >= 0.25), 2.0, mu >= 0.5);
float coord_y = ((angle * 3.0 + strength) * 3.0 + coherence + 0.5) / 216.0;
vec4 res0 = vec4(0.0), res1 = vec4(0.0);
vec4 w0, w1;
w0 = texture(ravu_3x_lut2, vec2(0.05, coord_y));
w1 = texture(ravu_3x_lut2, vec2(0.15, coord_y));
res0 += luma0 * w0 + luma8 * w1.wzyx;
res1 += luma0 * w1 + luma8 * w0.wzyx;
w0 = texture(ravu_3x_lut2, vec2(0.25, coord_y));
w1 = texture(ravu_3x_lut2, vec2(0.35, coord_y));
res0 += luma1 * w0 + luma7 * w1.wzyx;
res1 += luma1 * w1 + luma7 * w0.wzyx;
w0 = texture(ravu_3x_lut2, vec2(0.45, coord_y));
w1 = texture(ravu_3x_lut2, vec2(0.55, coord_y));
res0 += luma2 * w0 + luma6 * w1.wzyx;
res1 += luma2 * w1 + luma6 * w0.wzyx;
w0 = texture(ravu_3x_lut2, vec2(0.65, coord_y));
w1 = texture(ravu_3x_lut2, vec2(0.75, coord_y));
res0 += luma3 * w0 + luma5 * w1.wzyx;
res1 += luma3 * w1 + luma5 * w0.wzyx;
w0 = texture(ravu_3x_lut2, vec2(0.85, coord_y));
w1 = texture(ravu_3x_lut2, vec2(0.95, coord_y));
res0 += luma4 * w0;
res1 += luma4 * w1;
res0 = clamp(res0, 0.0, 1.0);
res1 = clamp(res1, 0.0, 1.0);
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(0, 0), vec4(res0[0], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(0, 1), vec4(res0[1], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(0, 2), vec4(res0[2], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(1, 0), vec4(res0[3], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(1, 1), vec4(luma4, 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(1, 2), vec4(res1[0], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(2, 0), vec4(res1[1], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(2, 1), vec4(res1[2], 0.0, 0.0, 0.0));
imageStore(out_image, ivec2(gl_GlobalInvocationID) * 3 + ivec2(2, 2), vec4(res1[3], 0.0, 0.0, 0.0));
}
//!TEXTURE ravu_3x_lut2
//!SIZE 10 216
//!FORMAT rgba16hf
//!FILTER NEAREST
24303b2aea26e7296718e6253f0ade9aba31c932b6312d2a262a4526502146264d276f2a33307a1a022a4399ec110226fa310b2b83270a339f22ed31e92a4c2774368d3876369438943876368d3874363e2f5426371f992572a31c0f8ba52ea82f32fa331d32d729cb29ea2683251f2705247928fe2f36a1e426ada7caa4231b90332d2d892a9934d1275133c82ce62959366f3866368a388a3866366f3859366d2dad9e9aa3d218d4a65ea572aba7aa6d32703441325e293029f7298d2d042a902353269a2fa4a5de1fcca9a7aae6a21b34262e082df234942b5733842c162b80367e389936b438b43899367e388036682eeb259c9cca1f4c9a6ca878a779a56232c2333d32d920592058a51ba6f5a4731c6328352f82982c20d6a6a3a85ea967334b286ca45634a2aaf7328d259fa69638e039a138053a053aa138e03996388e2c5720c8a4d59f4aa077a936a787a671325a3323321825d024ea9eaea4199cf6206829f22e01a01b9e57aaf4aa64ac8c34552dc3249f3494ab56331c2884a67538a3398e38173a173a8e38a3397538b826b1a808ac7fa463a5c9a808a827a802330134b332ea28be28842754262f284a1c8f28982e2ba5e1a382ad93adf7ad6e35cb30f62db834cca6b632632645a63b385c395638d839d83956385c393b382e317c30fa2fd9a26d2150af9cb074b0bc300631442fad94760aa323d4268325b23059313b326725c8a4dbb012b1b9af7534822db71ffa34b3aecd321925eba843388e39b6385b3a5b3ab6388e394338c32de62c0a2e6b8c159c30acc2ad0dafdf30d030462e869ee820702a372c822c49304130e130201e829d39b002af57ad863672334230903436af0c2e2eaaafac9336b0388e38a03aa03a8e38b038933603b17db29bb0ec26be2726a3efadafad38317131a31840ab27aa882de0322c32fe348e35393769275e24cdaee1b042b0db38cb35fe3343342eac0db008b43ab34b35db38d038663a663ad038db384b35512f3e297d24c228749a0322db9e20a1d1318b32a731e52803294524b5161125aa26982a1e305704e72810a0fe9f7c206932e52a99250d33319fee31dc298c240f37ee383137183918393137ee380f37dc2d42261e1ddb24c09e48110fa33fa4da31b2325d318c277d27801ea31ddc225828df2b5830c29845266ba569a5bea01a34f62dad296034b38ccb32c72bcb25ce36a4383037123912393037a438ce36e22cc31ab4a445201ca5ac19daa417a660318c32e830be268426498f2224481f222af62ce2306aa12425bea974a96ca52135a231c42f0e3579298a33722eba2bd635bb375f36bc38bc385f36bb37d6358f2d4c236da2a71d879d05a71da5d5a39e328c3325327c240924d2a695a85fa5cc1f6229aa2fa599bb1e06a7dea80baadb33542a27a33f34d1abbe329b25fea78b38d839af38123a123aaf38d8398b38372954a4f3a88aa0c39fd9a53a9f299dbf324e33d6314d254c24dfa357a6b59f90274a2c5730f69d069cc0ab78ac7fad18353a2fe528973402ac3332031597aa6738ac39b3381e3a1e3ab338ac3967386fa492acbfad6ea2bda24e1faf24bd24e8326d33c6311e2616255ca40da5cd9de62ac82d1c3130a1f09cc3ad48ae18af7b366e320030cd348ba8793110a310ac08384b396e38dc39dc396e384b3908381730862fcd2e06a1481c4cad3daf9baf3d314530942c1b9d39200a8c3928392a5b306731723220275aa6a8b072b16eb05d350930401c033533af75322c26d3a7873760391539623a623a153960398737ae28b429e62ce71ce2a1f2a862acb8ad21315b2ee022eda416253529212d392e0b30fb300832da23daa0e6ae3cae2fad7438ab3597318134bbaff0a962b0c7aec43487388c39b73ab73a8c398738c43444ae71ac97a3651c6a963110e3a821acca30fc29a0acb2a26620c62c582f5e30f53258340735ce1ddd9f3eb029af0eaef239c23798340c3462ae6bb0b4b279b1da3119387439ce3ace3a74391938da31fb2eb8288423d3284f9b8823519df1a0f731a632aa311b293c290924e5175c25e226b32a3630191512290e9d0a9feb208032132bac25fb32289dc531ac297c24fa36e9382e370d390d392e37e938fa36722def245a132d25bc9f1d1ed29f1ea2f03195322531cc27f327bc1b041c47237029d52cf0308e13ba27dea41da646a23a34122e162941346d9d2732ba293a21c236b3386237133913396237b338c236282cf499dca5e31c24a68a1466a41aa5d231b432db3069287f2755956624491fc02a862d8131619d5d280ea941a99ca35b35c831952ef1348b2814334b2d6428bf35c237a336a938a938a336c237bf35f42c331fc0a4f21dbe9f75a550a340a2f932b1332d323d2575241ca85ca9a1a5511b3f29c72f5e9a2c20bea576a8e3a90834902a82a43834eeab973201253ba88038db39bc380f3a0f3abc38db39803812269aa7e5a992a0439f4ca3b10a2e0a34337633b931be258c23d2a64aa85ca26427902c9f30b39c2588d2aa3cac52ad3f35422fe926873440acd131c79f6eab6238c039de38233a233ade38c039623873a805ad9fad3ca404a2ef1b64245724c233c033aa310027a12416a7f6a607a095298b2d2a3108a05498b3ac93ad99aebf366832a82ec034fea9de3003a826ad04386c39ba38f139f139ba386c390438f72c322c342c06a0031624a95aac37ad863227311a2d0b9e6321f4a67524292aa02e9b3009323d281ca7c0aec6b064b0be350230d6a6f7342bafbe3180228ea73c377c396f39613a613a6f397c393c374a98f022802a621de8a10aa231a9f9aa9b31782d36a2caa65e2647212d2c612daf2fb5315433042673a4a0ae83af02af5d38e1340e2cf73415b0272163ad59aaac34c138183a8e3a8e3a183ac138ac3466ae12ac3c9ea41feb9cec1e56a661a9ba320c2d78abcea666247f26ff2df72f8c2f67324a34ad23a6a1f8ad7dafffaf6a392736d930313432afffabadb0fcaef133c338263ad43ad43a263ac338f133be2e91286f23e028289c4624719cfea02832bc32b531632964297223a38c57259a26972a30302d181d29aa97369cf9218532ed2a4b25e132869d9b314a292d24f036ed3838370b390b393837ed38f036bb2ccf2177956525c9a0b31f35a239a46032e132343179285b28b212ee1ac623af290f2d3031d31a002920a2d3a20f8455342f2e22281e3459a0b2311f2987207836a4388537063906398537a4387836812ac1a276a7d0967fa6149d2fa51ca5fc31dc322031402a6b2733a0c41f771d632ca92ecc311d9ceb29a6a594a5149db0359d31162df3344a29be32e72c60274435a337ed3674387438ed36a3374435702cb91896a5f51da4a07ba4d5a1cea15d33e2333832ee259f24d0a802aad9a5189bbb28c22ff59b3e211aa4b6a794a91c346e2abca53034d1ab7232a62424a87538e039c9380a3a0a3ac938e039753817227aa8c5a92e9f649e30a0c419cc10a33397338f311c26e021c1a843a930a4c326a22cd130b098c51d4ca987abdaac4b35d62e0f2165346eac72310ca2a4ab5938d2390539273a273a0539d239593805a99eacadace5a493a047896e238e233c34f733793103288123bda87da88ea286270c2d23312a9e191a23abc0ace5ad9d36aa312e2caa342cabb6300aa801ad00388d39fa38ff39ff39fa388d390038252a9f278b28cf9c760820a57ba967ab08343a322c2e9aa234242eacb2a02d28c82b7f2fd831fa2877a78caa90af1cb01636053038aae43413afce30d39d94a82037a439b8395d3a5d3ab839a439203740a9c9a65b22b417619e5f2296a48ba86d326a2e4c2099a8c7263aa84229622c612e8a315d330829b0a64aac9aafefaf8f38b734f022273540b0802657ad9eaa0b351b39603a7d3a7d3a603a1b390b351fad52ab2da45c1fa49e372221a3dfa6e132a62e74a0d5a83527c5a2832ca62eb42ce73075335e244aa060abcdae2db0ee382f35d12c9e345fb069a68fb03baf7b355a39683ac93ac93a683a5a397b35812e8428c123c428879b5324069cf7a04e32c532a73197294e29da22c4972525be25452a3830f1167d29d610239890238f32bc2abc24e532049ca7319129c424e236ed383537003900393537ed38e236842c07246218f325fd9f3821109ecaa1bc32db321031c528a6288917f117fe235429652d8d31282174297ba1c6a482974934b42d21260434e3a05d314e28d51c7036af389337ef38ef389337af387036f52876a420a6739e17a6269f27a58fa453339c332c31a42b1028719b461b0010e42aa72e0d327721642b47a329a0d71e13351230792990347325e1315e2a1520d33530388b37833883388b373038d3350a2cf10dcfa5861da6a11ea456a16aa2bd3307344332b326da2447a987aaf8a52aa21128c62ff99d6623cda01ba6e5a82434e82969a7273499ab5832a324a5a76b38e639d338033a033ad338e6396b382e1f8da775a8a199099ec4998d18a5981434b93367317e261b202caa62aa6ea56b244f2ce430b8929223d8a600aaf6ab2e35ad2d05a333347dac233126a1f9aa4d38e5392739273a273a2739e5394d3825a80eab58aafda4819b3b99a22237238f3411344031c12839203caa5baaaca655226e2c2231d89d2c22a0a847abc7ac1a363f30392385341aacbc302ca652ac1038bc393439063a063a3439bc391038dc2892205d1ff2184b9859a1c8a570a85834ac32892ecba4fe2425ad26a5c72525271c2edc31382907a622985dad49af26361f2fd1abb63499aed52fdea577a92337cb39e239533a533ae239cb392337dfa9bba84b99639c18971b2259a0d0a58232cd2e85287daa462822aa6e28c42b0b2e6e31e032432ca3a9c6a82bb0a3b075384734cfa3533541b081281daea2acee358c39723a683a683a723a8c39ee350bab1faa54a4749d7a19fc23cc1caa9e5432bf2f51292ba80827e8a98c270f2c3d2c42307832292689a046a87fad0faf6b382d34c41c0d3509b11024cbb063b0e036e139893aac3aac3a893ae139e0364d2e7428ad239628bf9c1a24659c44a17a32da32a331f5297c29bd22899936254a25432a51309d18eb29671cb211702492324e2a5e23df32ad9c9a316029bc24d636f0383737f738f7383737f038d636c62b0923cf1a81245d9eac1f889d12a29e336e333e31862a1e288699ada03221db24eb2b5931dd14e62a5e1d7d992a2217343b2c491cbb33f0a14431fb274e1e9036e638cb37f738f738cb37e63890364228cfa242a49ba028a51ba195a454a32a340b341331f82c14295d1f6223491bb826652d5c32fb1c9c2a76a2a2a64194f5346d2f38267e3413245931a1293121f4355d38bc3778387838bc375d38f435b92bbf174fa5771c86a26fa4fba1eba3003411344532db271b250da9b7aaeca575a5a726c82f36a14a250a9e5fa4b7a71934f62871a81a341fab4b32102586a66538ed39d538f939f939d538ed396538fd1d08a350a4bb99369d549c77967c9d7b34cb331e319f281c1bcbaaa0ab8ea7629dee2af53029a0322853a204a7a4a8e834c72b1da907344dac0531649a51a93438fa393d39133a133a3d39fa3934386ea483a714a573a4cd1ca89c78210a23d0340534b330f429479d16ab1fac69a998a02d2b3f315aa0e02742a3dea7baa96535392d66a83a347fac8d30aea456ab2738f23967390a3a0a3a6739f2392738eb28731e3d9f92204714aa9ced9251a2bc34f632aa2e10a4962584ad4da7cf20e8a2752c3932c027df9cb928fba9e3adaa35712a0dad2b3480acb82e28a1caa62e37f639e1392b3a2b3ae139f6392e375ba553a51a9ba2a1c81a131cd819149c39334830492c17a9282625ac77118925d22a46303132732bbfa8bfa044af4fb0b037ba31adaa1b3591af1b2c81ade9ac4337283a693a683a683a693a283a43378ba8eda74b9cc0a448242020e2240f2499325630652a9e1c37a415ab01a834a0d22d933032324c2b619b81a17aac2aad28377231dda867346eb0442915b05cb00238563a863a973a973a863a563a02385f2ebc287b249b28759b3924149ceea09e32e3328e31582a5e298122d69ccb24ec244a2a7530301b9a2a7a200d1db0258232f229b721d9329d9a943170292d25b736e8382437e238e2382437e838b736ca2b1125d8214524ba9b1a20939c59a13d34d03300315c2c3028539ce5a0562147212e2bb931c48c0d2c6b24e4196223cf33842a28a267338ca0eb302628cf224736dd38da37cf38cf38da37dd38473604298f9d66a09ca003a544a381a51fa4e33456343931d42e222ba1258027ed2252176929883248a8192e249c8e249a271034182d0a1c0c34d422e430d228811de0356538b1374e384e38b1376538e035b92b791c6da4c917fca14da586a2eca319341a344b32f628112571a81eab83a6b5a74c25c92f5da4a926fa9d33a173a50034dc270da91134b6aa45321d25eaa56538f939d538ed39ed39d538f9396538fa1db4994e9cfda27f964aa4339d799de83407340431c72b709a1fa94dac50a9a4a83328f63001a7ef2a44a224a0619d7b349e28cdaaca33a0ab1d31121b8ea73438133a3d39fa39fa393d39133a343873a477a4a79c80a774210ba5d31c042365353a348b30392daca46aa87dac50abbca9de274031d8a7302b14a33ea087a0d034f82918ab04341facb030649d68a926380a3a6739f239f23967390a3a2638e7288520ee9c541e8e93839fe31338a2a9352b34ba2e702a1da10bad7eacbaa6e4ad119d363205aa712caf28b727c6a2bb340da480adf63244a7ad2e9e25e6202e372c3ae239f739f739e2392c3a2e374ea59aa1101c4ca5d2190e9bc21a0f9cb1371b351b2cbb3180adacaa90afe8ac50b0c1a8313245af4630c1a0732bd02a36331ba924ac4630a111482c2a2687254337683a693a283a283a693a683a43378ba8c0a42020eda7e2244a9c48241024283767344429723115b0dda86eb05cb02aad639b32327aac933081a14d2bd22d9932a11c15ab563001a8642a38a437a00238973a863a563a563a863a973a0238812ec42853248428069cc123879bf7a08f32e532a731bc2a9129bc24049cc42490237d2938302398452ad610f116be254e329729da22c532c497a7314e292525e23600393537ed38ed3835370039e236842cf32538210724109e6218fc9fcaa1493404345d31b42d4e282126e3a0d51c829774298d31c6a4652d7ba128215429bc32c5288917db32f1171031a628fe237036ef389337af38af389337ef387036f528739e269f76a427a520a617a68fa413359034e13112305e2a792973251520d71e642b0d3229a0a72e47a37621e42a5333a42b719b9c33461b2c3110280010d33583388b37303830388b378338d3350a2c861d1ea4f10d56a1cfa5a6a16aa2243427345832e829a32469a799aba5a7e5a86623c62f1ba61128cda0f99d2aa2bd33b32647a9073487aa4332da24f8a56b38033ad338e639e639d338033a6b382e1fa199c4998da78d1875a8099ea5982e3533342331ad2d26a105a37dacf9aaf6ab9223e43000aa4f2cd8a6b8926b2414347e262caab93362aa67311b206ea54d38273a2739e539e5392739273a4d3825a8fda43b990eaba22258aa819b37231a368534bc303f302ca639231aac52acc7ac2c22223147ab6e2ca0a8d89d55228f34c1283caa11345baa40313a20aca61038063a3439bc39bc393439063a1038dc28f21859a19220c8a55d1f4b9870a82636b634d52f1f2fdea5d1ab99ae77a949af07a6dc315dad1c2e2298382924275834cba425adac3226a5892efe24c7252337533ae239cb39cb39e239533a2337dfa9639c1b22bba859a04b991897d0a575385335812847341daecfa341b0a2aca3b0a3a9e0322bb06e31c6a8432c0b2e82327daa22aacd2e6e2885284628c42bee35683a723a8c398c39723a683aee350bab749dfc231faacc1c54a47a19aa9e6b380d3510242d34cbb0c41c09b163b00faf89a078327fad423046a829263d2c54322ba8e8a9bf2f8c27512908270f2ce036ac3a893ae139e139893aac3ae036be2edf2845249028769c6d232c9cfea08532e1329b31ee2a4b294c25819d2d24fa211f2930302b9c982a92973d189a26283262296d23bc32ac8db43163295725f0360b393837ed38ed3838370b39f036bb2c6525b41fcf2135a27695c9a039a455341e34b2312f2e1e29212859a087209a8300293031d2a20f2d1fa2d71aaf295f3279288012e132e31a34315a28c423783606398637a438a438863706397836802ad396159dc2a230a576a77fa61da5b035f334be329d31e72c162d4a296127179deb29cc3195a5a92ea6a51e9c622cfc31402a33a0dc32c51f20316b27781d44357438ed36a337a337ed3674384435702cf51d7ba4b918d5a196a5a4a0cea11c34303472326e2aa624bca5d1ab24a894a93e21c22fb6a7bb281aa4f59b189b5d33ee25d0a8e23302aa38329f24d9a575380a3ac938e039e039c9380a3a753817222e9f30a07aa8c419c5a9649ecc104b3565347231d62e0ca20f216eaca4abdaacc51dd13087aba22c4ca9b098c326a3331c26c1a8973343a98f31e02130a45938273a0539d239d2390539273a593805a9e5a447899eac6e23adac93a08e239d36aa34b630aa310aa82e2c2cab01ade5ad191a2331c0ac0c2d23ab2a9e86273c340328bda8f7337da8793181238ea20038ff39fa388d398d39fa38ff390038252acf9c20a59f277ba98b28750866ab1636e434ce300530d39d38aa13af94a81cb077a7d83190af7f2f8caafa28c82b08349aa22eac3a32b2a02c2e34242d2820375d3ab839a439a439b8395d3a203740a9b4175f22c9a696a45b22619e8ba88f3827358026b73457adf02240b09eaaefafb0a65d339aaf8a314aac0829612e6d3299a83aa86a2e42294c20c726622c0b357d3a603a1b391b39603a7d3a0b351fad5c1f372252ab21a32da4a49edfa6ee389e3469a62f358fb0d12c5fb03baf2db04aa07533cdaee73060ab5e24b42ce132d5a8c5a2a62e832c74a03527a62e7b35c93a683a5a395a39683ac93a7b35fb2ed4288b23b9284a9d8623439bf0a08032fb32c531132bac29ab252d9d7c24ea2010293530179fb22a169ded14e126f7311c290b24a6321218aa313d295d25fa360c392e37e938e9382e370c39fa36722d2d251e1eef24d19f5f13bb9f1ea23a3441342732122eba2916296b9d3b2148a2b927f0301ea6d42cdea473137029f031cd27c61b9532091c2531f4274a23c23613396237b338b33862371339c236282ce41c9314ef9965a4dba523a61aa55b35f1341433c8314b2d952e8b2864289ca35d28813140a9862d0ea9609dc12ad23169285b95b4326624db307e27471fbf35a938a336c237c237a336a938bf35f42cf21d75a5331f50a3c0a4be9f40a2083438349732902a012582a4eeab3ba8e3a92c20c72f76a83f29bea55e9a521bf9323d251ca8b1335ca92d327524a1a580380f3abc38db39db39bc380f3a8038122692a04ca39aa7b10ae5a9439f2e0a3f358734d131422fc79fe92640ac6eab52ad25889f303cac902cd2aab39c64273433be25d2a676334aa8b9318c235ca26238233ade38c039c039de38233a623873a83ca4ef1b05ad64249fad04a25724bf36c034de30683203a8a82efea926ad99ae54982a3193ad8b2db3ac08a09529c233002716a7c033f6a6aa31a12407a00438f139ba386c396c39ba38f1390438f72c06a024a9322c5aac342c031637adbe35f734be3102308022d6a62baf8ea764b01ca70932c6b09b30c0ae3d28a02e86320b9ef4a6273175241a2d6321292a3c37613a6f397c397c396f39613a3c374a98621d0aa2f02231a9802ae8a1f9aa5d38f7342721e13463ad0e2c15b059aa02af73a4543383afb531a0ae0426af2f9b31caa64721782d2d2c36a25e26612dac348e3a183ac138c138183a8e3aac3466aea41fec1e12ac56a63c9eeb9c61a96a393134ffab2736adb0d93032affcaeffafa6a14a347daf6732f8adad238c2fba32cea67f260c2dff2d78ab6624f72ff133d43a263ac338c338263ad43af133512fc22803223e29db9e7d24749a20a169320d33ee31e52adc299925319f8c247c20e7281e30fe9f982a10a05704aa26d131e52845248b32b516a731032911250f3718393137ee38ee38313718390f37dc2ddb24481142260fa31e1dc09e3fa41a346034cb32f62dc72bad29b48ccb25bea04526583069a5df2b6ba5c2985828da318c27801eb232a31d5d317d27dc22ce3612393037a438a43830371239ce36e22c4520ac19c31adaa4b4a41ca517a621350e358a33a231722ec42f7929ba2b6ca52425e23074a9f62cbea96aa1222a6031be26498f8c322224e8308426481fd635bc385f36bb37bb375f36bc38d6358f2da71d05a74c231da56da2879dd5a3db333f34be32542a9b2527a3d1abfea70baabb1eaa2fdea8622906a7a599cc1f9e327c24d2a68c3395a8253209245fa58b38123aaf38d839d839af38123a8b3837298aa0d9a554a43a9ff3a8c39f299d1835973433323a2f0315e52802ac98aa7fad069c573078ac4a2cc0abf69d9027bf324d25dfa34e3357a6d6314c24b59f67381e3ab338ac39ac39b3381e3a67386fa46ea24e1f92acaf24bfadbda2bd247b36cd3479316e3210a300308ba810ac18aff09c1c3148aec82dc3ad30a1e62ae8321e265ba46d330da5c6311625cd9d0838dc396e384b394b396e38dc390838173006a14cad862f3dafcd2e481c9baf5d350335753209302c26401c33afd3a76eb05aa6723272b16731a8b020275b303d311b9d0c8c45303928942c3920392a8737623a1539603960391539623a8737ae28e71cf2a8b42962ace62ce2a1b8ad74388134f0a9ab3562b09731bbafc7ae2faddaa008323caefb30e6aeda230b302131eda435295b2e212de0221625392ec434b73a8c39873887388c39b73ac43444ae651c311071ace3a897a36a9621acf2390c346bb0c237b4b2983462ae79b10eaedd9f073529af58343eb0ce1df532ca30b2a2c62cfc29582f9fac66205e30da31ce3a7439193819387439ce3ada317e2f7728341f5929bca05624149c28a263322a332e32982a252a03253da18c247e1d8528ed2f25a11a2ab2a12398a725b931ab281b248632f008ae31c928812443373039513703390339513730394337ac2e9924fd9e5a285ba481217a9fb4a4ee3371345e337a2d9f2c3729fc962a28d6a15925c32f4ba5442a93a5f49cc02597310127681f99327f16723105277920083724392c37b738b7382c3724390837972d7b1f42a24b2411a8f39eb6a475a8c33425354334f8301630132f082a9b2db5a6f3210b3023aac12a85aaeea3cc265c318e261e24a13286271d314526fa231036c5384136da37da374136c5381036582ee41e9ea8f825b8a77c9b26987aa573335934fb326e28ae259ca402abdaa6b2a9571f392fe1a88d2801a767941e1e5c326c205ca5b633f1a53232f31fe6a49a380c3aa638e139e139a6380c3a9a387c2c2ca08fa90221f6a613a42c9fc5a58e349f3452337a2d51287525a1abe5a590acc29e002f0eabd42927aa9a9e54235832d824e29f3733d9a405328b243e9d7038193a8a389c399c398a38193a70383a2875a06da4f0a69da09daa91a2fb9f9635db3455332e310b2ac12e6ea50b96a9ad6f9e00301cadc62be4ac16a2ee27fd3164250698f132159faa311625fc13f237bb391638173917391638bb39f2374931a5a261af9730abb01830982180b07b34fe34d632962d60254b20b2aecda8caafb3a4593221b17531e6b08125cc309830cd972b24df306927f22ec78de4253c38593ab03888398839b038593a3c38172e5d0a3eac3a2dbfad502e799bf6aea13692341b2ea633baa9683030af5aac3bad799df130ebae5a3032b05f1e67309830579f782a8d30222cde2dac20512c62369f3a82389b389b3882389f3a623633acd6190fa94ead92ab4fac841880ac6039ea3321b03237b3b2da3491ad47b237adbd94c6362fadde356faced1f2f358f2bbba1a82c1d27dc2e68aaef95b12fb933ba3a7538ba37ba377538ba3ab933ed2f85287e1d1a2a25a1a7252398b2a12e322a336332252a982a8c243da10325341f77287e2fbca0592928a2149c5624ae31c92881248632f008b931ab281b2451373039433703390339433730395137c32f5925d6a1442a4ba5c025f49c93a55e337134ee339f2c7a2d2a28fc963729fd9e9924ac2e5ba45a28b4a47a9f812172310527792099327f1697310127681f2c3724390837b738b738083724392c370b30f321b5a6c12a23aacc26eea385aa43342535c3341630f8309b2d082a132f42a27b1f972d11a84b2475a8b6a4f39e1d314526fa23a13286275c318e261e244136c5381036da37da371036c5384136392f571fb2a98d28e1a81e1e679401a7fb3259347333ae256e28daa602ab9ca49ea8e41e582eb8a7f8257aa526987c9b3232f31fe6a4b633f1a55c326c205ca5a6380c3a9a38e139e1399a380c3aa638002fc29e90acd4290eab54239a9e27aa52339f348e3451287a2de5a5a1ab75258fa92ca07c2cf6a60221c5a52c9f13a405328b243e9d3733d9a45832d824e29f8a38193a70389c399c397038193a8a3800306f9ea9adc62b1cadee2716a2e4ac5533db3496350b2a2e310a966ea5c12e6da475a03a289da0f0a6fb9f91a29daaaa311625fd13f132159ffc31642506981638bb39f23717391739f237bb3916385932b3a4caaf753121b1cc308125e6b0d632fe347b346025962dcda8b2ae4b2061afa5a24931abb0973080b098211830f22ec78de425df3069279830cd972b24b038593a3c38883988393c38593ab038f130799d3bad5a30ebae67305f1e32b01b2e9234a136baa9a6335aac30af68303eac5d0a172ebfad3a2df6ae799b502ede2dac20512c8d30222c9830579f782a82389f3a62369b389b3862369f3a8238c636bd9437adde352fad2f35ed1f6fac21b0ea336039b3b2323747b291adda340fa9d61933ac92ab4ead80ac84184fac68aaef95b12f1d27dc2e8f2bbba1a82c7538ba3ab933ba37ba37b933ba3a75381e30e7287c20982afe9faa26570410a0ee310d336932dc29e52a8c24319f99250322c228512fdb9e3e2920a1749a7d24a731032911258b32b516d131e5284524313718390f37ee38ee380f371839313758304526bea0df2b69a55828c2986ba5cb3260341a34c72bf62dcb25b38cad294811db24dc2d0fa342263fa4c09e1e1d5d317d27dc22b232a31dda318c27801e30371239ce36a438a438ce3612393037e23024256ca5f62c74a9222a6aa1bea98a330e352135722ea231ba2b7929c42fac194520e22cdaa4c31a17a61ca5b4a4e8308426481f8c3222246031be26498f5f36bc38d635bb37bb37d635bc385f36aa2fbb1e0baa6229dea8cc1fa59906a7be323f34db339b25542afea7d1ab27a305a7a71d8f2d1da54c23d5a3879d6da2253209245fa58c3395a89e327c24d2a6af38123a8b38d839d8398b38123aaf385730069c7fad4a2c78ac9027f69dc0ab33329734183503153a2f97aa02ace528d9a58aa037293a9f54a4299dc39ff3a8d6314c24b59f4e3357a6bf324d25dfa3b3381e3a6738ac39ac3967381e3ab3381c31f09c18afc82d48aee62a30a1c3ad7931cd347b3610a36e3210ac8ba800304e1f6ea26fa4af2492acbd24bda2bfadc6311625cd9d6d330da5e8321e265ca46e38dc3908384b394b390838dc396e3872325aa66eb0673172b15b302027a8b0753203355d352c260930d3a733af401c4cad06a117303daf862f9baf481ccd2e942c3920392a453039283d311b9d0a8c1539623a8737603960398737623a15390832daa02fadfb303cae0b30da23e6aef0a98134743862b0ab35c7aebbaf9731f2a8e71cae2862acb429b8ade2a1e62ce0221625392e5b2e212d2131eda435298c39b73ac43487388738c434b73a8c390735dd9f0eae583429aff532ce1d3eb06bb00c34f239b4b2c23779b162ae98343110651c44aee3a871ac21ac6a9697a3a0ac66205e30fc29582fca30b2a2c62c7439ce3ada3119381938da31ce3a743936301229eb20b32a0a9fe22619150e9dc531fb328032ac29132b7c24289dac258823d328fb2e519db828f1a04f9b8423aa313c295c25a632e517f7311b2909242e370d39fa36e938e938fa360d392e37f030ba2746a2d52c1da670298e13dea4273241343a34ba29122e3a216d9d16291d1e2d25722dd29fef241ea2bc9f5a132531f32747239532041cf031cc27bc1b62371339c236b338b338c2361339623781315d289ca3862d41a9c02a619d0ea91433f1345b354b2dc83164288b28952e8a14e31c282c66a4f4991aa524a6dca5db307f27491fb4326624d23169285595a336a938bf35c237c237bf35a938a336c72f2c20e3a93f2976a8511b5e9abea59732383408340125902a3ba8eeab82a475a5f21df42c50a3331f40a2be9fc0a42d327524a1a5b1335ca9f9323d251ca8bc380f3a8038db39db3980380f3abc389f30258852ad902c3cac6427b39cd2aad13187343f35c79f422f6eab40ace9264ca392a01226b10a9aa72e0a439fe5a9b9318c235ca276334aa83433be25d2a6de38233a6238c039c0396238233ade382a31549899ae8b2d93ad952908a0b3acde30c034bf3603a8683226adfea9a82eef1b3ca473a8642405ad572404a29fadaa31a12407a0c033f6a6c233002716a7ba38f13904386c396c390438f139ba3809321ca764b09b30c6b0a02e3d28c0aebe31f734be35802202308ea72bafd6a624a906a0f72c5aac322c37ad0316342c1a2d6321292a2731752486320b9ef4a66f39613a3c377c397c393c37613a6f39543373a402afb53183afaf2f0426a0ae2721f7345d3863ade13459aa15b00e2c0aa2621d4a9831a9f022f9aae8a1802a36a25e26612d782d2d2c9b31caa64721183a8e3aac34c138c138ac348e3a183a4a34a6a1ffaf67327daf8c2fad23f8adffab31346a39adb02736fcae32afd930ec1ea41f66ae56a612ac61a9eb9c3c9e78ab6624f72f0c2dff2dba32cea67f26263ad43af133c338c338f133d43a263a30301d29f921972a369c9a262d18aa979b31e13285324a29ed2a2d24869d4b254624e028be2e719c9128fea0289c6f23b53164295725bc32a28c28326329722338370b39f036ed38ed38f0360b393837303100290f840f2dd3a2af29d31a20a2b2311e3455341f292f2e872059a02228b31f6525bb2c35a2cf2139a4c9a0779534315b28c623e132ee1a60327928b212853706397836a438a438783606398537cc31eb29149da92e94a5632c1d9ca6a5be32f334b035e72c9d3160274a29162d149dd096812a2fa5c1a21ca57fa676a720316b27771ddc32c41ffc31402a33a0ed3674384435a337a33744357438ed36c22f3e2194a9bb28b6a7189bf59b1aa4723230341c34a6246e2a24a8d1abbca57ba4f51d702cd5a1b918cea1a4a096a538329f24d9a5e23302aa5d33ee25d0a8c9380a3a7538e039e03975380a3ac938d130c51ddaaca22c87abc326b0984ca9723165344b350ca2d62ea4ab6eac0f2130a02e9f1722c4197aa8cc10649ec5a98f31e02130a4973343a9a3331c26c1a80539273a5938d239d2395938273a05392331191ae5ad0c2dc0ac86272a9e23abb630aa349d360aa8aa3101ad2cab2e2c4789e5a405a96e239eac8e2393a0adac793181238ea2f7337da83c340328bda8fa38ff3900388d398d390038ff39fa38d83177a71cb07f2f90afc82bfa288caace30e4341636d39d053094a813af38aa20a5cf9c252a7ba99f2767ab76088b282c2e34242d283a32b2a008349aa22eacb8395d3a2037a439a43920375d3ab8395d33b0a6efaf8a319aaf612e08294aac802627358f3857adb7349eaa40b0f0225f22b41740a996a4c9a68ba8619e5b224c20c726622c6a2e42296d3299a83aa8603a7d3a0b351b391b390b357d3a603a75334aa02db0e730cdaeb42c5e2460ab69a69e34ee388fb02f353baf5fb0d12c37225c1f1fad21a352abdfa6a49e2da474a03527a62ea62e832ce132d5a8c5a2683ac93a7b355a395a397b35c93a683a38307d299023452a2398be25f116d610a731e5328f329129bc2ac424049cbc245324c428812e069c8428f7a0869bc123a7314e292525c532c4974e329729da2235370039e236ed38ed38e236003935378d3174298297652dc6a4542928217ba15d31043449344e28b42dd51ce3a021263821f325842c109e0724caa1fd9f62181031a628fe23db32f117bc32c52889179337ef387036af38af387036ef3893370d32642bd71ea72e29a0e42a772147a3e131903413355e2a1230152073257929269f739ef52827a576a48fa417a620a62c31102800109c33461b5333a42b719b8b378338d33530383038d33583388b37c62f6623e5a811281ba62aa2f99dcda0583227342434a324e829a5a799ab69a71ea4861d0a2c56a1f10d6aa2a6a1cfa54332da24f8a5073487aabd33b32647a9d338033a6b38e639e6396b38033ad338e4309223f6ab4f2c00aa6b24b892d8a6233133342e3526a1ad2df9aa7dac05a3c499a1992e1f8d188da7a598099e75a867311b206ea5b93362aa14347e262caa2739273a4d38e539e5394d38273a273922312c22c7ac6e2c47ab5522d89da0a8bc3085341a362ca63f3052ac1aac39233b99fda425a8a2220eab3723819b58aa40313920aca611345baa8f34c1283caa3439063a1038bc39bc391038063a3439dc3107a649af1c2e5dad252738292298d52fb6342636dea51f2f77a999aed1ab59a1f218dc28c8a5922070a84b985d1f892efe24c725ac3226a55834cba425ade239533a2337cb39cb392337533ae239e032a3a9a3b06e312bb00b2e432cc6a88128533575381dae4734a2ac41b0cfa31b22639cdfa959a0bba8d0a518974b9985284628c42bcd2e6e2882327daa22aa723a683aee358c398c39ee35683a723a783289a00faf42307fad3d2c292646a810240d356b38cbb02d3463b009b1c41cfc23749d0babcc1c1faaaa9e7a1954a4512908270f2cbf2f8c2754322ba8e8a9893aac3ae036e139e139e036ac3a893a5130eb297024432ab2114a259d18671c9a31df32923260294e2abc24ad9c5e231a2496284d2e659c742844a1bf9cad23a3317c293625da3289997a32f529bd223737f738d636f038f038d636f73837375931e62a2a22eb2b7d99db24dd145e1d4431bb331734fb273b2c4e1ef0a1491cac1f8124c62b889d092312a25d9ecf1a3e311e2832216e33ada09e33862a8699cb37f7389036e638e6389036f738cb375c329c2a4194652da2a6b826fb1c76a259317e34f534a1296d2f3121132438261ba19ba0422895a4cfa254a328a542a413311429491b0b3462232a34f82c5d1fbc377838f4355d385d38f4357838bc37c82f4a25b7a7a7265fa475a536a10a9e4b321a3419341025f62886a61fab71a86fa4771cb92bfba1bf17eba386a24fa545321b25eca51134b7aa0034db270da9d538f9396538ed39ed396538f939d538f5303228a4a8ee2a04a7629d29a053a205310734e834649ac72b51a94dac1da9549cbb99fd1d779608a37c9d369d50a41e311c1b8ea7cb33a0ab7b349f28cbaa3d39133a3438fa39fa393438133a3d393f31e027baa92d2bdea798a05aa042a38d303a346535aea4392d56ab7fac66a8a89c73a46ea4782183a70a23cd1c14a5b330479d69a905341facd034f42916ab67390a3a2738f239f23927380a3a67393932df9ce3ad752cfba9e8a2c027b928b82e2b34aa3528a1712acaa680ac0dadaa9c9220eb28ec92731e51a247143d9faa2e9625cf20f6324da7bc3410a484ade1392b3a2e37f639f6392e372b3ae1393132bfa84fb0463044afd22a732bbfa01b2c1b35b03781adba31e9ac91afadaa131ca2a15ba5d81953a5149cc81a1a9b492c2826892548307711393317a925ac693a683a4337283a283a4337683a693a3232619b2aad93307aacd22d4c2b81a144296734283715b072315cb06eb0dda82020c0a48ba8e224eda70f2448244b9c652a37a434a0563001a899329e1c15ab863a973a0238563a563a0238973a863a75309a2ab0254a2a0d1dec24301b7a209431d93282327029f2292d259e9ab72139249b285f2e159cbc28eea0779b7b248e315d29cb24e332d69c9e32582a81222437e238b736e838e838b736e2382437b9310d2c62232e2be4194721c48c6b24eb306733cf332628842acf228ca028a21a204524ca2b939c112559a1ba9bd821003130285621d033e5a03d345c2c539cda37cf384736dd38dd384736cf38da378832192e9a2769298f24591749a8249ce4300c341034d128182d821dd3220a1c44a39ca0042980a5909d1fa403a566a03931232bec2256348127e334d42ea125b1374e38e03565386538e0354e38b137c92fa92673a54c2533a1b5a75da4fa9d4532113400341d25dc27eaa5b6aa0da94da5c917b92b86a2791ceca3fca16da44b32112583a61a341eab1934f62871a8d538ed396538f939f9396538ed39d538f630ef2a619d332824a0a4a801a744a21d31ca337b34121b9e288ea7a0abcdaa4aa4fda2fa1d339db499799d7f964e9c0431709a50a907344dace834c72b1fa93d39fa393438133a133a3438fa393d394031302b87a0de273da0bca9d8a714a3b0300434d034649df82968a91fac18ab0ba580a773a4d31c77a404237421a79c8b30aca450ab3a347dac6535392d6aa86739f23926380a3a0a3a2638f23967393632712cc6a2119db727e4ad05aaaf28ad2ef632bb349e250da4e62044a780ad839f541ee728e313852038a28e93ee9cba2e1da1baa62b347eaca935702a0bade239f7392e372c3a2c3a2e37f739e23931324630d02ac1a8732b50b045afc1a0482c463036332a261ba98725a11124ac0e9b4ca54ea5c21a9aa10f9cd219101c1b2c80ade8ac1b3590afb137bb31acaa693a283a4337683a683a4337283a693a32329330d22d639b4d2b2aad7aac81a1642a5630993238a4a11c37a001a815ab4a9ceda78ba84824c0a41024e2242020442915b05cb067346eb028377231dda8863a563a0238973a973a0238563a863a3830452abe257d29f11690232398d610a731c5324e324e2997292525c497da22c1238428812e869bc428f7a0069c5324a7319129c424e532049c8f32bc2abc243537ed38e23600390039e236ed3835378d31652d5429742928218297c6a47ba11031db32bc32a628c528fe23f117891762180724842cfc9ff325caa1109e38215d314e28d51c0434e3a04934b42d21269337af387036ef38ef387036af3893370d32a72ee42a642b7621d71e29a047a32c319c3353331028a42b0010461b719b20a676a4f52817a6739e8fa427a5269fe1315e2a1520903473251335123079298b373038d33583388338d33530388b37c62f11282aa26623f99de5a81ba6cda043320734bd33da24b326f8a587aa47a9cfa5f10d0a2ca6a1861d6aa256a11ea45832a324a5a7273499ab2434e82969a7d338e6396b38033a033a6b38e639d338e4304f2c6b249223b892f6ab00aad8a66731b93314341b207e266ea562aa2caa75a88da72e1f099ea199a5988d18c499233126a1f9aa33347dac2e35ad2d05a32739e5394d38273a273a4d38e539273922316e2c55222c22d89dc7ac47aba0a8403111348f343a20c128aca65baa3caa58aa0eab25a8819bfda43723a2223b99bc302ca652ac85341aac1a363f3039233439bc391038063a063a1038bc393439dc311c2e242707a6382949af5dad2298892eac325834fe24cba4c72526a525ad5d1f9220dc284b98f21870a8c8a559a1d52fdea577a9b63499ae26361f2fd1abe239cb392337533a533a2337cb39e239e0326e310b2ea3a9432ca3b02bb0c6a88528cd2e823246287daac42b6e2822aa4b99bba8dfa91897639cd0a559a01b2281281daea2ac533541b075384734cfa3723a8c39ee35683a683aee358c39723a783242303d2c89a029260faf7fad46a85129bf2f543208272ba80f2c8c27e8a954a41faa0bab7a19749daa9ecc1cfc231024cbb063b00d3509b16b382d34c41c893ae139e036ac3aac3ae036e139893a3030982a9a261f293d18fa212b9c9297b431bc322832632962295725ac8d6d236d239028be2e2c9cdf28fea0779c45249b314b292d24e132819d8532ee2a4c253837ed38f0360b390b39f036ed38383730310f2daf290029d71a9a83d2a21fa23431e1325f325a287928c423e31a80127695cf21bb2cc9a0652539a435a2b41fb2311e2987201e3459a055342f2e21288637a4387836063906397836a4388637cc31a92e622ceb291e9c179d95a5a6a52031dc32fc316b27402a781dc51f33a076a7c2a2802a7fa6d3961da530a5159dbe32e72c6127f3344a29b0359d31162ded36a3374435743874384435a337ed36c22fbb28189b3e21f59b94a9b6a71aa43832e2335d339f24ee25d9a502aad0a896a5b918702ca4a0f51dcea1d5a17ba47232a62424a83034d1ab1c346e2abca5c938e03975380a3a0a3a7538e039c938d130a22cc326c51db098daac87ab4ca98f319733a333e0211c2630a443a9c1a8c5a97aa81722649e2e9fcc10c41930a072310ca2a4ab65346eac4b35d62e0f210539d2395938273a273a5938d239053923310c2d8627191a2a9ee5adc0ac23ab7931f7333c34812303288ea27da8bda8adac9eac05a993a0e5a48e236e234789b6300aa801adaa342cab9d36aa312e2cfa388d390038ff39ff3900388d39fa38d8317f2fc82b77a7fa281cb090af8caa2c2e3a32083434249aa22d28b2a02eac8b289f27252a7508cf9c66ab7ba920a5ce30d39d94a8e43413af1636053038aab839a43920375d3a5d3a2037a439b8395d338a31612eb0a60829efaf9aaf4aac4c206a2e6d32c72699a8622c42293aa85b22c9a640a9619eb4178ba896a45f22802657ad9eaa273540b08f38b734f022603a1b390b357d3a7d3a0b351b39603a7533e730b42c4aa05e242db0cdae60ab74a0a62ee1323527d5a8a62e832cc5a22da452ab1fada49e5c1fdfa621a3372269a68fb03baf9e345fb0ee382f35d12c683a5a397b35c93ac93a7b355a39683a3530b22ae1261029ed14ea20179f169daa31a632f7313d291c295d2512180b248623b928fb2e439bd428f0a04a9d8b23c531ac297c24fb322d9d8032132bab252e37e938fa360c390c39fa36e9382e37f030d42c7029b927731348a21ea6dea425319532f031f427cd274a23091cc61b5f13ef24722dbb9f2d251ea2d19f1e1e2732ba293b2141346b9d3a34122e16296237b338c23613391339c236b33862378131862dc12a5d28609d9ca340a90ea9db30b432d2317e276928471f66245b95dba5ef99282c23a6e41c1aa565a4931414334b2d6428f1348b285b35c831952ea336c237bf35a938a938bf35c237a336c72f3f29521b2c205e9ae3a976a8bea52d32b133f93275243d25a1a55ca91ca8c0a4331ff42cbe9ff21d40a250a375a5973201253ba83834eeab0834902a82a4bc38db3980380f3a0f3a8038db39bc389f30902c64272588b39c52ad3cacd2aab931763334338c23be255ca24aa8d2a6e5a99aa71226439f92a02e0ab10a4ca3d131c79f6eab873440ac3f35422fe926de38c0396238233a233a6238c039de382a318b2d9529549808a099ae93adb3acaa31c033c233a124002707a0f6a616a79fad05ad73a804a23ca457246424ef1bde3003a826adc034fea9bf366832a82eba386c390438f139f13904386c39ba3809329b30a02e1ca73d2864b0c6b0c0ae1a2d2731863263210b9e292a7524f4a6342c322cf72c031606a037ad5aac24a9be3180228ea7f7342bafbe350230d6a66f397c393c37613a613a3c377c396f395433b531af2f73a4042602af83afa0ae36a2782d9b315e26caa6612d2d2c4721802af0224a98e8a1621df9aa31a90aa2272163ad59aaf73415b05d38e1340e2c183ac138ac348e3a8e3aac34c138183a4a3467328c2fa6a1ad23ffaf7daff8ad78ab0c2dba326624cea6f72fff2d7f263c9e12ac66aeeb9ca41f61a956a6ec1effabadb0fcae313432af6a392736d930263ac338f133d43ad43af133c338263a1e30982aaa26e72857047c20fe9f10a0a7318b32d1310329e5281125b51645247d243e29512f749ac22820a1db9e0322ee31dc298c240d33319f6932e52a99253137ee380f37183918390f37ee3831375830df2b58284526c298bea069a56ba55d31b232da317d278c27dc22a31d801e1e1d4226dc2dc09edb243fa40fa34811cb32c72bcb256034b48c1a34f62dad293037a438ce3612391239ce36a4383037e230f62c222a24256aa16ca574a9bea9e8308c3260318426be26481f2224498fb4a4c31ae22c1ca5452017a6daa4ac198a33722eba2b0e3579292135a231c42f5f36bb37d635bc38bc38d635bb375f36aa2f6229cc1fbb1ea5990baadea806a725328c339e3209247c245fa595a8d2a66da24c238f2d879da71dd5a31da505a7be329b25fea73f34d1abdb33542a27a3af38d8398b38123a123a8b38d839af3857304a2c9027069cf69d7fad78acc0abd6314e33bf324c244d25b59f57a6dfa3f3a854a43729c39f8aa0299d3a9fd9a53332031598aa973402ac18353a2fe528b338ac3967381e3a1e3a6738ac39b3381c31c82de62af09c30a118af48aec3adc6316d33e83216251e26cd9d0da55ba4bfad92ac6fa4bda26ea2bd24af244e1f793110a310accd348ba87b366e3200306e384b390838dc39dc3908384b396e38723267315b305aa620276eb072b1a8b0942c45303d3139201b9d392a39280c8ccd2e862f1730481c06a19baf3daf4cad75322c26d3a7033533af5d350930401c153960398737623a623a8737603915390832fb300b30daa0da232fad3caee6aee0225b2e21311625eda4392e212d3529e62cb429ae28e2a1e71cb8ad62acf2a8f0a962b0c7ae8134bbaf7438ab3597318c398738c434b73ab73ac43487388c3907355834f532dd9fce1d0eae29af3eb09facfc29ca306620b2a25e30582fc62c97a371ac44ae6a96651c21ace3a831106bb0b4b279b10c3462aef239c237983474391938da31ce3ace3ada3119387439ed2f1a2aa725852823987e1d25a1b2a1ae318632b931c928ab288124f0081b24562459297e2f149c772828a2bca0341f2e32252a8c242a333da16332982a032551370339433730393039433703395137c32f442ac0255925f49cd6a14ba593a57231993297310527012779207f16681f81215a28ac2e7a9f9924b4a45ba4fd9e5e339f2c2a287134fc96ee337a2d37292c37b7380837243924390837b7382c370b30c12acc26f321eea3b5a623aa85aa1d31a1325c3145268e26fa2386271e24f39e4b24972db6a47b1f75a811a842a2433416309b2d2535082ac334f830132f4136da371036c538c5381036da374136392f8d281e1e571f6794b2a9e1a801a73232b6335c32f31f6c20e6a4f1a55ca57c9bf825582e2698e41e7aa5b8a79ea8fb32ae25daa6593402ab73336e289ca4a638e1399a380c3a0c3a9a38e139a638002fd4295423c29e9a9e90ac0eab27aa0532373358328b24d8243e9dd9a4e29f13a402217c2c2c9f2ca0c5a5f6a68fa952335128e5a59f34a1ab8e347a2d75258a389c397038193a193a70389c398a380030c62bee276f9e16a2a9ad1cade4acaa31f132fd3116256425fc13159f06989daaf0a63a2891a275a0fb9f9da06da455330b2a0b96db346ea596352e31c12e16381739f237bb39bb39f2371739163859327531cc30b3a48125caaf21b1e6b0f22edf309830c78dcd97e42569272b241830973049319821a5a280b0abb061afd6326025cda8fe34b2ae7b34962d4b20b03888393c38593a593a3c388839b038f1305a306730799d5f1e3badebae32b0de2d8d309830ac20579f512c222c782a502e3a2d172e799b5d0af6aebfad3eac1b2ebaa95aac923430afa136a633683082389b3862369f3a9f3a62369b388238c636de352f35bd94ed1f37ad2fad6fac68aa1d278f2bef95bba1b12fdc2ea82c4fac4ead33ac8418d61980ac92ab0fa921b0b3b247b2ea3391ad60393237da347538ba37b933ba3aba3ab933ba377538