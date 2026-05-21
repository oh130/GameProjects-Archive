using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class BGM : MonoBehaviour
{
    public static BGM instance;

    public AudioClip bgm_day;
    public AudioClip bgm_night;
    public AudioClip bgm_title;
    public AudioClip bgm_gameover;

    AudioSource audioSource;

    void Awake()
    {
        if (BGM.instance == null) BGM.instance = this;
        audioSource = GetComponent<AudioSource>();
        PlayBGM();
    }

    public void PlayBGM()
    {
        if (SceneManager.GetActiveScene().name == "Title")
        {
            audioSource.clip = bgm_title;
            audioSource.Play();
            audioSource.loop = true;
        }
        else
        {
            if (SceneManager.GetActiveScene().name == "Gameover") audioSource.PlayOneShot(bgm_gameover);
            audioSource.loop = false;
        }
    }

    public void PlayBGM(bool isNight)
    {
        if (isNight)
        {
            audioSource.clip = bgm_night;
            audioSource.Play();
        }
        else
        {
            audioSource.clip = bgm_day;
            audioSource.Play();
        }
    }

    public void IsOnPause(bool isOnPause)
    {
        if (isOnPause) audioSource.Pause();
        else audioSource.Play();
    }
}
