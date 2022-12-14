Shader "Custom/Arvore_Q2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("Texture", 2D) = "white" {}
        _NormalForce("NormalForce", Range(-2, 2)) = 1
        _SpecForce("SpecularForce", Range(0, 2)) = 1
        
        _BurningStart("BurningStartPos", float) = 0
        _BurningSlow("BurningSlowdown", float) = 1
        _BurningTex("Texture", 2D) = "white" {}
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100
            Pass
            {
                HLSLPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

               
                texture2D _MainTex;
                SamplerState sampler_MainTex;
                texture2D _NormalTex;
                SamplerState sampler_NormalTex;
                float _NormalForce;
                float _SpecForce;

                float _BurningStart;
                float _BurningSlow;
                texture2D _BurningTex;
                SamplerState sampler_BurningTex;

                struct Attributes
                {
                    float4 position : POSITION;
                    half2 uv       : TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
            
                struct Varyings 
                {
                    float4 positionVAR : SV_POSITION;
                    float4 locpositionVAR : COLOR1;
                    half2 uvVAR       : TEXCOORD0;
                    half3 normalVAR : NORMAL;
                    half4 colorVAR : COLOR0;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;
                    float3 position = Input.position.xyz;
                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.locpositionVAR = float4(position, 1);
                    Output.uvVAR = Input.uv;
                    Output.colorVAR = Input.color;
                    Output.normalVAR = TransformObjectToWorldNormal(Input.normal);

                    return Output;
                }

                half4 frag(Varyings Input) :SV_TARGET
                { 
                    half4 color = Input.colorVAR;
                    
                    Light l = GetMainLight();

                    half4 normalmap= _NormalTex.Sample(sampler_NormalTex, Input.uvVAR) * 2 - 1;

                    float intensity = dot(l.direction, Input.normalVAR+ normalmap.xzy * _NormalForce);

                    float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, Input.locpositionVAR).xyz);

                    float3 specularReflection;

                    if(intensity < 0.0)
                    {
                        specularReflection = float3(0.0, 0.0, 0.0);
                    }
                    else
                    {
                        specularReflection = l.color * pow(max(0.0, dot(
                                             reflect(-l.direction, Input.normalVAR + normalmap.xzy),
                                             viewDirection)), _SpecForce);
                    }

                    color *= clamp(0, 1, intensity);
                    if(Input.locpositionVAR.y + _BurningStart < (_Time.y / _BurningSlow))
                    {
                        color *= _BurningTex.Sample(sampler_BurningTex, Input.uvVAR);
                    }
                    else
                    {
                        color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);
                    }
                    
                
                    float step = _Time.y / _BurningSlow;
                    if(step > 1) step = 1;
                    color = lerp(_MainTex.Sample(sampler_MainTex, Input.uvVAR), _BurningTex.Sample(sampler_BurningTex, Input.uvVAR), step);
                    
                    color += float4(specularReflection, 0) * 0.05;
                    return color;
                }



            ENDHLSL
        }
    }
}
