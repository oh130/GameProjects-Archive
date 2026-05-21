using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.UI;

public class TitleManager : MonoBehaviour
{
    public static bool isOnPause = false;
    
    public GameObject popup;
    public Text score;
    public Text playtime;
    public AudioClip pause;
    public AudioClip unPause;

    public Sprite[] Tuto_plant = new Sprite[4];
    public static bool[] isTutoFinished;
    public GameObject tutorial;
    public Text tuto_title;
    public Text tuto_text;
    public Image tuto_image;

    AudioSource audioSource;

    void Start()
    {
        if(isTutoFinished == null)
        {
            isTutoFinished = new bool[4];
        }
        audioSource = GetComponent<AudioSource>();

        if (SceneManager.GetActiveScene().name == "Gameover")
        {
            score.text = "You Harvested " + PlayerControl.killScore + " Zombies";
            playtime.text = "You Survived For " + GlobalLightControl.day + " Days";
        }
    }

    void Update()
    {
        if (Input.GetButtonDown("Cancel") && SceneManager.GetActiveScene().name == "Gameplay"){
            if(tutorial.activeSelf == true)
            {
                isOnPause = false;
                BGM.instance.IsOnPause(isOnPause);
                Time.timeScale = 1f;
                tutorial.SetActive(false);
            }
            else
            {
                if (popup.activeSelf == false)
                {
                    isOnPause = true;
                    BGM.instance.IsOnPause(isOnPause);
                    audioSource.PlayOneShot(pause);
                    Time.timeScale = 0f;
                    popup.SetActive(true);
                }
                else Button_Resume();
            }
        }
    }

    public void Button_Resume()
    {
        isOnPause = false;
        BGM.instance.IsOnPause(isOnPause);
        audioSource.PlayOneShot(unPause);
        Time.timeScale = 1f;
        popup.SetActive(false);
    }

    public void Button_Play()
    {
        SceneManager.LoadScene("Gameplay");
    }
    public void Button_Quit()
    {
        Application.Quit();
    }
    public void PopupTutorial(string name)
    {
        int type = 0;
        switch (name)
        {
            case "Campanula":
                type = 0;
                break;
            case "Nepenthes":
                type = 1;
                break;
            case "Ivy":
                type = 2;
                break;
            case "Cistus":
                type = 3;
                break;
        }

        if (isTutoFinished[type]) return;

        isOnPause = true;
        BGM.instance.IsOnPause(isOnPause);
        Time.timeScale = 0f;
        tutorial.SetActive(true);
        switch (name)
        {
            case "Campanula":
                tuto_title.text = "Bellflower";
                tuto_text.text = "You harvested bellflower.\nYour sight and health generation increased.";
                tuto_image.sprite = Tuto_plant[0];
                isTutoFinished[0] = true;
                break;
            case "Nepenthes":
                tuto_title.text = "Nepenthes";
                tuto_text.text = "You harvested Nepenthes.\nFire acid saliva at a nearby enemy.";
                tuto_image.sprite = Tuto_plant[1];
                isTutoFinished[1] = true;
                break;
            case "Ivy":
                tuto_title.text = "Ivy";
                tuto_text.text = "You harvested Ivy.\nSummon vines that bind zombies. And, increases the player¡¯s max HP.";
                tuto_image.sprite = Tuto_plant[2];
                isTutoFinished[2] = true;
                break;
            case "Cistus":
                tuto_title.text = "Cistus";
                tuto_text.text = "You harvested Cistus.\nCharge the explosion attack that instantly kill zombies. And, Increases the player¡¯s melee damage.";
                tuto_image.sprite = Tuto_plant[3];
                isTutoFinished[3] = true;
                break;
        }
    }
}
