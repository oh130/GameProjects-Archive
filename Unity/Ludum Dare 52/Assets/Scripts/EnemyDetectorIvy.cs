using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDetectorIvy : MonoBehaviour
{
    public Ivy ivy;

    private void OnTriggerEnter2D(Collider2D collision)
    {
        ivy.StoppingEnemy();
    }
}
