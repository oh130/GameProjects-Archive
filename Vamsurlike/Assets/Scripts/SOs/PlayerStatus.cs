using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PlayerStatus", menuName = "PlayerStatus")]
public class PlayerStatus : ScriptableObject
{
    public float speed;
    public float regenTime;

    public float roleTime;
    public float roleCooldown;
    public float roleSpeed;

    public float invincibleTime;
    public float invincibleAlpha;
}
