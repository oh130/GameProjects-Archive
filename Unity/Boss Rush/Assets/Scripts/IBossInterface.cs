using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IBossInterface
{
    void Damaged(float amount);
    void SetBossHealthBar(float percentage);
}
