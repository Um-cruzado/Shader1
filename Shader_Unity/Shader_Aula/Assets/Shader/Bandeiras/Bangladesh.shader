Shader "Unlit/Bangladesh"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM 
                #pragma vertex vert
                #pragma fragment frag
                #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

 

                struct Attributes
                {
                    float4 position :POSITION;
                    float2 uv :TEXCOORD0;
                };
            
                struct Varyings 
                {
                    float4 positionVAR :SV_POSITION;
                    float2 uvVAR :TEXCOORD0;
 

                };

 

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

 

                    Output.positionVAR = TransformObjectToHClip(Input.position.xyz);

 
                    Output.uvVAR = Input.uv;
                    //Output.positionVAR = Input.position;

 

                    return Output;
                }
                float4 frag(Varyings Input) :SV_TARGET
                {
                    float2 center_pos = float2(0.5, 1.0);
                    float circle = length(float2(Input.uvVAR.x, Input.uvVAR.y*1.55) - center_pos);

                    float4 color = float4(0.07,0.62,0,1);
                    if(circle < 0.3)//Input.uvVAR.y > 0.5)
                        color = float4(0.88,0,0,1);
                    
                    return color;
                }

 

 

            ENDHLSL
        }
    }
}
