using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Air : MonoBehaviour
{
    #region Variables

    [SerializeField] SpellStatus SS;

    #endregion

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Enemy)
        {
            collision.gameObject.GetComponent<IEnemyInterface>().Damaged(SS.damage, (int)GameManager.Element.Air);
        }
    }
}
