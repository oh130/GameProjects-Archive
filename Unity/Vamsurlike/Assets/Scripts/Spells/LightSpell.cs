using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightSpell : MonoBehaviour
{
    #region Variables

    [SerializeField] SpellStatus SS;

    Rigidbody2D rb2d;

    #endregion

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
    }

    void OnEnable()
    {
        transform.position = PlayerController.Instance.CurrentPos;

        float randomAngle = Random.Range(0, 360) * Mathf.Deg2Rad;
        Vector2 randomDir = new(Mathf.Cos(randomAngle), Mathf.Sin(randomAngle));
        rb2d.velocity = SS.speed * randomDir;
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Enemy)
        {
            collision.gameObject.GetComponent<IEnemyInterface>().Damaged(SS.damage, (int)GameManager.Element.Light);
        }
        else if(collision.gameObject.layer == (int)GameManager.Layer.OuterMapWall)
        {
            this.gameObject.SetActive(false);
        }
    }
}
