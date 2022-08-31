#if !defined(FLOW_INCLUDED)
#define FLOW_INCLUDED

//获取偏移后的uv和权重
float3 FlowUVW  (float2 uv,float2 flowVector,float2 jump,float flowOffset,float tiling,float time, bool flowB) {
    
    float phaseOffset = flowB ? 0.5 : 0;    //周期1
    float progress = frac(time  + phaseOffset); //B波相对于A波偏移半个周期 0.5
    float3 uvw;
	//uvw.xy = uv -  flowVector.xy * progress + phaseOffset;
	uvw.xy = uv - flowVector * ( progress + flowOffset) ;
	uvw.xy *= tiling;   //添加了tilling之后 ，在Desmos中看到的阶梯平台不再平坦，查看 y = (t - mod(t * tiling ,1)) * jump ,tiling = 5,jump = 0.25 
	uvw.xy += phaseOffset;
	uvw.xy += (time - progress) * jump; // uvw.xy = time - frac(time + phaseOffset) ; 在Desmos中看到的是阶梯状的形状
	uvw.z = 1 - abs(1 - 2 * progress);  //w(p)=1−|1−2p| , w(p) where w(0)=w(1)=0 and w(1/2)=1
	return uvw;
}

#endif