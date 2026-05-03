using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForDebug : MonoBehaviour
{
    public float timeScale = 1f;

    void Update()
    {
        Time.timeScale = timeScale;
    }
}
