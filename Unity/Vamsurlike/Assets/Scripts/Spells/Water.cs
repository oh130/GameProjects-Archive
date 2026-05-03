using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Water : MonoBehaviour
{

    #region Variables

    [SerializeField] SpellStatus SS;

    WaitForSeconds lifeTime;

    #endregion

    void Awake()
    {
        lifeTime = new WaitForSeconds(SS.life);
    }

    void OnEnable()
    {
        transform.position = PlayerController.Instance.CurrentPos;

        StartCoroutine(Life());
    }

    IEnumerator Life()
    {
        yield return lifeTime;

        this.gameObject.SetActive(false);
    }

    void OnTriggerStay2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Enemy)
        {
            collision.gameObject.GetComponent<IEnemyInterface>().Damaged(SS.damage, (int)GameManager.Element.Water);
        }
    }
}
