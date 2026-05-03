using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "EnemyStat", menuName = "EnemyStat")]
public class EnemyStatus : ScriptableObject
{
    public float maxHealth = 20;
    
    public int attackPower = 1;
    public int attackTypes = 3;

    public float moveSpeed = 2.5f;

    public BossAttack[] bossAttacks;
}

[System.Serializable]
public class BossAttack
{
    public float range;
    public float damage;
    public float prepareTime;
    public float attackTime;
    public float endDelay;
    public float cooldown;
}

