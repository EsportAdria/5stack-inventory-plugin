// static 5021: S_PAINT_STYLE=8 S_OVERRIDE_NORMAL=1 S_ROUGHNESS_TEXTURE=1 S_PEARLESCENCE_MASK=1 S_SEPARATE_CHANNEL_INPUTS=1 S_PATINA_AGE=1
// Source 2 Viewer 20.1.0.0 - https://valveresourceformat.github.io
// SPIR-V source, GLSL reflection with SPIRV-Cross by KhronosGroup
// Static combos: S_PAINT_STYLE=8, S_OVERRIDE_NORMAL, S_ROUGHNESS_TEXTURE, S_PEARLESCENCE_MASK, S_SEPARATE_CHANNEL_INPUTS, S_PATINA_AGE

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

vec4 _2;

struct _2303
{
    int bRoughnessMode;
    vec3 g_vAlbedoLevels;
    vec3 g_vDarkMetallicAlbedoLevels;
    vec3 g_vMetallicAlbedoLevels;
    int g_bRoughnessUsesPatternUVs;
    int g_bPearlescenceMaskUsesPatternUVs;
    float g_fWearSoftness;
    vec3 g_vColor1;
    float g_flPearlescentScale;
    int g_bPearlescentOnMetallicOnly;
    float g_flPaintMetalness;
    float g_flWearAmount;
    float g_flPatinaAgeStart;
    float g_flPatinaColorize;
    vec3 g_vPaintAlbedoLevels;
    vec3 g_vMetallicPaintAlbedoLevels;
};

layout(set = 1) uniform _2303 _Globals_;

