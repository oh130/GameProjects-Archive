using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EarthMiddle : MonoBehaviour
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

    void FixedUpdate()
    {
        transform.position = PlayerController.Instance.CurrentPos;
        transform.Rotate(SS.speed * Time.fixedDeltaTime * Vector3.forward);
    }

    IEnumerator LifeTime()
    {
        yield return lifeTime;

        this.gameObject.SetActive(false);
    }
}
