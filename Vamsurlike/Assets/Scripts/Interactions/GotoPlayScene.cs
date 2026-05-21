using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GotoPlayScene : MonoBehaviour
{
    public void PlayScene()
    {
        SceneManager.LoadScene("Scene0");
    }
}
