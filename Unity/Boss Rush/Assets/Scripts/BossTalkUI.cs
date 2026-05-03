using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossTalkUI : MonoBehaviour
{
    public Transform target;
    public Vector3 pos;

    void Start()
    {
        transform.position = Camera.main.WorldToScreenPoint(target.position + pos);
    }

    void Update()
    {
        transform.position = Camera.main.WorldToScreenPoint(target.position + pos);
    }
}
