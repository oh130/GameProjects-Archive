using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDetectorNepenthes : MonoBehaviour
{
    public Nepenthes nepenthes;

    private void OnTriggerStay2D(Collider2D collision)
    {
        nepenthes.ShootingLeaf(collision.transform.position);
    }
}
