using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectileManager : MonoBehaviour
{
    #region Variables

    /* 
    
    ProjectileManager has...
    
    1. projectile prefabs
    2. projectile pool list
    3. make spell with type, with position
      
    */

    static ProjectileManager instance;
    public static ProjectileManager Instance { get { return instance; } }

    [SerializeField] GameObject[] projectiles;

    List<GameObject>[] projectileObjectPool;

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
        projectileObjectPool = new List<GameObject>[projectiles.Length];
        for (int i = 0; i < projectiles.Length; ++i)
        {
            projectileObjectPool[i] = new List<GameObject>();
        }
    }

    public void SetProjectileObjectActive(int type, Vector2 pos)
    {
        GameObject freeObj = null;

        foreach (GameObject obj in projectileObjectPool[type])
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
            freeObj = Instantiate(projectiles[type], pos, Quaternion.identity, transform);
            projectileObjectPool[type].Add(freeObj);
        }
    }
}
