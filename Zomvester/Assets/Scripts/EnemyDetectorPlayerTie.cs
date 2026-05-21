using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDetectorPlayerTie : MonoBehaviour
{
    public PlayerControl player;

    void OnTriggerStay2D(Collider2D collision)
    {
        player.TieEnemy();
    }
}
