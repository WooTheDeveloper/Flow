#if !defined(FLOW_INCLUDED)
#define FLOW_INCLUDED

float2 FlowUVW  (float2 uv,float2 flowVector, float time) {
    float progress = frac(time);
    float3 uvw;
	uvw.xy = uv -  flowVector.xy * progress;
	uvw.z = 1;
	return uvw;
}

#endif