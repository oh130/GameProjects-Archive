using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectableManager : MonoBehaviour
{
    #region Variables

    static CollectableManager instance;
    public static CollectableManager Instance { get { return instance; } }

    [SerializeField] GameObject[] collectables;

    List<GameObject>[] collectableObjectPool;

    #endregion

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if (instance != this)
        {
            Destroy(this.gameObject);
        }

        // object pool init
        collectableObjectPool = new List<GameObject>[collectables.Length];
        for (int i = 0; i < collectables.Length; ++i)
        {
            collectableObjectPool[i] = new List<GameObject>();
        }
    }

    public void SetCollectableObjectActive(int type, Vector2 pos)
    {
        GameObject freeObj = null;

        foreach (GameObject obj in collectableObjectPool[type])
        {
            if (!obj.activeSelf)
            {
                freeObj = obj;
                freeObj.transform.position = pos;
                freeObj.SetActive(true);
                break;
            }
        }

        if (!freeObj)
        {
            freeObj = Instantiate(collectables[type], pos, Quaternion.identity, transform);
            collectableObjectPool[type].Add(freeObj);
        }
    }
}
