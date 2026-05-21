using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyManager : MonoBehaviour
{
    #region Variables

    /* 
    
    EnemyManager has...
    
    1. enemy prefabs
    2. enemy pool list
    3. spawn points
    4. spawn enemy with type
      
    */

    [SerializeField] GameObject[] enemies;
    [SerializeField] List<Transform> spawnPoints;
    [SerializeField] float[] spawnCooldowns;
    [SerializeField] int[] enemyCountPerSpawn;
    [SerializeField] float[] firstSpawnCooldowns;

    List<GameObject>[] enemyObjectPool;
    WaitForSeconds[] enemySpawnCooldowns;

    #endregion

    void Awake()
    {
        // init
        enemyObjectPool = new List<GameObject>[enemies.Length];
        enemySpawnCooldowns = new WaitForSeconds[enemies.Length];

        for (int i = 0; i < enemies.Length; ++i)
        {
            enemyObjectPool[i] = new List<GameObject>();
            enemySpawnCooldowns[i] = new WaitForSeconds(spawnCooldowns[i]);
            StartCoroutine(SpawnEnemy(i));
        } 
    }

    IEnumerator SpawnEnemy(int typeNumber)
    {
        yield return new WaitForSeconds(firstSpawnCooldowns[typeNumber]);

        while (!GameManager.Instance.PlayerDeath)
        {
            for (int i = 0; i < enemyCountPerSpawn[typeNumber]; ++i)
            {
                SetEnemyObjectActive(typeNumber);
            }
            yield return enemySpawnCooldowns[typeNumber];
        }
    }

    void SetEnemyObjectActive(int type)
    {
        GameObject freeObj = null;
        Vector2 pos = spawnPoints[Random.Range(0, spawnPoints.Count)].position;

        foreach (GameObject obj in enemyObjectPool[type])
        {
            if(!obj.activeSelf)
            {
                freeObj = obj;
                freeObj.transform.position = pos;
                freeObj.SetActive(true);
                break;
            }
        }

        if (!freeObj)
        {
            freeObj = Instantiate(enemies[type], pos, Quaternion.identity, transform);
            enemyObjectPool[type].Add(freeObj);
        }
    }

    public void SpawnCooldownChange()
    {

    }
}
