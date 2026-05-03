using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LifeEnemy : MonoBehaviour, IEnemyInterface
{
    #region Variables

    [SerializeField] EnemyStatus ES;

    // Status
    float currentHP;
    float buffAmount;
    bool onInvincible;
    bool buffed;
    bool onHit;

    // Player Interaction
    float radian;
    Vector2 traceDir;
    Vector2 randomPoint;

    // Coroutine
    WaitForSeconds abilityCooldown1;
    WaitForSeconds abilityCooldown2;

    // Components
    Rigidbody2D rb2d;
    Animator anim;
    SpriteRenderer sr;

    #endregion

    void Awake()
    {
        abilityCooldown1 = new WaitForSeconds(ES.abilityCooldown);
        abilityCooldown2 = new WaitForSeconds(ES.remainValue1);

        rb2d = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        sr = GetComponent<SpriteRenderer>();
    }

    void OnEnable()
    {
        buffed = false;
        buffAmount = 1;
        
        currentHP = ES.maxHealth;

        StartCoroutine(MoveLoop());
        StartCoroutine(Buff());
        StartCoroutine(Heal());
    }

    void Move()
    {
        if (onHit)
        {
            return;
        }

        radian = Random.Range(0f, 360f) * Mathf.Deg2Rad;
        randomPoint = PlayerController.Instance.CurrentPos + ES.abilityRange * new Vector2(Mathf.Cos(radian), Mathf.Sin(radian));

        rb2d.velocity = ES.speed * buffAmount * (randomPoint - rb2d.position).normalized;

        if (rb2d.velocity.x < 0) transform.localScale = new Vector2(-1, 1);
        else if (rb2d.velocity.x > 0) transform.localScale = new Vector2(1, 1);
    }

    IEnumerator MoveLoop()
    {
        while (this.gameObject.activeSelf)
        {
            yield return GameManager.Instance.AppropriateDelay;
            Move();
        }
    }

    IEnumerator Buff()
    {
        Collider2D target;

        while (this.gameObject.activeSelf)
        {
            yield return abilityCooldown1;

            target = Physics2D.OverlapCircle(transform.position, ES.abilityRange, GameManager.Instance.EnemyLayer);

            target.gameObject.GetComponent<IEnemyInterface>().Buffed(ES.abilityValue);
        }
    }

    IEnumerator Heal()
    {
        Collider2D[] targets;

        while (this.gameObject.activeSelf)
        {
            yield return abilityCooldown2;

            targets = Physics2D.OverlapCircleAll(transform.position, ES.abilityRange, GameManager.Instance.EnemyLayer);

            foreach (Collider2D target in targets)
            {
                target.gameObject.GetComponent<IEnemyInterface>().Healed(ES.remainValue2);
            }
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
            rb2d.AddForce(-traceDir, ForceMode2D.Impulse);
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
        onHit = false;
        sr.material = GameManager.Instance.DefMaterial;
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

        this.gameObject.SetActive(false);
    }

    void OnCollisionStay2D(Collision2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Player)
        {
            PlayerController.Instance.Damaged(ES.collisionDamage * buffAmount);
        }
    }
}
