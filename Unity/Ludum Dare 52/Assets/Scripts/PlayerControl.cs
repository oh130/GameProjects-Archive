using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UI;

public class PlayerControl : MonoBehaviour
{
    public Vector2 boxSize;
    public Bucket bucket;
    public bool isDie;
    public Text killScoreText;
    public Text[] abilityTexts;
    public Text[] statTexts;
    public GameObject tie;
    public GameObject bomb;
    public AudioClip[] audioClips;
    public int waterRemain;

    public static int killScore;

    struct Stats
    {
        public int campanulaStat;
        public int nepenthesStat;
        public int ivyStat;
        public int cistusStat;
    };

    Stats playerStat;

    // Player Status.
    int maxHealth = 100;
    int currentHealth = 100;
    int strength = 5;
    int regeneration = 1;
    float playerSightRange = 5f;
    const float moveSpeed = 6f;
    const float attackDelay = 0.7f;
    Vector2 dir;

    // Is Damaged.
    bool isInvincible;
    float invincibleTime = 0.8f;

    bool isDelay;
    bool getRegeneration = true;

    //Plant Ability.
    float regenerationStack;
    float shootingCooldown = 1.8f;
    float tieSurroundCooldown = 18.0f;
    float tieSurroundTime = 1;
    const float tieSurroundRadius = 2.4f;
    float specialAttackCooldown = 35.0f;
    float strengthStack;

    //Ability Coroutine.
    bool shootReady;
    bool tieReady;
    bool specialAttackReady;

    //Plant Stack.
    float regPerOne = 0.1f;
    float sightPerOne = 0.15f;
    float shootCooldownPerOne = 0.003f;
    float tieCooldownPerOne = 0.018f;
    float tieTimePerOne = 0.004f;
    int healthPerOne = 2;
    float spAttackCooldownPerOne = 0.06f;
    float strengthPerOne = 0.03f;

    GameObject deathside;
    GameObject watercup;
    DeathsideControl deathsideControl;
    Rigidbody2D rb2d;
    BoxCollider2D coll2d;
    AudioSource audioSource;
    Animator anim;
    Animator watercupAnim;
    Animator tieAnim;
    Animator bombAnim;
    SpriteRenderer spriteRenderer;
    SpriteRenderer watercupSpriteRenderer;
    Light2D light2D;

    void Awake()
    {
        rb2d = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        coll2d = GetComponent<BoxCollider2D>();
        audioSource = GetComponent<AudioSource>();
        deathside = transform.GetChild(2).gameObject;
        deathsideControl = deathside.GetComponent<DeathsideControl>();
        watercup = transform.GetChild(3).gameObject;
        watercupAnim = watercup.GetComponent<Animator>();
        watercupSpriteRenderer = watercup.GetComponent<SpriteRenderer>();
        tieAnim = tie.GetComponent<Animator>();
        bombAnim = bomb.GetComponent<Animator>();
        light2D = transform.GetChild(1).GetComponent<Light2D>();
    }

    void Start()
    {
        StartCoroutine(SpecialAttackCoroutine());
        StartCoroutine(EndTie());
        StartCoroutine(EndShoot());
    }

    void Update()
    {
        if (isDie || TitleManager.isOnPause) return;

        Vector3 pos = Camera.main.WorldToViewportPoint(rb2d.position);

        if (pos.x < 0f) pos.x = 0f;
        else if (pos.x > 1f) pos.x = 1f;
        if (pos.y < 0f) pos.y = 0f;
        else if (pos.y > 1f) pos.y = 1f;

        rb2d.position = Camera.main.ViewportToWorldPoint(pos);

        if(Input.GetMouseButtonDown(0))
        {
            if(isDelay == false)
            {
                isDelay = true;
                Attack();
                StartCoroutine(AttackCoroutine());
            }
        }
        else if(Input.GetMouseButtonDown(1))
        {
            if (isDelay == false && waterRemain != 0)
            {
                isDelay = true;
                StartCoroutine(Watering());
                StartCoroutine(AttackCoroutine());
            }
        }

        if (getRegeneration)
        {
            ChangeHealth(regeneration);
            getRegeneration = false;
            StartCoroutine(RegenerationCoroutine());
        }
    }

    void FixedUpdate()
    {
        if (isDie || TitleManager.isOnPause) return; 
        Move();
    }

