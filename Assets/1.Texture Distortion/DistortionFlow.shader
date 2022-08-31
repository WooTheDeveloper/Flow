Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _FlowMap ("Flow (RG, A noise)", 2D) = "black" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
		_VJump ("V jump per phase", Range(-0.25, 0.25)) = 0.25
		_Tiling ("Tiling", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard 

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "Flow.cginc"
        sampler2D _MainTex, _FlowMap;
        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _UJump, _VJump, _Tiling;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2.0 - 1.0;
            float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
			float time = _Time.y + 0;   //用噪声对时间进行偏移
			float2 jump = float2(_UJump, _VJump);
            float3 uvwA = FlowUVW(IN.uv_MainTex,flowVector,jump,_Tiling, time,false);
            float3 uvwB = FlowUVW(IN.uv_MainTex,flowVector,jump,_Tiling, time,true); //flowB 的相位相对于A偏移了0.5，查看波形图，flowA + flowB 的和永远为1，即他们的比重之和为1，这就避免了之前的变黑
            float4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
			float4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;
            float4 c = (texA + 0) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = 0;
            o.Smoothness = 0;
            o.Alpha = 1;
            //o.Albedo = float3(flowVector, 0);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
