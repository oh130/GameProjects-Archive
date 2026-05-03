using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PlayerStat", menuName = "PlayerStat")]
public class PlayerStatus : ScriptableObject
{
    public float maxHealth;

    public float moveSpeed;
    public float jumpForce;
    public int jumpOppertunity;

    public float dashForce;
    public float dashTime;
    public float dashCooldown;

    public float groundCheckRadius;

    public float attackPower;
    public float attackTime;
    public float attackDelay;
    public float attackMove;
    public float attackRange;

    public float guardMoveSpeed;
    public float guardHealth;
    public float guardBrokenStunTime;
    public float guardCooldown;

    public float parryingTime;

    public float knockBackForce;
    public float knockBackTime;
    public float damagedInvincibleTime;

    public float interactionRange;
}
