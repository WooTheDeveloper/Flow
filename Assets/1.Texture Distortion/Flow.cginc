#if !defined(FLOW_INCLUDED)
#define FLOW_INCLUDED

float2 FlowUV (float2 uv,float2 flowVector, float time) {
    
	return uv -  flowVector.xy * time;
}

#endif