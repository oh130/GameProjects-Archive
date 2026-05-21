using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CollectableStatus", menuName = "CollectableStatus")]
public class CollectableStatus : ScriptableObject
{
    public int value;
    public float force;
}
