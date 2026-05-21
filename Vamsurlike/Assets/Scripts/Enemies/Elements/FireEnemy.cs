using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireEnemy : MonoBehaviour, IEnemyInterface
{
    #region Variables

    [SerializeField] EnemyStatus ES;

    // Status
    float currentHP;
    float buffAmount;
    bool onInvincible;
    bool onHit;
    bool abilityUnable;
    bool buffed;

    // Player Interaction
    Vector2 traceDist;
    Vector2 traceDir;

    // Coroutine Times
    WaitForSeconds abilityCooldown;

    // Components
    Rigidbody2D rb2d;
    Animator anim;
    SpriteRenderer sr;

    #endregion

    void Awake()
    {
        abilityCooldown = new WaitForSeconds(ES.abilityCooldown);

        rb2d = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        sr = GetComponent<SpriteRenderer>();
    }

    void OnEnable()
    {
        abilityUnable = false;
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

        traceDist = PlayerController.Instance.CurrentPos - rb2d.position;
        traceDir = traceDist.normalized;

        if (traceDist.magnitude <= ES.abilityRange)
        {
            rb2d.velocity = Vector2.zero;

            if (!abilityUnable)
            {
                abilityUnable = true;
                StartCoroutine(Ability());
            }
        }
        else
        {
            rb2d.velocity = ES.speed * buffAmount * traceDir;
        }

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

        if(elementType == GameManager.Instance.DominanceType[ES.elementType])
        {
            amount *= 0.5f;
        }
        else if(elementType == GameManager.Instance.InferiorType[ES.elementType])
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
            rb2d.AddForce(-traceDir, ForceMode2D.Impulse);
            StartCoroutine(KnockBack());
        }
    }

    IEnumerator Ability()
    {
        yield return GameManager.Instance.AppropriateDelay;
        ProjectileManager.Instance.SetProjectileObjectActive(0, transform.position);

        yield return abilityCooldown;
        abilityUnable = false;
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
