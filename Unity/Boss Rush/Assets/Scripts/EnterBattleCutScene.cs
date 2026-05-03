using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;
using UnityEngine.Playables;

public class EnterBattleCutScene : MonoBehaviour
{
    public PlayableDirector PD;
    public GameObject Boss;
    public GameObject BossHealthBar;
    public CinemachineVirtualCamera BossRoom;
    public float cutSceneTime;

    void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            BossRoom.Priority = 11;
            PD.Play();
            Boss.SetActive(true);
            StaticVariables.onCutScene = true;
            StartCoroutine(CutScene());
        }
    }

    IEnumerator CutScene()
    {
        var time = new WaitForSeconds(cutSceneTime);
        yield return time;
        BossHealthBar.SetActive(true);
        StaticVariables.onCutScene = false;
        this.gameObject.SetActive(false);
    }
}
