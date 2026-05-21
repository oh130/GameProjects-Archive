using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EarthEnemy : MonoBehaviour, IEnemyInterface
{
    #region Variables

    [SerializeField] EnemyStatus ES;

    // Status
    float currentHP;
    float buffAmount;
    bool onInvincible;
    bool onAbility;
    bool buffed;

    // Player Interaction
    float radian;
    Vector2 randomPoint;
    Vector2 traceDir;
    Vector2 viewportPos;

    // Components
    Rigidbody2D rb2d;
    Animator anim;
    SpriteRenderer sr;
    CircleCollider2D col;

    #endregion

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        sr = GetComponent<SpriteRenderer>();
        col = GetComponent<CircleCollider2D>();
    }

    void OnEnable()
    {
        col.enabled = true;
        buffed = false;
        onAbility = false;
        buffAmount = 1;

        currentHP = ES.maxHealth;

        StartCoroutine(MoveLoop());
    }

    void Move()
    {
        if (onAbility)
        {
            return;
        }

        viewportPos = Camera.main.WorldToViewportPoint(rb2d.position);

        if (!(viewportPos.x >= -0.05f && viewportPos.x <= 1.05f && viewportPos.y >= -0.05f && viewportPos.y <= 1.05f))
        {
            onAbility = true;
            col.enabled = false;
            rb2d.velocity = Vector2.zero;
            radian = Random.Range(0f, 360f) * Mathf.Deg2Rad;
            randomPoint = PlayerController.Instance.CurrentPos + ES.abilityRange * new Vector2(Mathf.Cos(radian), Mathf.Sin(radian));
            rb2d.MovePosition(randomPoint);

            StartCoroutine(Ability());
        }
        else
        {
            traceDir = (PlayerController.Instance.CurrentPos - rb2d.position).normalized;
            rb2d.velocity = ES.speed * buffAmount * traceDir;

            if (traceDir.x < 0) transform.localScale = new Vector2(-1, 1);
            else if (traceDir.x > 0) transform.localScale = new Vector2(1, 1);
        }
    }

    IEnumerator MoveLoop()
    {
        while (this.gameObject.activeSelf)
        {
            yield return GameManager.Instance.AppropriateDelay;
            Move();
        }
    }

    IEnumerator Ability()
    { 
        yield return GameManager.Instance.OneSecDelay;
        onAbility = false;
        col.enabled = true;
        
        Move();
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
            sr.material = GameManager.Instance.FlashWhiteMaterial;
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

        float rand = Random.value;

        for (int i = ES.collectableDropPercentage.Length - 1; i >= 0; --i)
        {
            if (rand < ES.collectableDropPercentage[i] * (1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Ion]))
            {
                CollectableManager.Instance.SetCollectableObjectActive(i, rb2d.position);
                break;
            }
        }

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
