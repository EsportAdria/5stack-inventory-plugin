// static 3852: S_ROUGHNESS_TEXTURE=1 S_PEARLESCENCE_MASK=1 S_SEPARATE_CHANNEL_INPUTS=1 S_CASE_HARDENING=1 S_CASE_HARDENING_TRILINEAR=1
// Source 2 Viewer 20.1.0.0 - https://valveresourceformat.github.io
// SPIR-V source, GLSL reflection with SPIRV-Cross by KhronosGroup
// Static combos: S_ROUGHNESS_TEXTURE, S_PEARLESCENCE_MASK, S_SEPARATE_CHANNEL_INPUTS, S_CASE_HARDENING, S_CASE_HARDENING_TRILINEAR

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

const vec2 _52[17] = vec2[](vec2(-0.00107233994640409946441650390625, -0.004002030007541179656982421875), vec2(0.001953119994141161441802978515625, -0.0033829100430011749267578125), vec2(0.004002030007541179656982421875, -0.00107233994640409946441650390625), vec2(-0.00071489601396024227142333984375, -0.00266802008263766765594482421875), vec2(0.000976564944721758365631103515625, -0.001691460027359426021575927734375), vec2(0.00266802008263766765594482421875, -0.00071489601396024227142333984375), vec2(-0.0033829100430011749267578125, -0.001953119994141161441802978515625), vec2(-0.001691460027359426021575927734375, -0.000976564944721758365631103515625), vec2(0.0), vec2(0.001691460027359426021575927734375, 0.000976564944721758365631103515625), vec2(0.0033829100430011749267578125, 0.001953119994141161441802978515625), vec2(-0.00266802008263766765594482421875, 0.00071489601396024227142333984375), vec2(-0.000976564944721758365631103515625, 0.001691460027359426021575927734375), vec2(0.00071489601396024227142333984375, 0.00266802008263766765594482421875), vec2(-0.004002030007541179656982421875, 0.00107233994640409946441650390625), vec2(-0.001953119994141161441802978515625, 0.0033829100430011749267578125), vec2(0.00107233994640409946441650390625, 0.0040020202286541461944580078125));
vec4 _2;
float _3;

struct _2048
{
    vec4 g_vPatternTexCoordXform0;
    vec4 g_vPatternTexCoordXform1;
    vec4 g_vPatternTexCoordXformHalftoneA0;
    vec4 g_vPatternTexCoordXformHalftoneA1;
    vec4 g_vPatternTexCoordXformHalftoneB0;
    vec4 g_vPatternTexCoordXformHalftoneB1;
    vec4 _m6;
    vec4 _m7;
    int bRoughnessMode;
    int bSpraypaintHalftone;
    float g_fWearSoftness;
    vec3 g_vColor0;
    vec3 g_vColor1;
    vec3 g_vColor2;
    vec3 g_vColor3;
    vec4 g_vPaintDurability;
    int g_bRoughnessPerColor;
    vec4 g_vPaintRoughness;
    float g_flPearlescentScale;
    vec4 g_vPaintMetalness;
    float g_flWearAmount;
    int g_bBiasSpray;
    vec3 g_vSprayBiasBlend;
    float g_fHalftoneCavityCutoff;
    vec3 g_vHalftonePatternLevels;
    vec2 g_vHalftoneThresholds;
    int g_bHalftoneInCavity;
    float g_flCaseHardeningPatternInfluence;
    float g_flCaseHardeningGeometricInfluence;
    float g_flCaseHardeningRampOffset;
    vec4 g_vCaseHardening;
    vec3 g_vPaintAlbedoLevels;
    vec3 g_vMetallicPaintAlbedoLevels;
};

layout(set = 1) uniform _2048 _Globals_;

