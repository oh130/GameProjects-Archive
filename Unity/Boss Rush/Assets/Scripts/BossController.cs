using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;

public class BossController : MonoBehaviour, IBossInterface
{
    public EnemyStatus enemyStatus;

    // Health
    float currentHealth;
    public Image bossHealthBar;
    // Death
    public UnityEvent BossDeath;

    void Start()
    {
        currentHealth = enemyStatus.maxHealth;
        SetBossHealthBar(1);
    }

    void Update()
    {
        
    }

    public void Damaged(float amount)
    {
        currentHealth = Mathf.Clamp(currentHealth - amount, 0, enemyStatus.maxHealth);
        SetBossHealthBar(currentHealth / enemyStatus.maxHealth);

        if(currentHealth == 0)
        {
            BossDeath.Invoke();
        }
    }

    public void SetBossHealthBar(float percentage)
    {
        bossHealthBar.fillAmount = percentage;
    }
}
