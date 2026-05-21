using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantControl : MonoBehaviour
{
    public int growLevel;
    public Sprite[] sprites;
    public AudioClip harvest;
    public AudioClip levelUp;

    float growTime = 45.0f;
    bool isReadyToGrow;
    bool onDelay;

    AudioSource audioSource;
    SpriteRenderer spriteRenderer;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        spriteRenderer.sprite = sprites[growLevel];
    }

    void Update()
    {
        if (growLevel < 3)
        {
            if (isReadyToGrow)
            {
                spriteRenderer.sprite = sprites[++growLevel];
                isReadyToGrow = false;
            }
            else if (!onDelay)
            {
                onDelay = true;
                StartCoroutine(Grow());
            }
        }
    }

    IEnumerator Grow()
    {
        var time = new WaitForSeconds(growTime);
        yield return time;
        onDelay = false;
        isReadyToGrow = true;
    }

    public void Harvest()
    {
        audioSource.PlayOneShot(harvest);
        if (growLevel == 0)
        {
            gameObject.SetActive(false);
            return;
        }

        spriteRenderer.sprite = sprites[--growLevel];
        GameObject.Find("GameManager").GetComponent<TitleManager>().PopupTutorial(this.gameObject.tag);
    }

    public void Water()
    {
        if (growLevel == 3) return;

        audioSource.PlayOneShot(levelUp);
        spriteRenderer.sprite = sprites[++growLevel];
    }
}
