using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathsideControl : MonoBehaviour
{
    public Transform player;

    Vector2 currentMouseDir;
    Vector2 centerOfAttackArea;
    Vector2 rotateCenter;
    float rotateRadiusOfSprite = 0.32f;
    float rotateRadiusOfAttackArea = 0.9f;
    float attackAnimationLen = 0.583f;
    bool onAttackAnimation;

    Animator anim;
    SpriteRenderer spriteRenderer;

    void Awake()
    {
        anim = GetComponent<Animator>();
        spriteRenderer = GetComponent<SpriteRenderer>();
    }

    void Update()
    {
        if (onAttackAnimation) return;

        Vector2 currentMousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        rotateCenter = new Vector2(player.position.x, player.position.y - 0.2f);

        currentMouseDir = (currentMousePos - rotateCenter).normalized;

        if (currentMouseDir.x < 0)
        {
            spriteRenderer.flipX = true;
            transform.position = new Vector2(rotateCenter.x - rotateRadiusOfSprite, rotateCenter.y);
        }
        else
        {
            spriteRenderer.flipX = false;
            transform.position = new Vector2(rotateCenter.x + rotateRadiusOfSprite, rotateCenter.y);
        }

        transform.rotation = Quaternion.Euler(0, 0, 0);
    }

    public Vector2 OnAttack()
    {
        transform.position = rotateCenter + currentMouseDir * rotateRadiusOfSprite;
        centerOfAttackArea = new Vector2(rotateCenter.x, rotateCenter.y + 0.2f) + currentMouseDir * rotateRadiusOfAttackArea;

        float zComp = currentMouseDir.y * 90;
        if (currentMouseDir.x < 0) zComp = -zComp;
        transform.rotation = Quaternion.Euler(0,0,zComp);

        anim.SetTrigger("isAttack");
        onAttackAnimation = true;
        StartCoroutine(AnimationDelay());

        return centerOfAttackArea;
    }

    IEnumerator AnimationDelay()
    {
        var time = new WaitForSeconds(attackAnimationLen);
        yield return time;
        onAttackAnimation = false;
    }
}
