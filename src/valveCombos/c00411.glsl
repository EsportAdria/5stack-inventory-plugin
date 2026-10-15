// static 411: S_PAINT_STYLE=6 S_OVERRIDE_NORMAL=1 S_ROUGHNESS_TEXTURE=1 S_PEARLESCENCE_MASK=1 S_SEPARATE_CHANNEL_INPUTS=1
// Source 2 Viewer 20.1.0.0 - https://valveresourceformat.github.io
// SPIR-V source, GLSL reflection with SPIRV-Cross by KhronosGroup
// Static combos: S_PAINT_STYLE=6, S_OVERRIDE_NORMAL, S_ROUGHNESS_TEXTURE, S_PEARLESCENCE_MASK, S_SEPARATE_CHANNEL_INPUTS

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

struct _1522
{
    int bRoughnessMode;
    int g_bRoughnessUsesPatternUVs;
    int g_bPearlescenceMaskUsesPatternUVs;
    float g_fWearSoftness;
    float g_flColorBrightness;
    float g_flPearlescentScale;
    float g_flPaintMetalness;
    float g_flWearAmount;
    vec3 g_vPaintAlbedoLevels;
    vec3 g_vMetallicPaintAlbedoLevels;
};

layout(set = 1) uniform _1522 _Globals_;

layout(set = 1, binding = 30) uniform texture2D g_tAmbientOcclusion;
layout(set = 1, binding = 23) uniform sampler g_sTrilinearClamp;
layout(set = 1, binding = 41) uniform texture2D g_tWear;
layout(set = 1, binding = 22) uniform sampler g_sTrilinearWrap;
layout(set = 1, binding = 40) uniform texture2D g_tPattern;
layout(set = 1, binding = 27) uniform sampler AddressU_dynamic_AddressV_dynamic;
layout(set = 1, binding = 42) uniform texture2D g_tGrunge;
layout(set = 1, binding = 35) uniform texture2D g_tMetalness;
layout(set = 1, binding = 37) uniform texture2D g_tPaintRoughness;
layout(set = 1, binding = 38) uniform texture2D g_tPearlescenceMask;
layout(set = 1, binding = 34) uniform texture2D g_tColor;
layout(set = 1, binding = 36) uniform texture2D g_tNormal;
layout(set = 1, binding = 39) uniform texture2D g_tGlitterNormal;

layout(location = 1) in vec4 input_1;
layout(location = 2) in vec4 input_2;
layout(location = 0) out vec4 output_0;

