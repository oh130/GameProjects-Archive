using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "SpellStatus", menuName = "SpellStatus")]
public class SpellStatus : ScriptableObject
{
    public float speed;

    public float damage;

    public float life;

    public float range;
}