layout(set = 1, binding = 30) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 23) uniform sampler g_sTrilinearClamp;
layout(set = 1, binding = 31) uniform texture2D g_tMasks;
layout(set = 1, binding = 41) uniform texture2D g_tWear;
layout(set = 1, binding = 22) uniform sampler g_sTrilinearWrap;
layout(set = 1, binding = 40) uniform texture2D g_tPattern;
layout(set = 1, binding = 27) uniform sampler AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 42) uniform texture2D g_tGrunge;
layout(set = 1, binding = 33) uniform texture2D g_tPosition;
layout(set = 1, binding = 44) uniform texture2D g_tPatinaAgeMask;
layout(set = 1, binding = 36) uniform texture2D g_tNormal;
layout(set = 1, binding = 43) uniform texture2D g_tPatinaAgeColorRamp;
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
    vec4 _19372 = texture(sampler2D(g_tMasks, g_sTrilinearClamp), input_1.xy);
    float _17150 = _19372.x;
    float _13255 = 1.0 - _17150;
    vec4 _19334 = texture(sampler2D(g_tWear, g_sTrilinearWrap), input_2.xy);
    float _5744 = _19334.x;
    vec4 _11743 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), input_1.zw);
    float _19155 = _11743.w;
    float _17710 = max(0.0, smoothstep(0.0, 0.5, _19155));
    float _10193 = (((min(_18087.w, _13255) + (_5744 * mix(smoothstep(0.0, 0.7200000286102294921875, pow(_4306, 1.2999999523162841796875)), smoothstep(0.0, 0.4000000059604644775390625, _4306), pow(_Globals_.g_flWearAmount, 1.2000000476837158203125)))) * ((_Globals_.g_flWearAmount * 6.0) + 1.0)) + (smoothstep(0.5, 0.60000002384185791015625, _19155) * smoothstep(1.0, 0.89999997615814208984375, _19155))) * _17710;
    float _4693 = _Globals_.g_fWearSoftness * _17710;
    bool _18318 = _17150 > 0.9900000095367431640625;
    float _6760 = mix(smoothstep(0.579999983310699462890625 - _4693, 0.680000007152557373046875 + _4693, _10193), _10193, float(_18318));
    vec4 _22452 = texture(sampler2D(g_tGrunge, g_sTrilinearWrap), input_2.zw);
    vec4 _9437 = texture(sampler2D(g_tPosition, g_sTrilinearClamp), input_1.xy);
    float _19621 = 1.0 - _4306;
    float _16758 = pow(_19621, 4.0) * 0.25;
    vec4 _20360 = texture(sampler2D(g_tPatinaAgeMask, g_sTrilinearWrap), input_1.xy);
    float _3378 = _20360.x;
    vec3 _18769 = vec3(_17150);
    vec3 _25191 = mix(vec3(mix(1.0, saturate(pow(dot(_22452.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125)), 0.25) * 2.0), _16758 + (_16758 + (0.75 * _Globals_.g_flWearAmount)))), _22452.xyz, _18769);
    float _20401 = _25191.x;
    vec4 _17842;
    _17842.x = _20401;
    float _21813 = _25191.y;
    _17842.y = _21813;
    float _20528 = _25191.z;
    _17842.z = _20528;
    float _15835 = mix(_Globals_.g_flPatinaAgeStart, 0.89999997615814208984375, pow(_Globals_.g_flWearAmount, 0.5));
    vec4 _9448 = texture(sampler2D(g_tNormal, g_sTrilinearWrap), input_1.xy);
    vec4 _19604 = smoothstep(vec4(0.0500000007450580596923828125), vec4(0.5), min(_9448, vec4(1.0) - _9448));
    float _19413 = min(1.0 - pow(smoothstep(0.0, 0.100000001490116119384765625 + (_5744 * 0.3300000131130218505859375), _4306), 4.0), mix(smoothstep(0.20000000298023223876953125, 0.4199999868869781494140625, _9437.z) * _Globals_.g_flWearAmount, 0.0, _3378 * _19621));
    vec4 _11525 = textureLod(sampler2D(g_tPatinaAgeColorRamp, g_sTrilinearClamp), vec2(max(min(((pow(smoothstep(0.5, 1.0, _19621), 2.0) * (_5744 + (1.0 - (_19604.x * _19604.y)))) + (_15835 * 0.75)) * mix(0.001000000047497451305389404296875, 1.0, pow(mix(_15835, 0.0, _3378), 0.89999997615814208984375)), 0.995999991893768310546875), 0.0040000001899898052215576171875), 0.5), 0.0);
    float _11617 = _11525.w;
    vec3 _9777 = _11525.xyz;
    vec3 _24045 = normalize(max(vec3(0.0003000000142492353916168212890625), mix(_17842.xyz, _9777, vec3(0.800000011920928955078125)).xyz)) * 1.059999942779541015625;
    float _6670 = dot(saturate(_17842.xyz * 1.0).xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125));
    vec3 _12903 = vec3(_11617);
    vec3 _12755 = mix(_Globals_.g_vAlbedoLevels, mix(_Globals_.g_vMetallicAlbedoLevels, _Globals_.g_vDarkMetallicAlbedoLevels, vec3(smoothstep(0.550000011920928955078125, 0.0155999995768070220947265625, _6670))), _12903);
    float _20079 = mix(_Globals_.g_vAlbedoLevels.x, _Globals_.g_vDarkMetallicAlbedoLevels.x, _11617);
    vec3 _22776 = _24045.xyz;
    vec3 _18437 = mix(_17842.xyz, mix(vec3(_20079), max((((_22776 * _20079) * 1.73199999332427978515625) / vec3(length(_22776))) / vec3(dot(_24045.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _24045 * mix(_12755.x, _12755.z, saturate(pow(max(_20401, max(_21813, _20528)), _12755.y)))).xyz, vec3(pow(smoothstep(0.0003000000142492353916168212890625, _20079, _6670), 0.5))), _18769);
    vec4 _17843;
    _17843.x = _18437.x;
    _17843.y = _18437.y;
    _17843.z = _18437.z;
    float _10247;
    vec4 _11711;
    if (_Globals_.bRoughnessMode != 0)
    {
        vec4 _20322 = texture(sampler2D(g_tMetalness, g_sTrilinearClamp), input_1.xy);
        float _6667 = 1.0 - _6760;
        float _21903;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bRoughnessUsesPatternUVs != 0)
        {
            _21903 = texture(sampler2D(g_tPaintRoughness, g_sTrilinearWrap), input_1.zw).x;
        }
        else
        {
            _21903 = texture(sampler2D(g_tPaintRoughness, g_sTrilinearWrap), input_1.xy).x;
        }
        float _14026 = mix(1.0, 0.0, _11617);
        float _21074 = mix(_21903, 0.5 * ((2.0 - dot(_17843.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))) - _5744), max(_19413, _11617));
        vec4 _13436;
        _13436.x = mix(_20322.x, mix(min(1.0, _21074 + ((((1.0 - _22452.w) * _Globals_.g_flWearAmount) * _Globals_.g_flWearAmount) * 0.5)), _21074, _17150), _18318 ? 1.0 : max(0.0, _6667));
        _13436.y = mix(mix(_Globals_.g_flPaintMetalness, _20322.y, _6760), _14026, _17150);
        vec4 _21709;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bPearlescenceMaskUsesPatternUVs != 0)
        {
            vec4 _18602 = _13436;
            _18602.z = _6667 * texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.zw).x;
            _21709 = _18602;
        }
        else
        {
            float _24237 = _6667 * texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.xy).x;
            vec4 _9184 = _13436;
            _9184.z = _24237 * _24237;
            _21709 = _9184;
        }
        vec4 _21710;
        if (_Globals_.g_bPearlescentOnMetallicOnly != 0)
        {
            vec4 _18603 = _21709;
            _18603.z = _21709.z * _17150;
            _21710 = _18603;
        }
        else
        {
            _21710 = _21709;
        }
        vec3 _18043 = _21710.xyz * vec3(0.077399380505084991455078125);
        vec3 _7676 = pow((_21710.xyz * vec3(0.947867333889007568359375)) + vec3(0.052132703363895416259765625), vec3(2.400000095367431640625));
        float _21354;
        if (_21710.x <= 0.040449999272823333740234375)
        {
            _21354 = _18043.x;
        }
        else
        {
            _21354 = _7676.x;
        }
        float _21355;
        if (_21710.y <= 0.040449999272823333740234375)
        {
            _21355 = _18043.y;
        }
        else
        {
            _21355 = _7676.y;
        }
        float _22686;
        if (_21710.z <= 0.040449999272823333740234375)
        {
            _22686 = _18043.z;
        }
        else
        {
            _22686 = _7676.z;
        }
        _11711 = vec4(_21354, _21355, _22686, min(1.0, _Globals_.g_flPearlescentScale));
        _10247 = _14026;
    }
    else
    {
        _11711 = vec4(input_1.xy, 0.0, 1.0);
        _10247 = 1.0;
    }
    vec4 _22401;
    if (_Globals_.bRoughnessMode == 0)
    {
        vec3 _14791 = _11743.xyz;
        vec3 _13560 = _11525.xyz;
        vec3 _14274 = _11743.xyz;
        vec3 _10732 = normalize(max(vec3(0.0003000000142492353916168212890625), mix(_13560 * _14274, _13560, vec3(_Globals_.g_flPatinaColorize)).xyz)) * 1.059999942779541015625;
        float _6671 = dot(saturate(_14274 * 1.0).xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125));
        vec3 _9366 = mix(_Globals_.g_vMetallicAlbedoLevels, _Globals_.g_vDarkMetallicAlbedoLevels, vec3(smoothstep(0.550000011920928955078125, 0.0155999995768070220947265625, _6671)));
        vec3 _22777 = _10732.xyz;
        vec3 _10517 = mix(_14791, mix(mix(vec3(_Globals_.g_vDarkMetallicAlbedoLevels.x), max((((_22777 * _Globals_.g_vDarkMetallicAlbedoLevels.x) * 1.73199999332427978515625) / vec3(length(_22777))) / vec3(dot(_10732.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _10732 * mix(_9366.x, _9366.z, saturate(pow(max(_11743.x, max(_11743.y, _11743.z)), _9366.y)))).xyz, vec3(pow(smoothstep(0.0003000000142492353916168212890625, _Globals_.g_vDarkMetallicAlbedoLevels.x, _6671), 0.5))), _9777, _12903), _18769).xyz;
        vec3 _18418 = mix(_10517 * _17843.xyz, mix(_10517, _17843.xyz, vec3(_19413)), _18769);
        vec3 _21271 = normalize(max(vec3(0.0003000000142492353916168212890625), _18418.xyz));
        vec3 _23898 = mix(_Globals_.g_vPaintAlbedoLevels.xyz, _Globals_.g_vMetallicPaintAlbedoLevels.xyz, vec3(mix(_Globals_.g_flPaintMetalness, _10247, _17150)));
        vec3 _25172 = mix(mix(_18418, ((_21271.xyz * mix(min(_23898.x, dot(mix(_14791, _14791 * _Globals_.g_vColor1, _18769).xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _23898.z, saturate(pow(max(_18418.x, max(_18418.y, _18418.z)), _23898.y)))) / vec3(max(_21271.x, max(_21271.y, _21271.z)))).xyz, vec3(_Globals_.g_flWearAmount)), texture(sampler2D(g_tColor, g_sTrilinearClamp), input_1.xy).xyz, vec3(_6760 * _13255));
        _22401 = vec4(_25172, 1.0);
    }
    else
    {
        _22401 = _11711;
    }
    vec4 _21329 = texture(sampler2D(g_tNormal, g_sTrilinearWrap), input_1.xy);
    vec4 _22402;
    if (_21329.w < 0.0)
    {
        vec4 _23135 = _22401;
        _23135.x = _21329.x;
        _23135.y = _21329.y;
        _23135.z = _21329.z;
        _22402 = _23135;
    }
    else
    {
        _22402 = _22401;
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


