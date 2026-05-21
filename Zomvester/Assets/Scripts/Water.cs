using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Water : MonoBehaviour
{
    public Bucket bucket;
    public Sprite filledPool;
    public Sprite emptyPool;

    GameObject Player;
    PlayerControl playerControl;
    SpriteRenderer spriteRenderer;
    GameObject watercup;
    Animator watercupAnim;
    AudioSource audioSource;

    int fillingDelay = 20;
    int poolLife;
    bool isAvailable = true;

    void Awake()
    {
        Player = GameObject.FindWithTag("Player");
        playerControl = Player.GetComponent<PlayerControl>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        audioSource = GetComponent<AudioSource>();

        watercup = transform.GetChild(0).gameObject;
        watercupAnim = watercup.GetComponent<Animator>();
        poolLife = Random.Range(1, 5);
    }

    void OnTriggerStay2D(Collider2D collision)
    {
        if (!isAvailable) return;

        if (collision.gameObject == Player)
        {
            if (!bucket.Filled()) return;
            isAvailable = false;
            spriteRenderer.sprite = emptyPool;
            playerControl.waterRemain = 5;

            StartCoroutine(GainwaterCoroutine());
            StartCoroutine(GetWaterDelay());
        }
        else if(collision.gameObject.layer == 10)
        {
            collision.gameObject.SetActive(false);
        }
    }

    IEnumerator GetWaterDelay()
    {
        var time = new WaitForSeconds(fillingDelay);
        yield return time;
        isAvailable = true;
        spriteRenderer.sprite = filledPool;
    }

    IEnumerator GainwaterCoroutine()
    {
        audioSource.Play();
        watercup.SetActive(true);
        watercupAnim.SetTrigger("isWatering");

        var time = new WaitForSeconds(1f);
        yield return time;
        watercup.SetActive(false);
        if (--poolLife == 0) this.gameObject.SetActive(false);
    }
}
