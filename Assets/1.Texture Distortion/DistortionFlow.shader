Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _FlowMap ("Flow (RG, A noise)", 2D) = "black" {}
        //[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
        [NoScaleOffset] _DerivHeightMap ("Deriv (AG) Height (B)", 2D) = "black" {}
        _UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
		_VJump ("V jump per phase", Range(-0.25, 0.25)) = 0.25
		_Tiling ("Tiling", Float) = 1
		_Speed ("Speed", Float) = 1
		_FlowStrength ("Flow Strength", Float) = 1
		_FlowOffset ("Flow Offset", Float) = 0
		_HeightScale ("Height Scale, Constant", Float) = 0.25
		_HeightScaleModulated ("Height Scale, Modulated", Float) = 0.75
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "Flow.cginc"
        sampler2D _MainTex, _FlowMap,_DerivHeightMap;
        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;
        float _HeightScale , _HeightScaleModulated;
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        float3 UnpackDerivativeHeight (float4 textureData) {
			float3 dh = textureData.agb;
			dh.xy = dh.xy * 2 - 1;
			return dh;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2.0 - 1.0;
            float3 flow = tex2D(_FlowMap, IN.uv_MainTex).rgb;
			flow.xy = flow.xy * 2 - 1;
			flow *= _FlowStrength;
            //flowVector *= _FlowStrength;
            float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
			float time = _Time.y * _Speed + noise;   //用噪声对时间进行偏移
			float2 jump = float2(_UJump, _VJump);
            float3 uvwA = FlowUVW(IN.uv_MainTex,flow.xy,jump,_FlowOffset,_Tiling, time,false);
            float3 uvwB = FlowUVW(IN.uv_MainTex,flow.xy,jump,_FlowOffset,_Tiling, time,true); //flowB 的相位相对于A偏移了0.5，查看波形图，flowA + flowB 的和永远为1，即他们的比重之和为1，这就避免了之前的变黑
            
            //法线
            //float3 normalA = UnpackNormal(tex2D(_NormalMap, uvwA.xy)) * uvwA.z;
			//float3 normalB = UnpackNormal(tex2D(_NormalMap, uvwB.xy)) * uvwB.z;
			//o.Normal = normalize(normalA + normalB);
			float finalHeightScale = flow.z * _HeightScaleModulated + _HeightScale;
            float3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy)) * (uvwA.z * finalHeightScale);
			float3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy)) * (uvwB.z * finalHeightScale);
			o.Normal = normalize(float3(-(dhA.xy + dhB.xy), 1));//The resulting surface normals look almost the same as when using the normal map, they're just cheaper to compute

            
            
            //基础色
            float4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
			float4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;
            float4 c = (texA + texB) * _Color;
            
            o.Albedo = c.rgb;
            //o.Albedo = pow(dhA.z + dhB.z, 2);   //用于Debug水的高度
            o.Metallic = 0;
            o.Smoothness = _Glossiness;
            o.Alpha = 1;
            //o.Albedo = float3(flowVector, 0);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