layout(set = 1, binding = 30) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 23) uniform sampler g_sTrilinearClamp;
layout(set = 1, binding = 31) uniform texture2D g_tMasks;
layout(set = 1, binding = 33) uniform texture2D g_tPosition;
layout(set = 1, binding = 41) uniform texture2D g_tWear;
layout(set = 1, binding = 22) uniform sampler g_sTrilinearWrap;
layout(set = 1, binding = 27) uniform sampler AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 32) uniform texture2D g_tSurface;
layout(set = 1, binding = 40) uniform texture2D g_tPattern;
layout(set = 1, binding = 36) uniform texture2D g_tNormal;
layout(set = 1, binding = 43) uniform texture2D g_tCaseHardeningColorRamp;
layout(set = 1, binding = 42) uniform texture2D g_tGrunge;
layout(set = 1, binding = 35) uniform texture2D g_tMetalness;
layout(set = 1, binding = 37) uniform texture2D g_tPaintRoughness;
layout(set = 1, binding = 38) uniform texture2D g_tPearlescenceMask;
layout(set = 1, binding = 34) uniform texture2D g_tColor;
layout(set = 1, binding = 39) uniform texture2D g_tGlitterNormal;

layout(location = 1) in vec4 input_1;
layout(location = 2) in vec4 input_2;
layout(location = 0) out vec4 output_0;

