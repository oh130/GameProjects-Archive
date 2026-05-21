using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Collectable : MonoBehaviour
{
    [SerializeField] CollectableStatus CS;

    Rigidbody2D rb2d;

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
    }

    void OnEnable()
    {
        rb2d.MovePosition(transform.position);

        float randomAngle = Random.Range(0, 360) * Mathf.Deg2Rad;
        Vector2 randomDir = new(Mathf.Cos(randomAngle), Mathf.Sin(randomAngle));
        rb2d.velocity = randomDir;

        StartCoroutine(LifeTime());
    }

    IEnumerator LifeTime()
    {
        yield return GameManager.Instance.CollectableLife;
        this.gameObject.SetActive(false);
    }

    void OnTriggerStay2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Player)
        {
            GameManager.Instance.GetEther(CS.value);
            this.gameObject.SetActive(false);
        }
        else if (collision.gameObject.layer == (int) GameManager.Layer.Magnet)
        {
            rb2d.AddForce(CS.force * (PlayerController.Instance.CurrentPos - rb2d.position).normalized);
        }
        else if (collision.gameObject.layer == (int)GameManager.Layer.OuterMapWall)
        {
            this.gameObject.SetActive(false);
        }
    }
}
