// static 1512: S_PEARLESCENCE_MASK=1 S_SEPARATE_CHANNEL_INPUTS=1 S_CASE_HARDENING=1
// Source 2 Viewer 20.1.0.0 - https://valveresourceformat.github.io
// SPIR-V source, GLSL reflection with SPIRV-Cross by KhronosGroup
// Static combos: S_PEARLESCENCE_MASK, S_SEPARATE_CHANNEL_INPUTS, S_CASE_HARDENING

#version 460
#if defined(GL_EXT_control_flow_attributes)
#extension GL_EXT_control_flow_attributes : require
#define SPIRV_CROSS_FLATTEN [[flatten]]
#define SPIRV_CROSS_BRANCH [[dont_flatten]]
#define SPIRV_CROSS_UNROLL [[unroll]]
#define SPIRV_CROSS_LOOP [[dont_unroll]]
#else
#define SPIRV_CROSS_FLATTEN
#define SPIRV_CROSS_BRANCH
#define SPIRV_CROSS_UNROLL
#define SPIRV_CROSS_LOOP
#endif

struct _468
{
    int bRoughnessMode;
    float g_fWearSoftness;
    vec3 g_vColor0;
    vec3 g_vColor1;
    vec3 g_vColor2;
    vec3 g_vColor3;
    vec4 g_vPaintDurability;
    float g_flPaintRoughness;
    int g_bRoughnessPerColor;
    vec4 g_vPaintRoughness;
    float g_flPearlescentScale;
    vec4 g_vPaintMetalness;
    float g_flWearAmount;
    float g_flCaseHardeningPatternInfluence;
    float g_flCaseHardeningGeometricInfluence;
    float g_flCaseHardeningRampOffset;
    vec4 g_vCaseHardening;
    vec3 g_vPaintAlbedoLevels;
    vec3 g_vMetallicPaintAlbedoLevels;
};

layout(set = 1) uniform _468 _Globals_;

layout(set = 1, binding = 30) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 23) uniform sampler g_sTrilinearClamp;
layout(set = 1, binding = 31) uniform texture2D g_tMasks;
layout(set = 1, binding = 40) uniform texture2D g_tWear;
layout(set = 1, binding = 22) uniform sampler g_sTrilinearWrap;
layout(set = 1, binding = 39) uniform texture2D g_tPattern;
layout(set = 1, binding = 27) uniform sampler AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 36) uniform texture2D g_tNormal;
layout(set = 1, binding = 42) uniform texture2D g_tCaseHardeningColorRamp;
layout(set = 1, binding = 41) uniform texture2D g_tGrunge;
layout(set = 1, binding = 35) uniform texture2D g_tMetalness;
layout(set = 1, binding = 37) uniform texture2D g_tPearlescenceMask;
layout(set = 1, binding = 34) uniform texture2D g_tColor;
layout(set = 1, binding = 38) uniform texture2D g_tGlitterNormal;

layout(location = 1) in vec4 input_1;
layout(location = 2) in vec4 input_2;
layout(location = 0) out vec4 output_0;

