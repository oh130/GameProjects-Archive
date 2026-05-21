using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Projectile : MonoBehaviour
{
    #region Variables

    [SerializeField] ProjectileStatus PS;

    Rigidbody2D rb2d;
    
    #endregion

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
    }

    void OnEnable()
    {
        rb2d.velocity = PS.speed * (PlayerController.Instance.CurrentPos - new Vector2(transform.position.x, transform.position.y)).normalized;
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Player && !(PlayerController.Instance.OnInvincible || PlayerController.Instance.IsRole))
        {
            PlayerController.Instance.Damaged(PS.damage);
            this.gameObject.SetActive(false);
        }
        
        if(collision.gameObject.layer == (int)GameManager.Layer.OuterMapWall)
        {
            this.gameObject.SetActive(false);
        }
    }
}
