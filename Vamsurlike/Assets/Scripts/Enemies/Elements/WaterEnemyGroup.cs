using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterEnemyGroup : MonoBehaviour
{
    int currentChildCount;

    void OnEnable()
    {
        currentChildCount = GameManager.Instance.WaterGroupCount;

        foreach (Transform child in transform)
        {
            child.gameObject.SetActive(true);
        }
    }

    public void ChildDie()
    {
        if(--currentChildCount == 0)
        {
            this.gameObject.SetActive(false);
        }
    }
}
