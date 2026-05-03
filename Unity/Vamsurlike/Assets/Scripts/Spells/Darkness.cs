using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Darkness : MonoBehaviour
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
        Vector3 pos = Camera.main.ScreenToWorldPoint(new(Screen.width * Random.value, Screen.height * Random.value));
        pos.z = 0f;
        transform.position = pos;

        StartCoroutine(LifeTime());
    }

    IEnumerator LifeTime()
    {
        yield return lifeTime;

        this.gameObject.SetActive(false);
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Enemy)
        {
            collision.gameObject.GetComponent<IEnemyInterface>().Damaged(SS.damage, (int)GameManager.Element.Darkness);
        }
    }
}
