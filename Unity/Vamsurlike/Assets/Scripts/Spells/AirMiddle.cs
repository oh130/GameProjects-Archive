using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AirMiddle : MonoBehaviour
{
    #region Variables

    [SerializeField] SpellStatus SS;

    WaitForSeconds lifeTime;

    #endregion

    void Awake()
    {
        lifeTime = new WaitForSeconds(SS.life);
    }

    void OnEnable()
    {
        transform.position = PlayerController.Instance.CurrentPos;

        StartCoroutine(LifeTime());
    }

    IEnumerator LifeTime()
    {
        yield return lifeTime;

        this.gameObject.SetActive(false);
    }
}
