// static 2088: S_PEARLESCENCE_MASK=1 S_SEPARATE_CHANNEL_INPUTS=1 S_OVERLAY_TEXTURE=1 S_CASE_HARDENING=1
// Source 2 Viewer 20.1.0.0 - https://valveresourceformat.github.io
// SPIR-V source, GLSL reflection with SPIRV-Cross by KhronosGroup
// Static combos: S_PEARLESCENCE_MASK, S_SEPARATE_CHANNEL_INPUTS, S_OVERLAY_TEXTURE, S_CASE_HARDENING

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

struct _20
{
    int bRoughnessMode;
    vec3 g_vAlbedoLevels;
    float g_fColorBoostFactor;
    float g_fOverlayStrength;
    float g_fOverlayMaterialStrength;
    float g_fOverlayBrightness;
    float g_fOverlayDurability;
    float g_fOverlayRoughness;
    float g_fOverlayMetalness;
    float g_fOverlayPearlescentMask;
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
    int nOverlayMaskMode;
    int nOverlayBlendMode;
};

layout(set = 1) uniform _20 _Globals_;

layout(set = 1, binding = 30) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 23) uniform sampler g_sTrilinearClamp;
layout(set = 1, binding = 31) uniform texture2D g_tMasks;
layout(set = 1, binding = 42) uniform texture2D g_tWear;
layout(set = 1, binding = 22) uniform sampler g_sTrilinearWrap;
layout(set = 1, binding = 41) uniform texture2D g_tPattern;
layout(set = 1, binding = 27) uniform sampler AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 36) uniform texture2D g_tNormal;
layout(set = 1, binding = 44) uniform texture2D g_tCaseHardeningColorRamp;
layout(set = 1, binding = 39) uniform texture2D g_tOverlay;
layout(set = 1, binding = 43) uniform texture2D g_tGrunge;
layout(set = 1, binding = 35) uniform texture2D g_tMetalness;
layout(set = 1, binding = 37) uniform texture2D g_tPearlescenceMask;
layout(set = 1, binding = 34) uniform texture2D g_tColor;
layout(set = 1, binding = 38) uniform texture2D g_tGlitterNormal;

