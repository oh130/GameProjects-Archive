using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ion : MonoBehaviour
{
    #region Variables

    [SerializeField] SpellStatus SS;

    WaitForSeconds effectTime;

    HashSet<GameObject> hitEnemiesCheck;

    // Ion's SS.speed = total enemy hit count restrict.

    #endregion

    void Awake()
    {
        effectTime = new WaitForSeconds(SS.life);
        hitEnemiesCheck = new HashSet<GameObject>();
    }

    void OnEnable()
    {
        transform.position = PlayerController.Instance.CurrentPos;

        StartCoroutine(ElectricChain((int)SS.speed));
    }

    IEnumerator ElectricChain(int remainHit)
    {
        // electric effect
        yield return effectTime;

        // chaining end
        if (remainHit == 0)
        {
            hitEnemiesCheck.Clear();
            this.gameObject.SetActive(false);
            yield return null;
        }

        // find nearest, not hit enemy
        Collider2D[] targets = Physics2D.OverlapCircleAll(transform.position, SS.range, GameManager.Instance.EnemyLayer);
        float closestDist = float.MaxValue;
        GameObject target = null;

        foreach (Collider2D col in targets)
        {
            if (hitEnemiesCheck.Contains(col.gameObject)) continue;

            float distance = Vector2.Distance(transform.position, col.transform.position);
            if (distance < closestDist)
            {
                closestDist = distance;
                target = col.gameObject;
            }
        }

        // if target exists, move to target, add to hitHash, give damage, recursive.
        if (target)
        {
            hitEnemiesCheck.Add(target);
            transform.position = target.transform.position;
            target.GetComponent<IEnemyInterface>().Damaged(SS.damage, (int)GameManager.Element.Ion);
            StartCoroutine(ElectricChain(--remainHit));
        }
        else
        {
            hitEnemiesCheck.Clear();
            this.gameObject.SetActive(false);
        }
    }
}