void main()
{
    vec4 _18087 = texture(sampler2D(g_tAmbientOcclusion, g_sTrilinearClamp), input_1.xy);
    float _4306 = pow(_18087.x, 1.5) * 0.959999978542327880859375;
    vec4 _19334 = texture(sampler2D(g_tWear, g_sTrilinearWrap), input_2.xy);
    vec4 _11743 = texture(sampler2D(g_tPattern, AddressU_dynamic_AddressV_dynamic), input_1.zw);
    float _19155 = _11743.w;
    float _17710 = max(0.0, smoothstep(0.0, 0.5, _19155));
    float _4693 = _Globals_.g_fWearSoftness * _17710;
    float _22167 = smoothstep(0.560000002384185791015625 - _4693, 0.7400000095367431640625 + _4693, (((_18087.w + (_19334.x * mix(smoothstep(0.0, 0.7200000286102294921875, pow(_4306, 1.2999999523162841796875)), smoothstep(0.0, 0.4000000059604644775390625, _4306), pow(_Globals_.g_flWearAmount, 1.2000000476837158203125)))) * ((_Globals_.g_flWearAmount * 6.0) + 1.0)) + (smoothstep(0.5, 0.60000002384185791015625, _19155) * smoothstep(1.0, 0.89999997615814208984375, _19155))) * _17710);
    vec4 _9437 = texture(sampler2D(g_tGrunge, g_sTrilinearWrap), input_2.zw);
    vec4 _16529 = mix(vec4(1.0), _9437, vec4((pow(1.0 - _4306, 4.0) * 0.25) + (0.75 * _Globals_.g_flWearAmount)));
    vec4 _7078;
    if (_Globals_.bRoughnessMode != 0)
    {
        vec4 _19391 = texture(sampler2D(g_tMetalness, g_sTrilinearClamp), input_1.xy);
        _19391.x = _19391.x;
        float _20271;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bRoughnessUsesPatternUVs != 0)
        {
            _20271 = texture(sampler2D(g_tPaintRoughness, g_sTrilinearWrap), input_1.zw).x;
        }
        else
        {
            _20271 = texture(sampler2D(g_tPaintRoughness, g_sTrilinearWrap), input_1.xy).x;
        }
        vec4 _13796 = mix(vec4(min(1.0, _20271 + ((((1.0 - _16529.w) * _Globals_.g_flWearAmount) * _Globals_.g_flWearAmount) * 0.5)), _Globals_.g_flPaintMetalness, 0.0, 1.0), _19391, vec4(_22167));
        float _13803 = 1.0 - _22167;
        vec4 _21709;
        SPIRV_CROSS_BRANCH
        if (_Globals_.g_bPearlescenceMaskUsesPatternUVs != 0)
        {
            vec4 _18602 = _13796;
            _18602.z = _13803 * texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.zw).x;
            _21709 = _18602;
        }
        else
        {
            float _24237 = _13803 * texture(sampler2D(g_tPearlescenceMask, g_sTrilinearWrap), input_1.xy).x;
            vec4 _9184 = _13796;
            _9184.z = _24237 * _24237;
            _21709 = _9184;
        }
        vec3 _18043 = _21709.xyz * vec3(0.077399380505084991455078125);
        vec3 _7676 = pow((_21709.xyz * vec3(0.947867333889007568359375)) + vec3(0.052132703363895416259765625), vec3(2.400000095367431640625));
        float _21354;
        if (_21709.x <= 0.040449999272823333740234375)
        {
            _21354 = _18043.x;
        }
        else
        {
            _21354 = _7676.x;
        }
        float _21355;
        if (_21709.y <= 0.040449999272823333740234375)
        {
            _21355 = _18043.y;
        }
        else
        {
            _21355 = _7676.y;
        }
        float _22686;
        if (_21709.z <= 0.040449999272823333740234375)
        {
            _22686 = _18043.z;
        }
        else
        {
            _22686 = _7676.z;
        }
        _7078 = vec4(_21354, _21355, _22686, min(1.0, _Globals_.g_flPearlescentScale));
    }
    else
    {
        _7078 = vec4(input_1.xy, 0.0, 1.0);
    }
    vec4 _22401;
    if (_Globals_.bRoughnessMode == 0)
    {
        vec3 _19076 = saturate(_11743.xyz * _Globals_.g_flColorBrightness);
        vec3 _21103 = _19076.xyz * _16529.xyz;
        vec3 _21271 = normalize(max(vec3(0.0003000000142492353916168212890625), _21103.xyz));
        vec3 _23898 = mix(_Globals_.g_vPaintAlbedoLevels.xyz, _Globals_.g_vMetallicPaintAlbedoLevels.xyz, vec3(_Globals_.g_flPaintMetalness));
        _22401 = vec4(mix(mix(_21103, ((_21271.xyz * mix(min(_23898.x, dot(_19076.xyz, vec3(0.2125000059604644775390625, 0.7153999805450439453125, 0.07209999859333038330078125))), _23898.z, saturate(pow(max(_21103.x, max(_21103.y, _21103.z)), _23898.y)))) / vec3(max(_21271.x, max(_21271.y, _21271.z)))).xyz, vec3(_Globals_.g_flWearAmount)), texture(sampler2D(g_tColor, g_sTrilinearClamp), input_1.xy).xyz, vec3(_22167)), 1.0);
    }
    else
    {
        _22401 = _7078;
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


