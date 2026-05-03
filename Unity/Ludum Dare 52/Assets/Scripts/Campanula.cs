using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
public class Campanula : MonoBehaviour
{
    GameObject Player;
    PlayerControl playerStatus;
    PlantControl plantStatus;
    Light2D light2D;

    int plantLevel;
    int healingFreq = 4;
    bool isReadyToHeal = true;

    void Start()
    {
        Player = GameObject.FindWithTag("Player");
        playerStatus = Player.GetComponent<PlayerControl>();
        plantStatus = GetComponent<PlantControl>();
        light2D = transform.GetChild(0).GetComponent<Light2D>();
    }

    void Update()
    {
        if(plantStatus.growLevel != plantLevel)
        {
            plantLevel = plantStatus.growLevel;
            ManageAbility(plantLevel);
        }

        if (isReadyToHeal)
        {
            Vector2 distVector = new Vector2(Player.transform.position.x - gameObject.transform.position.x, Player.transform.position.y - gameObject.transform.position.y);
            float dist = distVector.magnitude;

            if (dist <= light2D.pointLightOuterRadius)
            {
                playerStatus.ChangeHealth(1);
                isReadyToHeal = false;
                StartCoroutine(HealingCoroutine());
            }
        }
    }

    IEnumerator HealingCoroutine()
    {
        var time = new WaitForSeconds(healingFreq);
        yield return time;
        isReadyToHeal = true;
    }

    void ManageAbility(int level)
    {
        light2D.pointLightOuterRadius = 1.5f + level;
        healingFreq = 4 - level;
    }
}
