#if !defined(FLOW_INCLUDED)
#define FLOW_INCLUDED

float3 FlowUVW  (float2 uv,float2 flowVector, float time) {
    float progress = frac(time);
    float3 uvw;
	uvw.xy = uv -  flowVector.xy * progress;
	uvw.z = 1 - abs(1 - 2 * progress);  //w(p)=1−|1−2p| , w(p) where w(0)=w(1)=0 and w(1/2)=1
	return uvw;
}

#endif