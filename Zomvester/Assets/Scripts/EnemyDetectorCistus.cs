using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDetectorCistus : MonoBehaviour
{
    public Cistus cistus;

    private void OnTriggerEnter2D(Collider2D collision)
    {
        cistus.FireTheBomber();
    }
}
