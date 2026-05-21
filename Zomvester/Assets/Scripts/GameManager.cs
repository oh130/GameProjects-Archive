using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    [SerializeField] GameObject zombie;
    [SerializeField] GameObject player;
    [SerializeField] GameObject nepenthesProj;
    [SerializeField] GameObject[] plants;
    [SerializeField] Text enemyStatus;

    float enemySpawnTime;
    float standardSpawnTime = 2f;
    int currentStatus = 0;
    int enemyStatusPlusTime = 5;
    bool statusChange;
    bool enemySpawnAvailable;

    const int maxEnemySpawnCount = 600;
    const int maxPlantSpawnCount = 600;
    const int maxProjectileSpawnCount = 1200;

    static int enemySpawnIdx;
    static int plantSpawnIdx;
    static int projectileSpawnIdx;

    PlayerControl playerControl;
    public static GameObject[] enemySpawnArray;
    public static GameObject[] plantSpawnArray;
    public static GameObject[] projectileSpawnArray;

    void Awake()
    {
        enemySpawnArray = new GameObject[maxEnemySpawnCount];
        plantSpawnArray = new GameObject[maxPlantSpawnCount];
        projectileSpawnArray = new GameObject[maxProjectileSpawnCount];

        enemySpawnIdx = 0;
        plantSpawnIdx = 0;
        projectileSpawnIdx = 0;

        for (int i = 0; i < maxEnemySpawnCount; ++i)
        {
            GameObject enemy = Instantiate(zombie);
            enemy.SetActive(false);
            enemySpawnArray[i] = enemy;
        }

        for (int i = 0; i < maxPlantSpawnCount; ++i)
        {
            GameObject plant = Instantiate(plants[Random.Range(0,4)]);
            plant.SetActive(false);
            plantSpawnArray[i] = plant;
        }

        for (int i = 0; i < maxProjectileSpawnCount; ++i)
        {
            GameObject projectile = Instantiate(nepenthesProj);
            projectile.SetActive(false);
            projectileSpawnArray[i] = projectile;
        }
    }

    void Start()
    {
        enemySpawnTime = standardSpawnTime;
        playerControl = player.GetComponent<PlayerControl>();
        StartCoroutine(SpawnCoroutine());
        StartCoroutine(EnemyStatusUp());
    }

    void Update()
    {
        if (playerControl.isDie) return;

        if (enemySpawnAvailable)
        {
            enemySpawnAvailable = false;
            EnemySpawn();
            StartCoroutine(SpawnCoroutine());
        }

        if (statusChange)
        {
            statusChange = false;
            currentStatus++;
            if(GlobalLightControl.isNight) enemyStatus.text = "x" + (1f + currentStatus * 0.1f).ToString("F1");
            else enemyStatus.text = "x" + ((1f + currentStatus * 0.1f) * 0.7f).ToString("F1");
            StartCoroutine(EnemyStatusUp());
        }
    }

    void EnemySpawn()
    {
        float randX;
        float randY;
        int randNum = Random.Range(0, 4);

        switch (randNum)
        {
            case 0:
                randX = Random.Range(1.05f, 1.1f);
                randY = Random.Range(-1.1f, 1.1f);
                break;
            case 1:
                randX = Random.Range(-1.1f, -1.05f);
                randY = Random.Range(-1.1f, 1.1f);
                break;
            case 2:
                randX = Random.Range(-1.1f, 1.1f);
                randY = Random.Range(1.05f, 1.1f);
                break;
            default:
                randX = Random.Range(-1.1f, 1.1f);
                randY = Random.Range(-1.1f, -1.05f);
                break;
        }

        GameObject enemy = enemySpawnArray[enemySpawnIdx];
        enemySpawnIdx = (enemySpawnIdx + 1) % maxEnemySpawnCount;
        enemy.transform.position = Camera.main.ViewportToWorldPoint(new Vector3(randX, randY, 10));
        enemy.GetComponent<EnemyControl>().init(1f + currentStatus * 0.1f);
        enemy.SetActive(true);
    }

    IEnumerator SpawnCoroutine()
    {
        if (GlobalLightControl.isNight) enemySpawnTime = standardSpawnTime;
        else enemySpawnTime = standardSpawnTime * 2.5f;

        var time = new WaitForSeconds(enemySpawnTime);
        yield return time;
        enemySpawnAvailable = true;
    }

    IEnumerator EnemyStatusUp()
    {
        var time = new WaitForSeconds(enemyStatusPlusTime);
        yield return time;
        statusChange = true;
    }

    public static void MakePlant(Vector2 pos)
    {
        GameObject plant = plantSpawnArray[plantSpawnIdx];
        plantSpawnIdx = (plantSpawnIdx + 1) % maxPlantSpawnCount;
        plant.transform.position = pos;
        plant.SetActive(true);
    }

    public static GameObject MakeProjectile(Vector2 pos)
    {
        GameObject projectile = projectileSpawnArray[projectileSpawnIdx];
        projectileSpawnIdx = (projectileSpawnIdx + 1) % maxProjectileSpawnCount;
        projectile.transform.position = pos;
        projectile.SetActive(true);

        return projectile;
    }

    public static void GameOver()
    {
        SceneManager.LoadScene("Gameover");
    }
}
