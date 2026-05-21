using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;

public class GlobalLightControl : MonoBehaviour
{
    public static bool isNight;
    public static int day;

    public Text enemyStatus;
    public Text text;
    public Text dayText;

    Light2D light2D;
    Color32 danger;
    Color32 safe;
    float halfOfTheDay = 60;
    bool timeToChange = false;
    bool onChange = false;

    void Awake()
    {
        day = 0;
        isNight = false;
        light2D = GetComponent<Light2D>();
        danger = new Color(1.000f, 0.000f, 0.000f, 1.000f);
        safe = new Color(0.000f, 1.000f, 0.000f, 1.000f);
        StartCoroutine(lightCoroutine());
    }

    void Update()
    {
        if (timeToChange)
        {
            timeToChange = false;
            onChange = true;
        }

        if (onChange)
        {
            if (isNight)
            {
                light2D.intensity += 0.065f * Time.deltaTime;

                if (light2D.intensity >= 0.65f)
                {
                    light2D.intensity = 0.65f;
                    isNight = false;
                    onChange = false;
                    StartCoroutine(lightCoroutine());
                }
            }
            else
            {
                light2D.intensity -= 0.065f * Time.deltaTime;

                if (light2D.intensity <= 0)
                {
                    light2D.intensity = 0;
                    isNight = true;
                    onChange = false;
                    StartCoroutine(lightCoroutine());
                }
            }
        }
    }

    IEnumerator lightCoroutine()
    {
        if (isNight)
        {
            BGM.instance.PlayBGM(true);
            enemyStatus.color = danger;
            text.color = danger;
            dayText.color = danger;
        }
        else
        {
            BGM.instance.PlayBGM(false);
            enemyStatus.color = safe;
            text.color = safe;
            day++;
            dayText.text = day.ToString();
            dayText.color = safe;
            KillAllEnemy();
        }

        var time = new WaitForSeconds(halfOfTheDay);
        yield return time;
        timeToChange = true;
    }

    void KillAllEnemy()
    {
        foreach(GameObject enemy in GameManager.enemySpawnArray)
        {
            if (enemy.activeSelf)
            {
                enemy.GetComponent<EnemyControl>().Attacked(99999);
            }
        }
    }
}
