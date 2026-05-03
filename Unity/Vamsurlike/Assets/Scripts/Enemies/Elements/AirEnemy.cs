using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AirEnemy : MonoBehaviour, IEnemyInterface
{
    #region Variables

    [SerializeField] EnemyStatus ES;
    [SerializeField] AirEnemyGroup parent;

    // Status
    float currentHP;
    float buffAmount;
    bool onInvincible;
    bool buffed;

    // Components
    Animator anim;
    SpriteRenderer sr;

    #endregion

    void Awake()
    {
        anim = GetComponent<Animator>();
        sr = GetComponent<SpriteRenderer>();
    }

    void OnEnable()
    {
        buffed = false;
        buffAmount = 1;

        currentHP = ES.maxHealth;
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

        // ether random drop
        float rand = Random.value;

        for (int i = ES.collectableDropPercentage.Length - 1; i >= 0; --i)
        {
            if (rand < ES.collectableDropPercentage[i] * (1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Ion]))
            {
                CollectableManager.Instance.SetCollectableObjectActive(i, transform.position);
                break;
            }
        }

        parent.ChildDie();
        this.gameObject.SetActive(false);
    }

    void OnTriggerStay2D(Collider2D collision)
    {
        if (collision.gameObject.layer == (int)GameManager.Layer.Player)
        {
            PlayerController.Instance.Damaged(ES.collisionDamage);
        }
    }
}
