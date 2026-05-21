using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterEnemy : MonoBehaviour, IEnemyInterface
{
    #region Variables

    [SerializeField] EnemyStatus ES;
    [SerializeField] WaterEnemyGroup parent;
    [SerializeField] Transform parentPos;
    [SerializeField] Vector3 addPos;

    // Status
    float currentHP;
    float buffAmount;
    bool onInvincible;
    bool onHit;
    bool buffed;

    // Player Interaction
    Vector2 traceDir;

    // Components
    Rigidbody2D rb2d;
    Animator anim;
    SpriteRenderer sr;

    #endregion

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        sr = GetComponent<SpriteRenderer>();
    }

    void OnEnable()
    {
        transform.position = parentPos.position + addPos;
        rb2d.MovePosition(transform.position);

        onHit = false;
        onInvincible = false;
        buffed = false;
        buffAmount = 1;

        currentHP = ES.maxHealth;

        StartCoroutine(MoveLoop());
    }

    void Move()
    {
        if (onHit)
        {
            return;
        }

        traceDir = (PlayerController.Instance.CurrentPos - rb2d.position).normalized;

        rb2d.velocity = ES.speed * buffAmount * traceDir;

        if (traceDir.x < 0) transform.localScale = new Vector2(-1, 1);
        else if (traceDir.x > 0) transform.localScale = new Vector2(1, 1);
    }

    IEnumerator MoveLoop()
    {
        while (this.gameObject.activeSelf)
        {
            yield return GameManager.Instance.AppropriateDelay;
            Move();
        }
    }

    public void Healed(float amount)
    {
        currentHP = Mathf.Clamp(currentHP + amount, 0, ES.maxHealth * buffAmount);
    }

    public void Damaged(float amount, int elementType)
    {
        if (onInvincible)
        {
            return;
        }

        if (elementType == (int)GameManager.Element.Ion)
        {
            // critical by ion (affected by luck)
            if (Random.value <= GameManager.Instance.IonCritPercentage * (1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Ion]))
            {
                amount *= GameManager.Instance.IonCritMultiply;
            }
        }

        if (elementType == GameManager.Instance.DominanceType[ES.elementType])
        {
            amount *= 0.5f;
        }
        else if (elementType == GameManager.Instance.InferiorType[ES.elementType])
        {
            amount *= 2;
        }

        amount *= 1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Fire];
        currentHP -= amount;

        if (currentHP <= 0)
        {
            Die();
        }
        else
        {
            // invincible
            onInvincible = true;
            StartCoroutine(Invincible());

            // knockback
            onHit = true;
            sr.material = GameManager.Instance.FlashWhiteMaterial;
            rb2d.velocity = Vector2.zero;
            rb2d.AddForce(-0.5f * traceDir, ForceMode2D.Impulse);
            StartCoroutine(KnockBack());
        }
    }

    IEnumerator Invincible()
    {
        yield return GameManager.Instance.InvincibleTime;
        onInvincible = false;
    }

    IEnumerator KnockBack()
    {
        yield return GameManager.Instance.KnockBackTime;
        sr.material = GameManager.Instance.DefMaterial;
        onHit = false;

        Move();
    }

    public void Buffed(float amount)
    {
        if (buffed) return;
        buffed = true;
        buffAmount += amount;

        currentHP *= buffAmount;
    }

    public void Die()
    {
        // give EXP
        GameManager.Instance.GetExp(ES.giveExp);

        // random ether drop
        float rand = Random.value;

        for (int i = ES.collectableDropPercentage.Length - 1; i >= 0; --i)
        {
            if (rand < ES.collectableDropPercentage[i] * (1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Ion]))
            {
                CollectableManager.Instance.SetCollectableObjectActive(i, rb2d.position);
                break;
            }
        }

        parent.ChildDie();
        this.gameObject.SetActive(false);
    }

    void OnCollisionStay2D(Collision2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Player)
        {
            PlayerController.Instance.Damaged(ES.collisionDamage);
        }
    }
}