    void Move()
    {
        dir = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical")).normalized;

        if (dir == Vector2.zero) anim.SetBool("isWalking", false);
        else anim.SetBool("isWalking", true);
       
        if (Input.GetAxisRaw("Horizontal") < 0)
        {
            spriteRenderer.flipX = true;
            watercupSpriteRenderer.flipX = true;
        }
        else if (Input.GetAxisRaw("Horizontal") > 0)
        {
            spriteRenderer.flipX = false;
            watercupSpriteRenderer.flipX = false;
        }

        rb2d.position += dir * moveSpeed * Time.deltaTime;
    }

    void Attack()
    {
        Vector2 centerOfAttack = deathsideControl.OnAttack();

        Collider2D[] collider2Ds;

        if (specialAttackReady)
        {
            collider2Ds = Physics2D.OverlapBoxAll(centerOfAttack, new Vector2(boxSize.x + 1f, boxSize.y + 0.7f), 0);
            audioSource.PlayOneShot(audioClips[3]);
            bomb.transform.position = centerOfAttack;
            bombAnim.SetTrigger("Bomb");

            StartCoroutine(SpecialAttackCoroutine());
        }
        else
        {
            collider2Ds = Physics2D.OverlapBoxAll(centerOfAttack, boxSize, 0);
            audioSource.PlayOneShot(audioClips[0]);
        }

        foreach (Collider2D coll in collider2Ds)
        {
            switch (coll.tag)
            {
                case "Enemy":
                    if (specialAttackReady) coll.GetComponent<EnemyControl>().Attacked(99999);
                    else coll.GetComponent<EnemyControl>().Attacked(strength);
                    break;
                case "Campanula":
                    coll.GetComponent<PlantControl>().Harvest();
                    statTexts[0].text = (++playerStat.campanulaStat).ToString();
                    regenerationStack += regPerOne;
                    if(regenerationStack >= 1)
                    {
                        regeneration++;
                        regenerationStack -= 1.00f;
                    }
                    playerSightRange += sightPerOne;
                    abilityTexts[0].text = playerSightRange.ToString("F1");
                    light2D.pointLightOuterRadius = playerSightRange;
                    break;
                case "Nepenthes":
                    coll.GetComponent<PlantControl>().Harvest();
                    statTexts[1].text = (++playerStat.nepenthesStat).ToString();
                    shootingCooldown = Mathf.Clamp(shootingCooldown - shootCooldownPerOne, 0.3f, 1.8f);
                    break;
                case "Ivy":
                    coll.GetComponent<PlantControl>().Harvest();
                    statTexts[2].text = (++playerStat.ivyStat).ToString();
                    tieSurroundCooldown = Mathf.Clamp(tieSurroundCooldown - tieCooldownPerOne, 1, 18);
                    tieSurroundTime += tieTimePerOne;
                    maxHealth += healthPerOne;
                    currentHealth += healthPerOne;
                    HealthBar.instance.SetHealthBar(currentHealth, maxHealth);
                    break;
                case "Cistus":
                    coll.GetComponent<PlantControl>().Harvest();
                    statTexts[3].text = (++playerStat.cistusStat).ToString();
                    specialAttackCooldown = Mathf.Clamp(specialAttackCooldown - spAttackCooldownPerOne, 1, 35);
                    strengthStack += strengthPerOne;
                    if (strengthStack >= 1)
                    {
                        strength++;
                        strengthStack -= 1.00f;
                    }
                    break;
                default:
                    break;
            }
        }

        specialAttackReady = false;
    }

    public void ShootEnemy(Vector2 enemyPos)
    {
        if (shootReady)
        {
            shootReady = false;
            Vector2 shootDir = (enemyPos - rb2d.position).normalized;

            audioSource.PlayOneShot(audioClips[1]);
            GameObject projectile = GameManager.MakeProjectile(transform.position);
            if (projectile == null) return;
            projectile.GetComponent<Rigidbody2D>().AddForce((shootDir) * 10.0f, ForceMode2D.Impulse);

            StartCoroutine(EndShoot());
        }
    }

    public void TieEnemy()
    {
        if (tieReady)
        {
            tieReady = false;
            StartCoroutine(Tie());
        }
    }