void main()
{
    vec4 _18087 = texture(sampler2D(g_tAmbientOcclusion, g_sTrilinearClamp), input_1.xy);
    float _4306 = pow(_18087.x, 1.5) * 0.959999978542327880859375;
    float _5542 = _18087.y;
    vec4 _18992 = texture(sampler2D(g_tMasks, g_sTrilinearClamp), input_1.xy);
    vec4 _19334 = texture(sampler2D(g_tWear, g_sTrilinearWrap), input_2.xy);
    vec4 _22452 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), input_1.zw);
    vec4 _9448 = texture(sampler2D(g_tNormal, g_sTrilinearWrap), input_1.xy);
    vec4 _19604 = smoothstep(vec4(0.85000002384185791015625), vec4(0.20000000298023223876953125), min(_9448, vec4(1.0) - _9448));
    float _4409 = mix(0.5, pow(_4306, 0.85000002384185791015625), _Globals_.g_flCaseHardeningGeometricInfluence) * mix(1.0, _5542 * (min(_19604.x, _19604.y) * 2.0), _Globals_.g_flCaseHardeningGeometricInfluence);
    float _6306 = _4409 * 2.0;
    float _3407 = max(_22452.y * _Globals_.g_flCaseHardeningPatternInfluence, ((1.0 - _5542) * 0.20000000298023223876953125) * _Globals_.g_flCaseHardeningGeometricInfluence) + _Globals_.g_flCaseHardeningRampOffset;
    vec4 _11030 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), (input_1.zw + vec2(0.00048828125)).xy);
    vec4 _11031 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), (input_1.zw + vec2(-0.00048828125)).xy);
    vec4 _11032 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), (input_1.zw + vec2(-0.00048828125, 0.00048828125)).xy);
    vec4 _20284 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), (input_1.zw + vec2(0.00048828125, -0.00048828125)).xy);
    vec4 _19699 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + _22452.x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20630 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + _11030.x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20631 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + _11031.x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20632 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + _11032.x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20633 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + _20284.x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    float _7656 = _18992.x;
    float _11437 = _18992.y;
    float _12425 = _18992.z;
    float _10779 = mix(mix(mix(_Globals_.g_vPaintDurability.x, _Globals_.g_vPaintDurability.y, _7656), _Globals_.g_vPaintDurability.z, _11437), _Globals_.g_vPaintDurability.w, _12425);
    float _4693 = _Globals_.g_fWearSoftness * _10779;
    float _22167 = smoothstep(0.560000002384185791015625 - _4693, 0.7400000095367431640625 + _4693, ((_18087.w + (_19334.x * mix(smoothstep(0.0, 0.7200000286102294921875, pow(_4306, 1.2999999523162841796875)), smoothstep(0.0, 0.4000000059604644775390625, _4306), pow(_Globals_.g_flWearAmount, 1.2000000476837158203125)))) * ((_Globals_.g_flWearAmount * 6.0) + 1.0)) * _10779);
    vec4 _9437 = texture(sampler2D(g_tGrunge, g_sTrilinearWrap), input_2.zw);
    vec4 _16529 = mix(vec4(1.0), _9437, vec4((pow(1.0 - _4306, 4.0) * 0.25) + (0.75 * _Globals_.g_flWearAmount)));
    float _7177 = mix(mix(mix(_Globals_.g_vPaintMetalness.x, _Globals_.g_vPaintMetalness.y, _7656), _Globals_.g_vPaintMetalness.z, _11437), _Globals_.g_vPaintMetalness.w, _12425);
    vec4 _7078;
    if (_Globals_.bRoughnessMode != 0)
    {
        vec4 _19391 = texture(sampler2D(g_tMetalness, g_sTrilinearClamp), input_1.xy);
        _19391.x = _19391.x;
        float _20271;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bRoughnessPerColor != 0)
        {
            _20271 = mix(mix(mix(_Globals_.g_vPaintRoughness.x, _Globals_.g_vPaintRoughness.y, _7656), _Globals_.g_vPaintRoughness.z, _11437), _Globals_.g_vPaintRoughness.w, _12425);
        }
        else
        {
            _20271 = _Globals_.g_flPaintRoughness;
        }
        vec4 _13720 = mix(vec4(min(1.0, _20271 + ((((1.0 - _16529.w) * _Globals_.g_flWearAmount) * _Globals_.g_flWearAmount) * 0.5)), _7177, 0.0, 1.0), _19391, vec4(_22167));
        vec4 _20360 = texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.xy);
        float _13666 = (1.0 - _22167) * _20360.x;
        vec4 _8739 = _13720;
        _8739.z = _13666;
        vec3 _18043 = _8739.xyz * vec3(0.077399380505084991455078125);
        vec3 _7676 = pow((_8739.xyz * vec3(0.947867333889007568359375)) + vec3(0.052132703363895416259765625), vec3(2.400000095367431640625));
        float _21354;
        if (_13720.x <= 0.040449999272823333740234375)
        {
            _21354 = _18043.x;
        }
        else
        {
            _21354 = _7676.x;
        }
        float _23035;
        if (_13720.y <= 0.040449999272823333740234375)
        {
            _23035 = _18043.y;
        }
        else
        {
            _23035 = _7676.y;
        }
        float _19513;
        if (_13666 <= 0.040449999272823333740234375)
        {
            _19513 = _18043.z;
        }
        else
        {
            _19513 = _7676.z;
        }
        vec4 _17156 = vec4(_21354, _23035, _13666, min(1.0, _Globals_.g_flPearlescentScale));
        _17156.z = _19513;
        _7078 = _17156;
    }
    else
    {
        _7078 = vec4(input_1.xy, 0.0, 1.0);
    }
    vec4 _22401;
    if (_Globals_.bRoughnessMode == 0)
    {
        vec3 _6606 = (((((_19699.xyzw + _20630.xyzw).xyzw + _20631.xyzw).xyzw + _20632.xyzw).xyzw + _20633.xyzw).xyzw * 0.20000000298023223876953125).xyz;
        vec3 _24417 = mix(mix(mix(mix(_Globals_.g_vColor0.xyz, _6606, vec3(_Globals_.g_vCaseHardening.x)).xyz, mix(_Globals_.g_vColor1.xyz, _6606, vec3(_Globals_.g_vCaseHardening.y)), vec3(_7656)).xyz, mix(_Globals_.g_vColor2.xyz, _6606, vec3(_Globals_.g_vCaseHardening.z)), vec3(_11437)).xyz, mix(_Globals_.g_vColor3.xyz, _6606, vec3(_Globals_.g_vCaseHardening.w)), vec3(_12425));
        vec3 _21103 = _24417.xyz * _16529.xyz;
        vec3 _21271 = normalize(max(vec3(0.0003000000142492353916168212890625), _21103.xyz));
        vec3 _23898 = mix(_Globals_.g_vPaintAlbedoLevels.xyz, _Globals_.g_vMetallicPaintAlbedoLevels.xyz, vec3(_7177));
        _22401 = vec4(mix(mix(_21103, ((_21271.xyz * mix(min(_23898.x, dot(_24417.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _23898.z, saturate(pow(max(_21103.x, max(_21103.y, _21103.z)), _23898.y)))) / vec3(max(_21271.x, max(_21271.y, _21271.z)))).xyz, vec3(_Globals_.g_flWearAmount)), texture(sampler2D(g_tColor, g_sTrilinearClamp), input_1.xy).xyz, vec3(_22167)), 1.0);
    }
    else
    {
        _22401 = _7078;
    }
    vec4 _3300 = texture(sampler2D(g_tGlitterNormal, g_sTrilinearWrap), input_1.xy);
    vec4 _6805;
    if (_3300.w < 0.0)
    {
        vec4 _23136 = _22401;
        _23136.x = _3300.x;
        _23136.y = _3300.y;
        _23136.z = _3300.z;
        _6805 = _23136;
    }
    else
    {
        _6805 = _22401;
    }
    output_0 = _6805;
}


