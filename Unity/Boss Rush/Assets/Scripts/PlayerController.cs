using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class PlayerController : MonoBehaviour
{

    #region Variables
    public PlayerStatus playerStatus;

    // Move
    int lookDir;
    float moveInput;
    // Jump
    public Transform groundCheck;
    public LayerMask groundLayer;
    bool isGrounded; 
    bool jumpPressed;
    bool onJump;
    int jumpCount;
    // Dash
    bool dashPressed;
    bool canDash;
    bool onDash;
    float elapsedDashTime;
    // Attack
    public Transform actionPoint;
    public LayerMask enemyLayer;
    bool attackPressed;
    bool onAttack;
    float currentAttackPower;
    bool isSpecialAttack;
    // Guard
    float currentGuardHealth;
    bool guardPressed;
    bool guardPressing;
    bool onGuard;
    bool onStun;
    // Parrying
    bool onParrying;
    bool onGuardCooldown;
    // Health
    public Image healthBar;
    float currentHealth;
    // Damaged
    bool damagedInvincible;
    bool onKnockBack;
    bool death;
    // Components
    Rigidbody2D rb2d;
    Animator anim;
    // Events
    public UnityEvent PlayerDeath;
    #endregion

    void Start()
    {
        rb2d = GetComponent<Rigidbody2D>();
        // Initialize        
        lookDir = 1;
        canDash = true;
        currentHealth = playerStatus.maxHealth;
        SetHealthBar(1);
        currentGuardHealth = playerStatus.guardHealth;
        currentAttackPower = playerStatus.attackPower;
    }

    void Update()
    {
        #region Abnormal Status
        // Ground Check
        isGrounded = Physics2D.OverlapCircle(groundCheck.position, playerStatus.groundCheckRadius, groundLayer);

        if (death || StaticVariables.onCutScene)
        {
            if (isGrounded)
            {
                rb2d.velocity = Vector2.zero;
            }
            return;
        }
        else if(onStun || onKnockBack || onParrying)
        {
            return;
        }
        #endregion

        #region Move Input
        moveInput = Input.GetAxisRaw("Horizontal");
        
        // Move Input Detect
        if (!onDash && (onJump || !onAttack))
        {
            Move();
        }
        #endregion

        #region Jump Input
        jumpPressed = Input.GetKeyDown(KeyCode.Space);
        
        if (isGrounded && rb2d.velocity.y == 0)
        {
            onJump = false;
            jumpCount = 0;
        }
        else
        {
            onJump = true;
        }

        // Jump Input Detect
        if (jumpPressed && (jumpCount < playerStatus.jumpOppertunity) && !onAttack && !onDash && !onGuard)
        {
            jumpCount++;
            Jump();
        }
        #endregion

        #region Dash Input
        dashPressed = Input.GetKeyDown(KeyCode.LeftShift);

        // Dash Input Detect
        if (dashPressed && canDash && !onAttack && !onGuard)
        {
            canDash = false;
            onDash = true;
            StartCoroutine(Dash());
        }
        #endregion

        #region Attack Input
        attackPressed = Input.GetKey(KeyCode.A);

        // Attack Input Detect
        if(attackPressed && !onAttack && !onDash && !onGuard)
        {
            onAttack = true;
            StartCoroutine(Attack());
        }
        #endregion

        #region Guard Input
        guardPressed = Input.GetKeyDown(KeyCode.S);
        guardPressing = Input.GetKey(KeyCode.S);

        // Guard Input Detect
        if(guardPressing && !onJump)
        {
            onGuard = true;
        }
        else
        {
            onGuard = false;
        }

        if (guardPressed && !onAttack && !onDash && !onGuardCooldown)
        {
            onParrying = true;
            onGuardCooldown = true;
            StartCoroutine(Parrying());
        }
        #endregion
    }

    void FixedUpdate()
    {
        
    }

    void Move()
    {
        if (moveInput < 0) lookDir = -1;
        else if (moveInput > 0) lookDir = 1;

        // Sprite Flip
        transform.localScale = new Vector2(lookDir, 1);

        if (onGuard)
        {
            rb2d.velocity = new Vector2(moveInput * playerStatus.guardMoveSpeed, rb2d.velocity.y);
        }
        else
        {
            rb2d.velocity = new Vector2(moveInput * playerStatus.moveSpeed, rb2d.velocity.y);
        }
    }   

    void Jump()
    {
        rb2d.AddForce((playerStatus.jumpForce - rb2d.velocity.y) * Vector2.up, ForceMode2D.Impulse);
        // Jump Animation
        // if rb2d.velocity.y >= 0, jump animation, < 0, drop animation
    }

    IEnumerator Dash()
    {
        // Dash
        rb2d.velocity = new Vector2(lookDir * playerStatus.dashForce, 0f);
        rb2d.gravityScale = 0;

        while(elapsedDashTime < playerStatus.dashTime)
        {
            rb2d.velocity = new Vector2(lookDir * Mathf.Lerp(playerStatus.dashForce, 0f, (elapsedDashTime / playerStatus.dashTime) * (elapsedDashTime / playerStatus.dashTime)), 0f);
            
            elapsedDashTime += Time.deltaTime;
            yield return null;
        }

        elapsedDashTime = 0;
        rb2d.gravityScale = 1;
        onDash = false;
        
        var time = new WaitForSeconds(playerStatus.dashCooldown);
        yield return time;
        canDash = true;
    }

    IEnumerator Attack()
    {
        if (isSpecialAttack)
        {
            currentAttackPower *= 2;
            isSpecialAttack = false;
        }

        Collider2D[] hitEnemies = Physics2D.OverlapCircleAll(actionPoint.position, playerStatus.attackRange, enemyLayer);

        foreach (Collider2D enemy in hitEnemies)
        {
            enemy.GetComponent<IBossInterface>().Damaged(currentAttackPower);
        }

        if (!onJump)
        {
            rb2d.velocity = Vector2.zero;
        }

        currentAttackPower = playerStatus.attackPower;
        
        var time = new WaitForSeconds(playerStatus.attackDelay);
        yield return time;
        onAttack = false;
    }

    IEnumerator Parrying()
    {
        var time = new WaitForSeconds(playerStatus.parryingTime);
        yield return time;
        onParrying = false;

        time = new WaitForSeconds(playerStatus.guardCooldown);
        yield return time;
        onGuardCooldown = false;
    }

    public void Healed(float amount)
    {
        currentHealth = Mathf.Clamp(currentHealth + amount, 0, playerStatus.maxHealth);
        SetHealthBar(currentHealth / playerStatus.maxHealth);
    }

    public void Damaged(float amount)
    {
        if (onDash || damagedInvincible) return;

        // Parry
        if (onParrying)
        {
            isSpecialAttack = true;
            return;
        }

        // Guard
        if (onGuard)
        {
            currentGuardHealth -= amount;
            if(currentGuardHealth <= 0)
            {
                Debug.Log("Guard Broken");
                StartCoroutine(GuardBroken());
            }

            return;
        }

        // Health Change
        currentHealth = Mathf.Clamp(currentHealth - amount, 0, playerStatus.maxHealth);
        SetHealthBar(currentHealth / playerStatus.maxHealth);

        // Death Control
        if (currentHealth == 0)
        {
            death = true;
            PlayerDeath.Invoke();
            return;
        }

        // Invincible
        StartCoroutine(DamagedInvincible());
    }

    void SetHealthBar(float percentage)
    {
        healthBar.fillAmount = percentage;
    }

    IEnumerator GuardBroken()
    {
        onGuard = false;
        onStun = true;
        rb2d.velocity = Vector2.zero;

        var time = new WaitForSeconds(playerStatus.guardBrokenStunTime);
        yield return time;
        onStun = false;

        currentGuardHealth = playerStatus.guardHealth;
    }

    IEnumerator DamagedInvincible()
    {
        onKnockBack = true;
        damagedInvincible = true;

        // Knock Back
        rb2d.velocity = new Vector2((-lookDir) * playerStatus.knockBackForce, rb2d.velocity.y);
        
        var time = new WaitForSeconds(playerStatus.knockBackTime);
        yield return time;
        onKnockBack = false;

        // Invincible
        time = new WaitForSeconds(playerStatus.damagedInvincibleTime);
        yield return time;
        damagedInvincible = false;
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(actionPoint.position, playerStatus.attackRange);

        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, playerStatus.interactionRange);
        
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(groundCheck.position, playerStatus.groundCheckRadius);
    }
}