layout(location = 1) in vec4 input_1;
layout(location = 2) in vec4 input_2;
layout(location = 3) in vec2 input_3;
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
    vec4 _21760 = texture(sampler2D(g_tOverlay, g_sTrilinearWrap), input_3.xy);
    vec4 _19017;
    SPIRV_CROSS_BRANCH
    switch (_Globals_.nOverlayMaskMode)
    {
        case 1:
        {
            vec4 _18602 = _21760;
            _18602.w = _21760.w * (1.0 - max(_18992.x, max(_18992.y, _18992.z)));
            _19017 = _18602;
            break;
        }
        case 2:
        {
            vec4 _18603 = _21760;
            _18603.w = _21760.w * (_18992.x * (1.0 - max(_18992.y, _18992.z)));
            _19017 = _18603;
            break;
        }
        case 3:
        {
            vec4 _18604 = _21760;
            _18604.w = _21760.w * (_18992.y * (1.0 - _18992.z));
            _19017 = _18604;
            break;
        }
        case 4:
        {
            vec4 _18605 = _21760;
            _18605.w = _21760.w * _18992.z;
            _19017 = _18605;
            break;
        }
        case 5:
        {
            vec4 _18606 = _21760;
            _18606.w = _21760.w * max(_18992.x, max(_18992.y, _18992.z));
            _19017 = _18606;
            break;
        }
        default:
        {
            _19017 = _21760;
            break;
        }
    }
    float _8479 = _19017.w * _Globals_.g_fOverlayStrength;
    vec4 _22799 = vec4(_19017.xyz * _Globals_.g_fOverlayBrightness, _8479);
    float _6970 = _19334.x * mix(smoothstep(0.0, 0.7200000286102294921875, pow(_4306, 1.2999999523162841796875)), smoothstep(0.0, 0.4000000059604644775390625, _4306), pow(_Globals_.g_flWearAmount, 1.2000000476837158203125));
    float _20190 = (_Globals_.g_flWearAmount * 6.0) + 1.0;
    float _7656 = _18992.x;
    float _11437 = _18992.y;
    float _12425 = _18992.z;
    float _10779 = mix(mix(mix(_Globals_.g_vPaintDurability.x, _Globals_.g_vPaintDurability.y, _7656), _Globals_.g_vPaintDurability.z, _11437), _Globals_.g_vPaintDurability.w, _12425);
    float _4693 = _Globals_.g_fWearSoftness * _10779;
    float _11674 = 0.560000002384185791015625 - _4693;
    float _13285 = 0.7400000095367431640625 + _4693;
    float _11943 = smoothstep(_11674, _13285, (((_18087.w + _6970) * _20190) * mix(1.0, _Globals_.g_fOverlayDurability, _19017.w)) * _10779);
    float _15188 = smoothstep(_11674, _13285, (_6970 * _20190) * _Globals_.g_fOverlayDurability);
    float _21709;
    SPIRV_CROSS_BRANCH
    if (_Globals_.nOverlayMaskMode == 0)
    {
        _21709 = max(0.0, mix(_11943, min(_11943, _15188), _8479));
    }
    else
    {
        _21709 = _11943;
    }
    vec4 _19287;
    SPIRV_CROSS_BRANCH
    if (_Globals_.nOverlayBlendMode == 4)
    {
        vec4 _11598 = _22799;
        _11598.w = _8479 * saturate(1.0 - _15188);
        _19287 = _11598;
    }
    else
    {
        _19287 = _22799;
    }
    vec4 _9437 = texture(sampler2D(g_tGrunge, g_sTrilinearWrap), input_2.zw);
    vec4 _16529 = mix(vec4(1.0), _9437, vec4((pow(1.0 - _4306, 4.0) * 0.25) + (0.75 * _Globals_.g_flWearAmount)));
    float _7177 = mix(mix(mix(_Globals_.g_vPaintMetalness.x, _Globals_.g_vPaintMetalness.y, _7656), _Globals_.g_vPaintMetalness.z, _11437), _Globals_.g_vPaintMetalness.w, _12425);
    float _10247;
    vec4 _11711;
    if (_Globals_.bRoughnessMode != 0)
    {
        vec4 _19391 = texture(sampler2D(g_tMetalness, g_sTrilinearClamp), input_1.xy);
        _19391.x = _19391.x;
        float _21710;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bRoughnessPerColor != 0)
        {
            _21710 = mix(mix(mix(_Globals_.g_vPaintRoughness.x, _Globals_.g_vPaintRoughness.y, _7656), _Globals_.g_vPaintRoughness.z, _11437), _Globals_.g_vPaintRoughness.w, _12425);
        }
        else
        {
            _21710 = _Globals_.g_flPaintRoughness;
        }
        float _10825 = ((1.0 - _15188) * _19287.w) * _Globals_.g_fOverlayMaterialStrength;
        float _13705 = mix(_7177, _Globals_.g_fOverlayMetalness, _10825);
        vec4 _13720 = mix(vec4(min(1.0, mix(_21710, _Globals_.g_fOverlayRoughness, _10825) + ((((1.0 - _16529.w) * _Globals_.g_flWearAmount) * _Globals_.g_flWearAmount) * 0.5)), _13705, 0.0, 1.0), _19391, vec4(_21709));
        vec4 _20360 = texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.xy);
        float _9193 = mix((1.0 - _21709) * _20360.x, _Globals_.g_fOverlayPearlescentMask - _21709, _10825);
        vec4 _7773 = _13720;
        _7773.z = _9193;
        vec3 _18043 = _7773.xyz * vec3(0.077399380505084991455078125);
        vec3 _7676 = pow((_7773.xyz * vec3(0.947867333889007568359375)) + vec3(0.052132703363895416259765625), vec3(2.400000095367431640625));
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
        if (_9193 <= 0.040449999272823333740234375)
        {
            _19513 = _18043.z;
        }
        else
        {
            _19513 = _7676.z;
        }
        vec4 _17156 = vec4(_21354, _23035, _9193, min(1.0, _Globals_.g_flPearlescentScale));
        _17156.z = _19513;
        _11711 = _17156;
        _10247 = _13705;
    }
    else
    {
        _11711 = vec4(input_1.xy, 0.0, 1.0);
        _10247 = _7177;
    }
    vec4 _22401;
    if (_Globals_.bRoughnessMode == 0)
    {
        vec4 _21761 = texture(sampler2D(g_tColor, g_sTrilinearClamp), input_1.xy);
        vec3 _6606 = (((((_19699.xyzw + _20630.xyzw).xyzw + _20631.xyzw).xyzw + _20632.xyzw).xyzw + _20633.xyzw).xyzw * 0.20000000298023223876953125).xyz;
        vec3 _24109 = mix(mix(mix(mix(_Globals_.g_vColor0.xyz, _6606, vec3(_Globals_.g_vCaseHardening.x)).xyz, mix(_Globals_.g_vColor1.xyz, _6606, vec3(_Globals_.g_vCaseHardening.y)), vec3(_7656)).xyz, mix(_Globals_.g_vColor2.xyz, _6606, vec3(_Globals_.g_vCaseHardening.z)), vec3(_11437)).xyz, mix(_Globals_.g_vColor3.xyz, _6606, vec3(_Globals_.g_vCaseHardening.w)), vec3(_12425));
        vec3 _19629;
        SPIRV_CROSS_BRANCH
        switch (_Globals_.nOverlayBlendMode)
        {
            case 0:
            {
                _19629 = mix(_24109.xyz, _19287.xyz, vec3(_19287.w));
                break;
            }
            case 1:
            {
                vec3 _19212 = normalize(max(vec3(0.0003000000142492353916168212890625), (_19287.xyz * _24109.xyz).xyz)) * 1.059999942779541015625;
                vec3 _13609 = _19212.xyz;
                _19629 = mix(_24109.xyz, mix(vec3(_Globals_.g_vAlbedoLevels.x), max((((_13609 * _Globals_.g_vAlbedoLevels.x) * 1.73199999332427978515625) / vec3(length(_13609))) / vec3(dot(_19212.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _19212 * mix(_Globals_.g_vAlbedoLevels.x, _Globals_.g_vAlbedoLevels.z, saturate(pow(max(_24109.x, max(_24109.y, _24109.z)), _Globals_.g_vAlbedoLevels.y)))).xyz, vec3(pow(smoothstep(0.0003000000142492353916168212890625, _Globals_.g_vAlbedoLevels.x, dot(saturate(_24109.xyz * 1.0).xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), 0.5))).xyz, vec3(_19287.w));
                break;
            }
            case 2:
            {
                vec3 _23491 = _24109.xyz * _19287.xyz;
                vec3 _19213 = normalize(max(vec3(0.0003000000142492353916168212890625), _23491.xyz)) * 1.059999942779541015625;
                vec3 _13610 = _19213.xyz;
                _19629 = mix(_24109.xyz, mix(vec3(_Globals_.g_vAlbedoLevels.x), max((((_13610 * _Globals_.g_vAlbedoLevels.x) * 1.73199999332427978515625) / vec3(length(_13610))) / vec3(dot(_19213.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _19213 * mix(_Globals_.g_vAlbedoLevels.x, _Globals_.g_vAlbedoLevels.z, saturate(pow(max(_23491.x, max(_23491.y, _23491.z)), _Globals_.g_vAlbedoLevels.y)))).xyz, vec3(pow(smoothstep(0.0003000000142492353916168212890625, _Globals_.g_vAlbedoLevels.x, dot(saturate(_23491.xyz * 1.0).xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), 0.5))).xyz, vec3(_19287.w));
                break;
            }
            case 3:
            {
                vec3 _18121 = _24109.xyz + _19287.xyz;
                float _7244 = dot(saturate(_18121.xyz * 2.0).xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125));
                vec3 _19214 = normalize(max(vec3(0.0003000000142492353916168212890625), _18121.xyz)) * 1.059999942779541015625;
                vec3 _13611 = _19214.xyz;
                vec3 _19113 = max((((_13611 * _Globals_.g_vAlbedoLevels.x) * 1.73199999332427978515625) / vec3(length(_13611))) / vec3(dot(_19214.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _19214 * mix(_Globals_.g_vAlbedoLevels.x, _Globals_.g_vAlbedoLevels.z, saturate(pow(max(_18121.x, max(_18121.y, _18121.z)) * 2.0, _Globals_.g_vAlbedoLevels.y)))).xyz;
                _19629 = mix(_24109.xyz, mix(vec3(_Globals_.g_vAlbedoLevels.x), mix(_19113, min(_Globals_.g_vAlbedoLevels.zzz, _19113 + (vec3(_7244) * 2.0)), vec3(1.0 / _Globals_.g_fColorBoostFactor)).xyz, vec3(pow(smoothstep(0.0003000000142492353916168212890625, _Globals_.g_vAlbedoLevels.x, _7244), 0.5))).xyz, vec3(_19287.w));
                break;
            }
            case 4:
            {
                _19629 = mix(_24109.xyz, _19287.xyz, vec3(_19287.w));
                break;
            }
            default:
            {
                _19629 = _24109.xyz;
                break;
            }
        }
        vec3 _21103 = _19629.xyz * _16529.xyz;
        vec3 _21271 = normalize(max(vec3(0.0003000000142492353916168212890625), _21103.xyz));
        vec3 _23898 = mix(_Globals_.g_vPaintAlbedoLevels.xyz, _Globals_.g_vMetallicPaintAlbedoLevels.xyz, vec3(_10247));
        _22401 = vec4(mix(mix(_21103, ((_21271.xyz * mix(min(_23898.x, dot(_19629.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _23898.z, saturate(pow(max(_21103.x, max(_21103.y, _21103.z)), _23898.y)))) / vec3(max(_21271.x, max(_21271.y, _21271.z)))).xyz, vec3(_Globals_.g_flWearAmount)), _21761.xyz, vec3(_21709)), 1.0);
    }
    else
    {
        _22401 = _11711;
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


