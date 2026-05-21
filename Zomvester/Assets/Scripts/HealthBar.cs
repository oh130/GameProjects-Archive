using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthBar : MonoBehaviour
{
    public static HealthBar instance;

    public Text currentHealthText;
    public Image mask;
    float originalSize;

    void Awake()
    {
        instance = this;
    }

    void Start()
    {
        originalSize = mask.rectTransform.rect.width;
    }

    public void SetHealthBar(int currentHealth, int maxHealth)
    {
        currentHealthText.text = currentHealth.ToString();
        mask.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, originalSize * (currentHealth / (float)maxHealth));
    }
}