    public void ChangeHealth(int amount)
    {
        if (isDie || TitleManager.isOnPause) return;

        if(amount < 0)
        {
            if (isInvincible) return;
            if (currentHealth + amount <= 0)
            {
                isDie = true;
                GameManager.GameOver();
                return;
            }

            audioSource.PlayOneShot(audioClips[5]);
            isInvincible = true;
            coll2d.enabled = false;
            StartCoroutine(InvincibleCoroutine());
        }

        currentHealth = Mathf.Clamp(currentHealth + amount, 0, maxHealth);
        HealthBar.instance.SetHealthBar(currentHealth, maxHealth);
    }

    public void GetKillScore()
    {
        killScoreText.text = (++killScore).ToString();
    }

    IEnumerator AttackCoroutine()
    {
        var time = new WaitForSeconds(attackDelay);
        yield return time;
        isDelay = false;
    }

    IEnumerator Watering()
    {
        deathside.SetActive(false);
        watercup.SetActive(true);

        watercupAnim.SetTrigger("isWatering");
        bucket.Used(--waterRemain);
        audioSource.PlayOneShot(audioClips[6]);

        Collider2D[] collider2Ds;
        collider2Ds = Physics2D.OverlapBoxAll(transform.position, new Vector2(2.5f, 2.5f), 0);

        foreach (Collider2D coll in collider2Ds)
            if (coll.gameObject.layer == 10)
                coll.GetComponent<PlantControl>().Water();

        var time = new WaitForSeconds(0.683f);
        yield return time;

        watercup.SetActive(false);
        deathside.SetActive(true);
    }

    IEnumerator InvincibleCoroutine()
    {
        var time = new WaitForSeconds(0.1f * invincibleTime);
        int countTime = 0;

        while (countTime < 10)
        {
            if (countTime % 2 == 0)
                spriteRenderer.color = new Color32(255, 255, 255, 70);
            else
                spriteRenderer.color = new Color32(255, 255, 255, 180);

            yield return time;

            countTime++;
        }

        spriteRenderer.color = new Color32(255, 255, 255, 255);
        isInvincible = false;
        coll2d.enabled = true;

        yield return null;
    }

    IEnumerator RegenerationCoroutine()
    {
        var time = new WaitForSeconds(1);
        yield return time;
        getRegeneration = true;
    }

    IEnumerator EndShoot()
    {
        int shootPercentage = 0;
        abilityTexts[1].text = "0%";
        var time = new WaitForSeconds(shootingCooldown * 0.01f);

        while (shootPercentage < 100)
        {
            yield return time;
            abilityTexts[1].text = (++shootPercentage).ToString() + "%";
        }

        shootReady = true;
        yield return null;
    }

    IEnumerator Tie()
    {
        int timeCount = 2;
        var time = new WaitForSeconds(1);
        abilityTexts[2].text = "2";

        while(timeCount > 0)
        {
            yield return time;
            abilityTexts[2].text = (--timeCount).ToString();
        }

        tie.transform.position = rb2d.position;
        tieAnim.SetTrigger("Tying");
        audioSource.PlayOneShot(audioClips[2]);

        Collider2D[] collider2Ds = Physics2D.OverlapCircleAll(rb2d.position, tieSurroundRadius);

        foreach (Collider2D coll in collider2Ds)
            if (coll.CompareTag("Enemy"))
                coll.GetComponent<EnemyControl>().Stopped(tieSurroundTime);

        yield return StartCoroutine(EndTie());
    }

    IEnumerator EndTie()
    {
        int tiePercentage = 0;
        abilityTexts[2].text = "0%";
        var time = new WaitForSeconds(tieSurroundCooldown * 0.01f);

        while (tiePercentage < 100)
        {
            yield return time;
            abilityTexts[2].text = (++tiePercentage).ToString() + "%";
        }

        tieReady = true;
        yield return null;
    }

    IEnumerator SpecialAttackCoroutine()
    {
        int specialAttackPercentage = 0;
        abilityTexts[3].text = "0%";
        var time = new WaitForSeconds(specialAttackCooldown * 0.01f);

        while (specialAttackPercentage < 100)
        {
            yield return time;
            abilityTexts[3].text = (++specialAttackPercentage).ToString() + "%";
        }

        specialAttackReady = true;
        audioSource.PlayOneShot(audioClips[4]);
        yield return null;
    }
}
