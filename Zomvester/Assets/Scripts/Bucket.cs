using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bucket : MonoBehaviour
{
    public GameObject[] buckets;

    public bool Filled()
    {
        for (int i = 4; i >= 0; --i)
        {
            if (buckets[i].activeSelf)
            {
                if (i == 4) return false;
                return true;
            }
            buckets[i].SetActive(true);
        }

        return true;
    }

    public void Used(int now)
    {
        buckets[now].SetActive(false);
    }
}
