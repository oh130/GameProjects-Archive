using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NepenthesProjectile : MonoBehaviour
{
    int damage = 7;
    float currentLifeTime = 0;
    float projectileLife = 1.0f;

    void Update()
    {
        currentLifeTime += Time.deltaTime;

        if(currentLifeTime >= projectileLife)
        {
            currentLifeTime = 0;
            gameObject.SetActive(false);
        }
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Enemy"))
        {
            collision.GetComponent<EnemyControl>().Attacked(damage);
        }

        currentLifeTime = 0;
        gameObject.SetActive(false);
    }
}
