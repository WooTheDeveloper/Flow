using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyTest : MonoBehaviour
{
    public float myTime;
    public string _MyTime = "_MyTime";

    private void Reset()
    {
        myTime = 0f;
    }

    private void Update()
    {
        myTime += Time.deltaTime;
        Shader.SetGlobalVector(_MyTime,new Vector4(0,myTime,0,0));
    }
}
