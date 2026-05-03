using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boss1 : MonoBehaviour
{
    public EnemyStatus enemyStatus;
    public Rigidbody2D player;

    int playerDir;
    int lookDir;
    float dist;
    public float turnDelay = 0.5f;

    bool onAttack;
    bool canAttack;
    bool onStun;
    bool onTurnDelay;
    bool[] onCooldown;
    List<int> attackList;

    Rigidbody2D rb2d;
    SpriteRenderer sr;

    void Start()
    {
        rb2d = GetComponent<Rigidbody2D>();
        sr = GetComponent<SpriteRenderer>();
        onCooldown = new bool[enemyStatus.attackTypes];
        attackList = new List<int>();
        canAttack = true;
        lookDir = -1;
    }

    void Update()
    {
        #region Abnormal Status
        if (StaticVariables.onCutScene || onAttack || onStun)
        {
            return;
        }
        #endregion

        #region Move
        dist = player.position.x - rb2d.position.x;
        playerDir = dist < 0 ? -1 : 1;
        Move();
        #endregion

        #region Attack
        if (canAttack)
        {
            for (int i = 0; i < enemyStatus.attackTypes; ++i)
            {
                if (Mathf.Abs(dist) <= enemyStatus.bossAttacks[i].range && !onCooldown[i])
                {
                    attackList.Add(i);
                }
            }

            if (attackList.Count != 0)
            {
                StartCoroutine(Attack(attackList[Random.Range(0, attackList.Count)]));
                attackList.Clear();
            }
        }
        #endregion
    }

    void Move()
    {
        if (playerDir != lookDir)
        {
            if (onTurnDelay) return;

            lookDir = playerDir;
            transform.localScale = new Vector2(-transform.localScale.x, transform.localScale.y);
            onTurnDelay = true;
            StartCoroutine(Turn());
        }

        rb2d.position = new Vector2(rb2d.position.x + lookDir * enemyStatus.moveSpeed * Time.deltaTime, rb2d.position.y);
    }

    IEnumerator Turn()
    {
        var time = new WaitForSeconds(turnDelay);
        yield return time;
        onTurnDelay = false;
    }

    IEnumerator Attack(int attackType)
    {
        onAttack = true;
        canAttack = false;
        onCooldown[attackType] = true;

        var time = new WaitForSeconds(enemyStatus.bossAttacks[attackType].prepareTime);
        yield return time;
        Debug.Log(attackType);

        time = new WaitForSeconds(enemyStatus.bossAttacks[attackType].attackTime);
        yield return time;
        Debug.Log("Attack End");
        onAttack = false;

        time = new WaitForSeconds(enemyStatus.bossAttacks[attackType].endDelay);
        yield return time;
        Debug.Log("Can Attack");
        canAttack = true;

        time = new WaitForSeconds(enemyStatus.bossAttacks[attackType].cooldown);
        yield return time;
        onCooldown[attackType] = false;
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, enemyStatus.bossAttacks[0].range);

        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, enemyStatus.bossAttacks[1].range);

        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, enemyStatus.bossAttacks[2].range);
    }
}