void main()
{
    vec4 _18087 = texture(sampler2D(g_tAmbientOcclusion, g_sTrilinearClamp), input_1.xy);
    float _4306 = pow(_18087.x, 1.5) * 0.959999978542327880859375;
    float _5542 = _18087.y;
    vec4 _12552 = texture(sampler2D(g_tMasks, g_sTrilinearClamp), input_1.xy);
    vec4 _13155;
    _13155 = vec4(0.0);
    int _18752;
    vec4 _19130;
    int _16208 = 0;
    for (;;)
    {
        if (!(_16208 < 17))
        {
            break;
        }
        _19130 = _13155 + (texture(sampler2D(g_tPosition, g_sTrilinearClamp), (input_1.xy + (_52[_16208] * 0.20000000298023223876953125)).xy) * 0.0588235296308994293212890625);
        _18752 = _16208 + 1;
        _13155 = _19130;
        _16208 = _18752;
        continue;
    }
    vec4 _11428 = _13155 * 2.0;
    bool _14874 = _Globals_.bSpraypaintHalftone != 0;
    vec4 _19667;
    SPIRV_CROSS_BRANCH
    if (_14874)
    {
        vec4 _18602 = _11428;
        _18602.z = _11428.z * (-1.0);
        _19667 = _18602;
    }
    else
    {
        _19667 = _11428;
    }
    vec4 _19068 = texture(sampler2D(g_tWear, g_sTrilinearWrap), input_2.xy);
    vec4 _21760 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
    bool _14875 = _Globals_.g_bBiasSpray != 0;
    vec4 _20826;
    SPIRV_CROSS_BRANCH
    if (_14875)
    {
        vec3 _23972 = _21760.xyz;
        vec3 _22672 = _23972 * 12.9200000762939453125;
        vec3 _7485 = (pow(_23972, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
        float _21354;
        if (_21760.x <= 0.003130800090730190277099609375)
        {
            _21354 = _22672.x;
        }
        else
        {
            _21354 = _7485.x;
        }
        float _21355;
        if (_21760.y <= 0.003130800090730190277099609375)
        {
            _21355 = _22672.y;
        }
        else
        {
            _21355 = _7485.y;
        }
        float _19167;
        if (_21760.z <= 0.003130800090730190277099609375)
        {
            _19167 = _22672.z;
        }
        else
        {
            _19167 = _7485.z;
        }
        vec4 _16668;
        _16668.x = _21354;
        _16668.y = _21355;
        _16668.z = _19167;
        _20826 = _16668;
    }
    else
    {
        _20826 = _21760;
    }
    vec3 _6906 = normalize((_20826.xyz * 2.0) - vec3(1.0));
    vec4 _19680 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.yz, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_19667.yz, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec4 _19681 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.xz, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_19667.xz, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec4 _19718 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.yx, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_19667.yx, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec4 _17673 = mix(mix(_19680.xyzw, _19681.xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_6906.y), 7.0))), _19718.xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_6906.z), 7.0)));
    vec4 _22401;
    SPIRV_CROSS_BRANCH
    if (_14874)
    {
        vec4 _12936 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
        vec4 _20827;
        SPIRV_CROSS_BRANCH
        if (_14875)
        {
            vec3 _23973 = _12936.xyz;
            vec3 _22673 = _23973 * 12.9200000762939453125;
            vec3 _7486 = (pow(_23973, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
            float _21356;
            if (_12936.x <= 0.003130800090730190277099609375)
            {
                _21356 = _22673.x;
            }
            else
            {
                _21356 = _7486.x;
            }
            float _21357;
            if (_12936.y <= 0.003130800090730190277099609375)
            {
                _21357 = _22673.y;
            }
            else
            {
                _21357 = _7486.y;
            }
            float _19168;
            if (_12936.z <= 0.003130800090730190277099609375)
            {
                _19168 = _22673.z;
            }
            else
            {
                _19168 = _7486.z;
            }
            vec4 _16671;
            _16671.x = _21356;
            _16671.y = _21357;
            _16671.z = _19168;
            _20827 = _16671;
        }
        else
        {
            _20827 = _12936;
        }
        vec3 _8217 = normalize((_20827.xyz * 2.0) - vec3(1.0));
        vec4 _20991 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.yz, _Globals_.g_vPatternTexCoordXformHalftoneA0.xy) + _Globals_.g_vPatternTexCoordXformHalftoneA0.w, dot(_19667.yz, _Globals_.g_vPatternTexCoordXformHalftoneA1.xy) + _Globals_.g_vPatternTexCoordXformHalftoneA1.w));
        vec4 _20992 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.xz, _Globals_.g_vPatternTexCoordXformHalftoneA0.xy) + _Globals_.g_vPatternTexCoordXformHalftoneA0.w, dot(_19667.xz, _Globals_.g_vPatternTexCoordXformHalftoneA1.xy) + _Globals_.g_vPatternTexCoordXformHalftoneA1.w));
        vec4 _19719 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.yx, _Globals_.g_vPatternTexCoordXformHalftoneA0.xy) + _Globals_.g_vPatternTexCoordXformHalftoneA0.w, dot(_19667.yx, _Globals_.g_vPatternTexCoordXformHalftoneA1.xy) + _Globals_.g_vPatternTexCoordXformHalftoneA1.w));
        vec4 _12937 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
        vec4 _20828;
        SPIRV_CROSS_BRANCH
        if (_14875)
        {
            vec3 _23974 = _12937.xyz;
            vec3 _22674 = _23974 * 12.9200000762939453125;
            vec3 _7487 = (pow(_23974, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
            float _21358;
            if (_12937.x <= 0.003130800090730190277099609375)
            {
                _21358 = _22674.x;
            }
            else
            {
                _21358 = _7487.x;
            }
            float _21359;
            if (_12937.y <= 0.003130800090730190277099609375)
            {
                _21359 = _22674.y;
            }
            else
            {
                _21359 = _7487.y;
            }
            float _19169;
            if (_12937.z <= 0.003130800090730190277099609375)
            {
                _19169 = _22674.z;
            }
            else
            {
                _19169 = _7487.z;
            }
            vec4 _16673;
            _16673.x = _21358;
            _16673.y = _21359;
            _16673.z = _19169;
            _20828 = _16673;
        }
        else
        {
            _20828 = _12937;
        }
        vec3 _8218 = normalize((_20828.xyz * 2.0) - vec3(1.0));
        vec4 _20993 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.yz, _Globals_.g_vPatternTexCoordXformHalftoneB0.xy) + _Globals_.g_vPatternTexCoordXformHalftoneB0.w, dot(_19667.yz, _Globals_.g_vPatternTexCoordXformHalftoneB1.xy) + _Globals_.g_vPatternTexCoordXformHalftoneB1.w));
        vec4 _20994 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.xz, _Globals_.g_vPatternTexCoordXformHalftoneB0.xy) + _Globals_.g_vPatternTexCoordXformHalftoneB0.w, dot(_19667.xz, _Globals_.g_vPatternTexCoordXformHalftoneB1.xy) + _Globals_.g_vPatternTexCoordXformHalftoneB1.w));
        vec4 _19720 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_19667.yx, _Globals_.g_vPatternTexCoordXformHalftoneB0.xy) + _Globals_.g_vPatternTexCoordXformHalftoneB0.w, dot(_19667.yx, _Globals_.g_vPatternTexCoordXformHalftoneB1.xy) + _Globals_.g_vPatternTexCoordXformHalftoneB1.w));
        vec4 _21709;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bHalftoneInCavity != 0)
        {
            float _17464 = smoothstep(_Globals_.g_vHalftonePatternLevels.x, _Globals_.g_vHalftonePatternLevels.z, pow((min(_4306, _Globals_.g_fHalftoneCavityCutoff) * _5542) * 2.0, _Globals_.g_vHalftonePatternLevels.y));
            vec4 _12502;
            SPIRV_CROSS_BRANCH
            if (_Globals_.g_vHalftoneThresholds.x > _Globals_.g_vHalftoneThresholds.y)
            {
                vec3 _8829 = _17673.xyz * _17464;
                vec4 _8677;
                _8677.x = _8829.x;
                _8677.y = _8829.y;
                _12502 = _8677;
            }
            else
            {
                vec3 _9522 = _17673.xyz * (1.0 - _17464);
                vec4 _8676;
                _8676.x = _9522.x;
                _8676.y = _9522.y;
                _12502 = _8676;
            }
            _21709 = _12502;
        }
        else
        {
            float _17463 = smoothstep(_Globals_.g_vHalftonePatternLevels.x, _Globals_.g_vHalftonePatternLevels.z, pow((_4306 * _5542) * 2.0, _Globals_.g_vHalftonePatternLevels.y));
            vec4 _12501;
            SPIRV_CROSS_BRANCH
            if (_Globals_.g_vHalftoneThresholds.x > _Globals_.g_vHalftoneThresholds.y)
            {
                vec3 _9521 = _17673.xyz * (1.0 - _17463);
                vec4 _8675;
                _8675.x = _9521.x;
                _8675.y = _9521.y;
                _12501 = _8675;
            }
            else
            {
                vec3 _8828 = _17673.xyz * _17463;
                vec4 _8674;
                _8674.x = _8828.x;
                _8674.y = _8828.y;
                _12501 = _8674;
            }
            _21709 = _12501;
        }
        vec3 _9149 = smoothstep(vec3(_Globals_.g_vHalftoneThresholds.x), vec3(_Globals_.g_vHalftoneThresholds.y), _21709.xyz * vec3(mix(mix(_20991.xyzw, _20992.xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_8217.y), 7.0))), _19719.xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_8217.z), 7.0))).w, mix(mix(_20993.xyzw, _20994.xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_8218.y), 7.0))), _19720.xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_8218.z), 7.0))).w, _3));
        vec4 _15713;
        _15713.x = _9149.x;
        _15713.y = _9149.y;
        _22401 = _15713;
    }
    else
    {
        _22401 = _17673;
    }
    vec4 _9448 = texture(sampler2D(g_tNormal, g_sTrilinearWrap), input_1.xy);
    vec4 _19604 = smoothstep(vec4(0.85000002384185791015625), vec4(0.20000000298023223876953125), min(_9448, vec4(1.0) - _9448));
    float _4409 = mix(0.5, pow(_4306, 0.85000002384185791015625), _Globals_.g_flCaseHardeningGeometricInfluence) * mix(1.0, _5542 * (min(_19604.x, _19604.y) * 2.0), _Globals_.g_flCaseHardeningGeometricInfluence);
    float _6306 = _4409 * 2.0;
    float _3407 = max(_22401.y * _Globals_.g_flCaseHardeningPatternInfluence, ((1.0 - _5542) * 0.20000000298023223876953125) * _Globals_.g_flCaseHardeningGeometricInfluence) + _Globals_.g_flCaseHardeningRampOffset;
    vec3 _22631 = _19667.xyz + vec3(0.0, 0.00048828125, 0.00048828125);
    vec4 _12938 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
    vec4 _20829;
    SPIRV_CROSS_BRANCH
    if (_14875)
    {
        vec3 _23975 = _12938.xyz;
        vec3 _22675 = _23975 * 12.9200000762939453125;
        vec3 _7488 = (pow(_23975, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
        float _21360;
        if (_12938.x <= 0.003130800090730190277099609375)
        {
            _21360 = _22675.x;
        }
        else
        {
            _21360 = _7488.x;
        }
        float _21361;
        if (_12938.y <= 0.003130800090730190277099609375)
        {
            _21361 = _22675.y;
        }
        else
        {
            _21361 = _7488.y;
        }
        float _19170;
        if (_12938.z <= 0.003130800090730190277099609375)
        {
            _19170 = _22675.z;
        }
        else
        {
            _19170 = _7488.z;
        }
        vec4 _16676;
        _16676.x = _21360;
        _16676.y = _21361;
        _16676.z = _19170;
        _20829 = _16676;
    }
    else
    {
        _20829 = _12938;
    }
    vec3 _8219 = normalize((_20829.xyz * 2.0) - vec3(1.0));
    vec2 _14210 = _22631.yz;
    vec4 _19682 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14210, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14210, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec2 _14211 = _22631.xz;
    vec4 _19683 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14211, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14211, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec2 _14212 = _22631.yx;
    vec4 _19721 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14212, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14212, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec3 _11810 = _19667.xyz + vec3(0.0, -0.00048828125, -0.00048828125);
    vec4 _12939 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
    vec4 _20830;
    SPIRV_CROSS_BRANCH
    if (_14875)
    {
        vec3 _23976 = _12939.xyz;
        vec3 _22676 = _23976 * 12.9200000762939453125;
        vec3 _7489 = (pow(_23976, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
        float _21362;
        if (_12939.x <= 0.003130800090730190277099609375)
        {
            _21362 = _22676.x;
        }
        else
        {
            _21362 = _7489.x;
        }
        float _21363;
        if (_12939.y <= 0.003130800090730190277099609375)
        {
            _21363 = _22676.y;
        }
        else
        {
            _21363 = _7489.y;
        }
        float _19171;
        if (_12939.z <= 0.003130800090730190277099609375)
        {
            _19171 = _22676.z;
        }
        else
        {
            _19171 = _7489.z;
        }
        vec4 _16677;
        _16677.x = _21362;
        _16677.y = _21363;
        _16677.z = _19171;
        _20830 = _16677;
    }
    else
    {
        _20830 = _12939;
    }
    vec3 _8220 = normalize((_20830.xyz * 2.0) - vec3(1.0));
    vec2 _14213 = _11810.yz;
    vec4 _19684 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14213, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14213, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec2 _14214 = _11810.xz;
    vec4 _19685 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14214, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14214, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec2 _14215 = _11810.yx;
    vec4 _19722 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14215, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14215, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec3 _11811 = _19667.xyz + vec3(0.0, -0.00048828125, 0.00048828125);
    vec4 _12940 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
    vec4 _20831;
    SPIRV_CROSS_BRANCH
    if (_14875)
    {
        vec3 _23977 = _12940.xyz;
        vec3 _22677 = _23977 * 12.9200000762939453125;
        vec3 _7490 = (pow(_23977, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
        float _21364;
        if (_12940.x <= 0.003130800090730190277099609375)
        {
            _21364 = _22677.x;
        }
        else
        {
            _21364 = _7490.x;
        }
        float _21365;
        if (_12940.y <= 0.003130800090730190277099609375)
        {
            _21365 = _22677.y;
        }
        else
        {
            _21365 = _7490.y;
        }
        float _19172;
        if (_12940.z <= 0.003130800090730190277099609375)
        {
            _19172 = _22677.z;
        }
        else
        {
            _19172 = _7490.z;
        }
        vec4 _16678;
        _16678.x = _21364;
        _16678.y = _21365;
        _16678.z = _19172;
        _20831 = _16678;
    }
    else
    {
        _20831 = _12940;
    }
    vec3 _8221 = normalize((_20831.xyz * 2.0) - vec3(1.0));
    vec2 _14216 = _11811.yz;
    vec4 _19686 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14216, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14216, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec2 _14217 = _11811.xz;
    vec4 _19687 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14217, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14217, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec2 _14218 = _11811.yx;
    vec4 _19723 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14218, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14218, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w));
    vec3 _11812 = _19667.xyz + vec3(0.0, 0.00048828125, -0.00048828125);
    vec4 _12941 = texture(sampler2D(g_tSurface, g_sTrilinearClamp), input_1.xy);
    vec4 _20832;
    SPIRV_CROSS_BRANCH
    if (_14875)
    {
        vec3 _23978 = _12941.xyz;
        vec3 _22678 = _23978 * 12.9200000762939453125;
        vec3 _7491 = (pow(_23978, vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875);
        float _21366;
        if (_12941.x <= 0.003130800090730190277099609375)
        {
            _21366 = _22678.x;
        }
        else
        {
            _21366 = _7491.x;
        }
        float _21367;
        if (_12941.y <= 0.003130800090730190277099609375)
        {
            _21367 = _22678.y;
        }
        else
        {
            _21367 = _7491.y;
        }
        float _19173;
        if (_12941.z <= 0.003130800090730190277099609375)
        {
            _19173 = _22678.z;
        }
        else
        {
            _19173 = _7491.z;
        }
        vec4 _16679;
        _16679.x = _21366;
        _16679.y = _21367;
        _16679.z = _19173;
        _20832 = _16679;
    }
    else
    {
        _20832 = _12941;
    }
    vec3 _8222 = normalize((_20832.xyz * 2.0) - vec3(1.0));
    vec2 _14219 = _11812.yz;
    vec2 _14220 = _11812.xz;
    vec2 _14221 = _11812.yx;
    vec4 _19699 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + _22401.x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20630 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + mix(mix(_19682.xyzw, _19683.xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_8219.y), 7.0))), _19721.xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_8219.z), 7.0))).x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20631 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + mix(mix(_19684.xyzw, _19685.xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_8220.y), 7.0))), _19722.xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_8220.z), 7.0))).x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20632 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + mix(mix(_19686.xyzw, _19687.xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_8221.y), 7.0))), _19723.xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_8221.z), 7.0))).x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    vec4 _20633 = texture(sampler2D(g_tCaseHardeningColorRamp, g_sTrilinearClamp), vec2(mix(_6306, _4409 + mix(mix(texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14219, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14219, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w)).xyzw, texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14220, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14220, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w)).xyzw, vec4(_Globals_.g_vSprayBiasBlend.y * pow(abs(_8222.y), 7.0))), texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), vec2(dot(_14221, _Globals_.g_vPatternTexCoordXform0.xy) + _Globals_.g_vPatternTexCoordXform0.w, dot(_14221, _Globals_.g_vPatternTexCoordXform1.xy) + _Globals_.g_vPatternTexCoordXform1.w)).xyzw, vec4(_Globals_.g_vSprayBiasBlend.z * pow(abs(_8222.z), 7.0))).x, _Globals_.g_flCaseHardeningPatternInfluence), _3407));
    float _7656 = _12552.x;
    float _11437 = _12552.y;
    float _12425 = _12552.z;
    float _10779 = mix(mix(mix(_Globals_.g_vPaintDurability.x, _Globals_.g_vPaintDurability.y, _7656), _Globals_.g_vPaintDurability.z, _11437), _Globals_.g_vPaintDurability.w, _12425);
    float _4693 = _Globals_.g_fWearSoftness * _10779;
    float _22167 = smoothstep(0.560000002384185791015625 - _4693, 0.7400000095367431640625 + _4693, ((_18087.w + (_19068.x * mix(smoothstep(0.0, 0.7200000286102294921875, pow(_4306, 1.2999999523162841796875)), smoothstep(0.0, 0.4000000059604644775390625, _4306), pow(_Globals_.g_flWearAmount, 1.2000000476837158203125)))) * ((_Globals_.g_flWearAmount * 6.0) + 1.0)) * _10779);
    vec4 _9437 = texture(sampler2D(g_tGrunge, g_sTrilinearWrap), input_2.zw);
    vec4 _16529 = mix(vec4(1.0), _9437, vec4((pow(1.0 - _4306, 4.0) * 0.25) + (0.75 * _Globals_.g_flWearAmount)));
    float _7177 = mix(mix(mix(_Globals_.g_vPaintMetalness.x, _Globals_.g_vPaintMetalness.y, _7656), _Globals_.g_vPaintMetalness.z, _11437), _Globals_.g_vPaintMetalness.w, _12425);
    vec4 _7078;
    if (_Globals_.bRoughnessMode != 0)
    {
        vec4 _19391 = texture(sampler2D(g_tMetalness, g_sTrilinearClamp), input_1.xy);
        _19391.x = _19391.x;
        vec4 _19069 = texture(sampler2D(g_tPaintRoughness, g_sTrilinearWrap), input_1.xy);
        float _20271;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bRoughnessPerColor != 0)
        {
            _20271 = mix(mix(mix(_Globals_.g_vPaintRoughness.x, _Globals_.g_vPaintRoughness.y, _7656), _Globals_.g_vPaintRoughness.z, _11437), _Globals_.g_vPaintRoughness.w, _12425);
        }
        else
        {
            _20271 = _19069.x;
        }
        vec4 _13720 = mix(vec4(min(1.0, _20271 + ((((1.0 - _16529.w) * _Globals_.g_flWearAmount) * _Globals_.g_flWearAmount) * 0.5)), _7177, 0.0, 1.0), _19391, vec4(_22167));
        vec4 _20360 = texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.xy);
        float _13666 = (1.0 - _22167) * _20360.x;
        vec4 _8739 = _13720;
        _8739.z = _13666;
        vec3 _18043 = _8739.xyz * vec3(0.077399380505084991455078125);
        vec3 _7676 = pow((_8739.xyz * vec3(0.947867333889007568359375)) + vec3(0.052132703363895416259765625), vec3(2.400000095367431640625));
        float _21368;
        if (_13720.x <= 0.040449999272823333740234375)
        {
            _21368 = _18043.x;
        }
        else
        {
            _21368 = _7676.x;
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
        vec4 _17156 = vec4(_21368, _23035, _13666, min(1.0, _Globals_.g_flPearlescentScale));
        _17156.z = _19513;
        _7078 = _17156;
    }
    else
    {
        _7078 = vec4(input_1.xy, 0.0, 1.0);
    }
    vec4 _22402;
    if (_Globals_.bRoughnessMode == 0)
    {
        vec3 _6606 = (((((_19699.xyzw + _20630.xyzw).xyzw + _20631.xyzw).xyzw + _20632.xyzw).xyzw + _20633.xyzw).xyzw * 0.20000000298023223876953125).xyz;
        vec3 _24417 = mix(mix(mix(mix(_Globals_.g_vColor0.xyz, _6606, vec3(_Globals_.g_vCaseHardening.x)).xyz, mix(_Globals_.g_vColor1.xyz, _6606, vec3(_Globals_.g_vCaseHardening.y)), vec3(_7656)).xyz, mix(_Globals_.g_vColor2.xyz, _6606, vec3(_Globals_.g_vCaseHardening.z)), vec3(_11437)).xyz, mix(_Globals_.g_vColor3.xyz, _6606, vec3(_Globals_.g_vCaseHardening.w)), vec3(_12425));
        vec3 _21103 = _24417.xyz * _16529.xyz;
        vec3 _21271 = normalize(max(vec3(0.0003000000142492353916168212890625), _21103.xyz));
        vec3 _23898 = mix(_Globals_.g_vPaintAlbedoLevels.xyz, _Globals_.g_vMetallicPaintAlbedoLevels.xyz, vec3(_7177));
        _22402 = vec4(mix(mix(_21103, ((_21271.xyz * mix(min(_23898.x, dot(_24417.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _23898.z, saturate(pow(max(_21103.x, max(_21103.y, _21103.z)), _23898.y)))) / vec3(max(_21271.x, max(_21271.y, _21271.z)))).xyz, vec3(_Globals_.g_flWearAmount)), texture(sampler2D(g_tColor, g_sTrilinearClamp), input_1.xy).xyz, vec3(_22167)), 1.0);
    }
    else
    {
        _22402 = _7078;
    }
    vec4 _3300 = texture(sampler2D(g_tGlitterNormal, g_sTrilinearWrap), input_1.xy);
    vec4 _6805;
    if (_3300.w < 0.0)
    {
        vec4 _23136 = _22402;
        _23136.x = _3300.x;
        _23136.y = _3300.y;
        _23136.z = _3300.z;
        _6805 = _23136;
    }
    else
    {
        _6805 = _22402;
    }
    output_0 = _6805;
}


