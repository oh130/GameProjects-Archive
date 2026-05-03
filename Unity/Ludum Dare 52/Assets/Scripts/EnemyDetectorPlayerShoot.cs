using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDetectorPlayerShoot : MonoBehaviour
{
    public PlayerControl player;

    void OnTriggerStay2D(Collider2D collision)
    {
        player.ShootEnemy(collision.transform.position);
    }
}
