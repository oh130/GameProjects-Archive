using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IEnemyInterface
{
    public void Damaged(float amount, int elementType);
    public void Healed(float amount);
    public void Buffed(float amount);
    public void Die();
}
