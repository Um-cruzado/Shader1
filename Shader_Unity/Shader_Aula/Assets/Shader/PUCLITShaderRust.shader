Shader "Unlit/PUCLITShaderRust"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OldTex ("OldTexture", 2D) = "white" {}
        _WindSelect("WindSelect", Range(0,1)) = 0.5
        _WindForce("WindForce", Range(-0.02, 0.02)) = 0.5
        _LeafSelect("LeafSelect", Range(1,-1)) = 0.5
        _LeafDirection("LeafDirection", Vector) = (0,0,0,0)

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

 

                float _WindSelect;
                float _WindForce;
                float _LeafSelect;
                float4 _LeafDirection;
                texture2D _MainTex;
                SamplerState sampler_MainTex;
                texture2D _OldTex;
                SamplerState sampler_OldTex;

                struct Attributes
                {
                    float4 position :POSITION;
                    half2 uv       :TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
            
                struct Varyings 
                {
                    float4 positionVAR :SV_POSITION;
                    half2 uvVAR       : TEXCOORD0;
                    half4 color : COLOR0;
                    float3 pureposition :COLOR1;
                    half3 normalVAR : NORMAL;
                };

 

                Varyings vert(Attributes Input)
                {
                    Varyings Output;
                    float3 position = Input.position.xyz;

 

                    if (Input.color.y > _WindSelect) {
                        position = Input.position.xyz + Input.normal * (cos(_Time.w) * Input.position.y * _WindForce);
                    }

 

                    Output.positionVAR = TransformObjectToHClip(position);

 

                    Output.uvVAR = Input.uv;
                    Output.pureposition = position;
                    Light l = GetMainLight();
                   
                    float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normal));
                    Output.color = Input.color;
                    

 

                    return Output;
                }
                half4 frag(Varyings Input) :SV_TARGET
                { 
                    half4 color = Input.color;
                    float force = ( dot(Input.pureposition,_LeafDirection.xyz) > _LeafSelect);
                     if (dot(Input.pureposition,_LeafDirection.xyz) > _LeafSelect) {
                    color *= _OldTex.Sample(sampler_OldTex, Input.uvVAR)*force;
                    }
                    color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);

                    

                    return color;
                }

 

 

            ENDHLSL
        }
    }
}
