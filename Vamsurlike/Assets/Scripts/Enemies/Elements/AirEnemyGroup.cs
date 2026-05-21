using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AirEnemyGroup : MonoBehaviour
{
    #region Variables

    [SerializeField] EnemyStatus ES;
    int currentChildCount;

    // Trace
    Vector2 traceDir;

    // Coroutine
    WaitForSeconds rushDelay;

    // Components
    Rigidbody2D rb2d;

    #endregion

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
        rushDelay = new WaitForSeconds(ES.abilityValue);
    }

    void OnEnable()
    {
        currentChildCount = GameManager.Instance.AirGroupCount;

        foreach (Transform child in transform)
        {
            child.gameObject.SetActive(true);
        }

        traceDir = (PlayerController.Instance.CurrentPos - new Vector2(transform.position.x, transform.position.y)).normalized;

        rb2d.velocity = ES.speed * traceDir;

        if (traceDir.x < 0) transform.localScale = new Vector2(-1, 1);
        else if (traceDir.x > 0) transform.localScale = new Vector2(1, 1);
    }

    public void ChildDie()
    {
        if (--currentChildCount == 0)
        {
            this.gameObject.SetActive(false);
        }
    }

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.OuterMapWall)
        {
            rb2d.velocity = Vector2.zero;
            StartCoroutine(RushDelay());
        }
    }

    IEnumerator RushDelay()
    {
        yield return rushDelay;
        traceDir = (PlayerController.Instance.CurrentPos - rb2d.position).normalized;
        rb2d.velocity = ES.speed * traceDir;

        if (traceDir.x < 0) transform.localScale = new Vector2(-1, 1);
        else if (traceDir.x > 0) transform.localScale = new Vector2(1, 1);
    }
}