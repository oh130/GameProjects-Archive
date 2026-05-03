using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Life : MonoBehaviour
{
    #region Variables

    [SerializeField] SpellStatus SS;

    Rigidbody2D rb2d;

    Transform target;

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

        StartCoroutine(Homing());
    }

    IEnumerator Homing()
    {
        // Deceleration
        yield return GameManager.Instance.OneSecDelay;

        // Homing
        Collider2D[] targets;
        float closestDist;

        StartCoroutine(Acceleration());

        while (this.gameObject.activeSelf)
        {
            targets = Physics2D.OverlapCircleAll(transform.position, SS.range, GameManager.Instance.EnemyLayer);
            closestDist = float.MaxValue;
            target = null;

            foreach (Collider2D col in targets)
            {
                float distance = Vector2.Distance(transform.position, col.transform.position);
                if (distance < closestDist)
                {
                    closestDist = distance;
                    target = col.transform;
                }
            }

            yield return GameManager.Instance.AppropriateDelay;
        }
    }

    IEnumerator Acceleration()
    {
        while (this.gameObject.activeSelf)
        {
            if (target)
            {
                Vector2 dir = new(target.transform.position.x - transform.position.x, target.transform.position.y - transform.position.y);
                rb2d.velocity += Time.fixedDeltaTime * SS.speed * dir.normalized;
            }
            yield return GameManager.Instance.FixedTimeDelay;
        }
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Enemy)
        {
            collision.gameObject.GetComponent<IEnemyInterface>().Damaged(SS.damage, (int)GameManager.Element.Life);

            this.gameObject.SetActive(false);
        }
        else if (collision.gameObject.layer == (int)GameManager.Layer.OuterMapWall)
        {
            this.gameObject.SetActive(false);
        }
    }
}
