using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cistus : MonoBehaviour
{
    public Sprite chargedSprite;
    public Sprite onDelaySprite;

    PlantControl plantStatus;
    Animator anim;
    SpriteRenderer spriteRenderer;
    AudioSource audioSource;

    int bomberTimer = 30;
    bool isReadyToBomb = true;
    float bombRadius = 2.4f;
    float bombReady = 1f;

    void Start()
    {
        plantStatus = GetComponent<PlantControl>();
        anim = transform.GetChild(1).GetComponent<Animator>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        audioSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        if (plantStatus.growLevel == 3)
        {
            if (!isReadyToBomb) spriteRenderer.sprite = onDelaySprite;
            else spriteRenderer.sprite = chargedSprite;
        }
    }

    public void FireTheBomber()
    {
        if (isReadyToBomb && plantStatus.growLevel == 3)
        {
            isReadyToBomb = false;
            StartCoroutine(Bomb());
        }
    }

    IEnumerator Bomb()
    {
        var time = new WaitForSeconds(bombReady);
        yield return time;
        audioSource.Play();
        anim.SetTrigger("Bomb");

        Collider2D[] collider2Ds = Physics2D.OverlapCircleAll(gameObject.transform.position, bombRadius);

        foreach (Collider2D coll in collider2Ds)
            if (coll.CompareTag("Enemy"))
                coll.GetComponent<EnemyControl>().Attacked(99999);

        StartCoroutine(EndBomb());
    }

    IEnumerator EndBomb()
    {
        yield return new WaitForSeconds(bomberTimer);
        isReadyToBomb = true;
    }
}
