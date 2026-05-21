using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class PlayerController : MonoBehaviour
{
    #region Variables

    /* 
    
    PlayerController has...
    
    1. player move
    2. current player status
    3. player damaged, invincible, die
    4. player animation
      
    */

    [SerializeField] PlayerStatus PS;
    [SerializeField] Slider HpSlider;
    [SerializeField] TextMeshProUGUI HpText;
    [SerializeField] GameObject invincibleMark;

    // Singleton
    static PlayerController instance;
    public static PlayerController Instance { get { return instance; } }

    // Input variable
    Vector2 input;
    Vector2 lookDir;
    Vector2 currentPos;

    // Status
    float currentHP;
    float elapsedRoleTime;
    bool isRole;
    bool roleUnable;
    bool onInvincible;

    // Coroutine Times
    WaitForSeconds regenTime;
    WaitForSeconds roleCooldown;
    WaitForSeconds invincibleTime;

    // Components
    Rigidbody2D rb2d;
    SpriteRenderer sr;
    Animator anim;

    // Properties
    public Vector2 LookDir { get { return lookDir; } }
    public Vector2 CurrentPos { get { return currentPos; } }
    public float CurrentHP { get { return currentHP; } }
    public bool IsRole { get { return isRole; } }
    public bool OnInvincible { get {  return onInvincible; } }
    #endregion

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if (instance != this)
        {
            Destroy(this.gameObject);
        }

        regenTime = new WaitForSeconds(PS.regenTime);
        invincibleTime = new WaitForSeconds(PS.invincibleTime);
        roleCooldown = new WaitForSeconds(PS.roleCooldown);
        
        lookDir = Vector2.right;

        rb2d = GetComponent<Rigidbody2D>();
        sr = GetComponent<SpriteRenderer>();
        anim = GetComponent<Animator>();
    }

    void Start()
    {
        currentPos = rb2d.position;
        currentHP = GameManager.Instance.CurrentStats[(int)GameManager.Element.Earth];
        ChangeHP(1);
        StartCoroutine(RegenHP());
    }

    void FixedUpdate()
    {
        if (GameManager.Instance.PlayerDeath || GameManager.Instance.NotOnLive)
        {
            return;
        }

        currentPos = rb2d.position;

        if (isRole)
        {
            return;
        }

        if (input.x > 0)
        {
            transform.localScale = new Vector2(1, 1);
        }
        else if (input.x < 0)
        {
            transform.localScale = new Vector2(-1, 1);
        }

        rb2d.velocity = (1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Water]) * PS.speed * input;
    }

    // new input system
    public void OnMove(InputAction.CallbackContext context)
    {
        if (GameManager.Instance.PlayerDeath || GameManager.Instance.NotOnLive)
        {
            return;
        }

        input = context.ReadValue<Vector2>().normalized;
        if (!isRole && input != Vector2.zero)
        {
            lookDir = input;
        }
    }

    public void OnRole(InputAction.CallbackContext context)
    {
        if (GameManager.Instance.PlayerDeath || GameManager.Instance.NotOnLive || roleUnable)
        {
            return;
        }

        isRole = true;
        roleUnable = true;
        invincibleMark.SetActive(true);
        StartCoroutine(Role());
    }

    public void Healed(float amount)
    {
        currentHP = Mathf.Clamp(currentHP + amount, 0, GameManager.Instance.CurrentStats[(int)GameManager.Element.Earth]);

        ChangeHP(currentHP / GameManager.Instance.CurrentStats[(int)GameManager.Element.Earth]);
    }

    public void Damaged(float amount)
    {
        if (onInvincible)
        {
            return;
        }

        amount *= 1 + 0.01f * GameManager.Instance.CurrentStats[(int)GameManager.Element.Darkness];
        currentHP = Mathf.Clamp(currentHP - amount, 0, GameManager.Instance.CurrentStats[(int)GameManager.Element.Earth]);
        ChangeHP(currentHP / GameManager.Instance.CurrentStats[(int)GameManager.Element.Earth]);

        if (currentHP == 0)
        {
            GameManager.Instance.Death();
            Die();
        }
        else
        {
            sr.color = new Color(sr.color.r, sr.color.g, sr.color.b, PS.invincibleAlpha);
            onInvincible = true;
            StartCoroutine(Invincible());
        }
    }

    void ChangeHP(float percent)
    {
        HpSlider.value = percent;
        HpText.text = string.Format("{0:F1}", currentHP);
    }

    void Die()
    {
        // set trigger die animation
        enabled = false;
    }

    IEnumerator Role()
    {
        while (elapsedRoleTime < PS.roleTime)
        {
            rb2d.velocity = Mathf.Lerp(PS.roleSpeed, 0f, (elapsedRoleTime / PS.roleTime) * (elapsedRoleTime / PS.roleTime)) * lookDir;

            elapsedRoleTime += Time.deltaTime;
            yield return null;
        }

        elapsedRoleTime = 0;
        isRole = false;
        invincibleMark.SetActive(false);
        if(input != Vector2.zero)
        {
            lookDir = input;
        }

        yield return roleCooldown;
        roleUnable = false;
    }

    IEnumerator Invincible()
    {
        yield return invincibleTime;
        sr.color = new Color(sr.color.r, sr.color.g, sr.color.b);
        onInvincible = false;
    }

    IEnumerator RegenHP()
    {
        while (!GameManager.Instance.PlayerDeath)
        {
            yield return regenTime;
            Healed(GameManager.Instance.CurrentStats[(int)GameManager.Element.Life]);
        }
    }
}
