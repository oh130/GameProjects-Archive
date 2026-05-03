using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "EnemyStatus", menuName = "EnemyStatus")]
public class EnemyStatus : ScriptableObject
{
    public int elementType;

    public float maxHealth;
    public float speed;

    public float collisionDamage;

    public float abilityRange;
    public float abilityCooldown;
    public float abilityValue;
    public float remainValue1;
    public float remainValue2;

    public float giveExp;
    public float[] collectableDropPercentage;
}
