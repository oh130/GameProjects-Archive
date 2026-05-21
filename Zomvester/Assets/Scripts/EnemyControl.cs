using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EnemyControl : MonoBehaviour
{
    public bool isDie;
    public AudioClip zombieAttacked;
    public AudioClip zombieDeath;

    int damage;
    int health;
    float moveSpeed;
    bool isTied;
    bool damaged;
    float damagedForce = 4f;
    float damagedTime = 0.3f;
    float timer;

    int defDamage = 7;
    int defHealth = 14;
    float defMoveSpeed = 2f;

    Vector2 dir;

    GameObject target;
    AudioSource audioSource;
    Rigidbody2D rb2d;
    Animator anim;
    BoxCollider2D coll;
    PlayerControl playerControl;
    SpriteRenderer spriteRenderer;

    void Awake()
    {
        target = GameObject.FindWithTag("Player");
        audioSource = GetComponent<AudioSource>(); 
        rb2d = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        coll = GetComponent<BoxCollider2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        playerControl = target.GetComponent<PlayerControl>();

        init(0.7f);
    }

    public void init(float zombieStatus)
    {
        isDie = false;
        isTied = false;
        anim.enabled = true;
        coll.enabled = true;

        health = (int)(defHealth * zombieStatus);
        damage = (int)(defDamage * zombieStatus);
        if(GlobalLightControl.isNight) moveSpeed = Mathf.Clamp(defMoveSpeed * (1f + (zombieStatus - 1f) * 0.2f), 2f, 6.3f);
        else moveSpeed = Mathf.Clamp(defMoveSpeed * (1f + (zombieStatus - 1f) * 0.2f), 1.4f, 4.3f);
    }

    void Update()
    {
        if (TitleManager.isOnPause) return;

        rb2d.AddForce(Vector2.zero);

        if (damaged)
        {
            timer += Time.deltaTime;
            if (timer >= damagedTime)
            {
                timer = 0;
                damaged = false;
                spriteRenderer.color = new Color32(255, 255, 255, 255);
            }
        }
    }

    void Move()
    {
        float horizontalDir = target.transform.position.x - transform.position.x;
        if(horizontalDir < 0) spriteRenderer.flipX = true;
        else if (horizontalDir > 0) spriteRenderer.flipX = false;

        dir = new Vector2(horizontalDir, target.transform.position.y - transform.position.y).normalized;
        rb2d.position += dir * moveSpeed * Time.deltaTime;

        if (damaged) rb2d.position -= dir * damagedForce * Time.deltaTime;
    }

    void FixedUpdate()
    {
        if (isDie || isTied || TitleManager.isOnPause) return;
        Move();
    }
    
    void OnCollisionStay2D(Collision2D collision)
    {
        if(collision.gameObject == target)
        {
            playerControl.ChangeHealth(-damage);
        }
    }

    public void Attacked(int attackDamage)
    {
        if (isDie) return;

        audioSource.PlayOneShot(zombieAttacked);
        damaged = true;
        spriteRenderer.color = new Color32(255, 255, 255, 128);
        
        health -= attackDamage;
        if(health <= 0)
        {
            isDie = true;
            rb2d.velocity = Vector2.zero;
            anim.enabled = false;
            coll.enabled = false;
            audioSource.PlayOneShot(zombieDeath);
            
            StartCoroutine(DieCoroutine());
        }
    }

    public void Stopped(float stopTime)
    {
        if (isDie) return;
        isTied = true;
        anim.enabled = false;
        StartCoroutine(StopTimeDelay(stopTime));
    }

    IEnumerator DieCoroutine()
    {
        var time = new WaitForSeconds(0.7f);
        yield return time;

        playerControl.GetKillScore();

        if (Random.Range(0.00f, 1.00f) >= 0.7f)
        {
            GameManager.MakePlant(rb2d.position);
        }
        gameObject.SetActive(false);
    }

    IEnumerator StopTimeDelay(float stopTime)
    {
        var time = new WaitForSeconds(stopTime);
        yield return time;
        isTied = false;
        anim.enabled = true;
    }
}
