using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ivy : MonoBehaviour
{
    PlantControl plantStatus;
    Animator anim;
    AudioSource audioSource;

    int tieTimer = 10;
    bool isReadyToTie = true;
    float tieRadius = 2.4f;
    float tieReady = 1f;
    float tiedTime = 2.0f;

    void Start()
    {
        plantStatus = GetComponent<PlantControl>();
        anim = transform.GetChild(1).GetComponent<Animator>();
        audioSource = GetComponent<AudioSource>();
    }

    public void StoppingEnemy()
    {
        if (isReadyToTie && plantStatus.growLevel == 3)
        {
            isReadyToTie = false;
            StartCoroutine(Tie());
        }
    }

    IEnumerator Tie()
    {
        var time = new WaitForSeconds(tieReady);
        yield return time;

        anim.SetTrigger("Tying");
        audioSource.Play();

        Collider2D[] collider2Ds = Physics2D.OverlapCircleAll(gameObject.transform.position, tieRadius);

        foreach (Collider2D coll in collider2Ds)
            if (coll.CompareTag("Enemy"))
                coll.GetComponent<EnemyControl>().Stopped(tiedTime);

        StartCoroutine(EndTie());
    }

    IEnumerator EndTie()
    {
        yield return new WaitForSeconds(tieTimer);
        isReadyToTie = true;
    }
}
