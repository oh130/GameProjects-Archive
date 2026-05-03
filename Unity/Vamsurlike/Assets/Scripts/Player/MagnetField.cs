using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagnetField : MonoBehaviour
{
    [SerializeField] float radius;
    CircleCollider2D col;

    void Awake()
    {
        col = GetComponent<CircleCollider2D>();
        col.radius = radius;
    }

    public void ResetColliderRadius()
    {
        col.radius = radius * (1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Ion]);
    }
}
