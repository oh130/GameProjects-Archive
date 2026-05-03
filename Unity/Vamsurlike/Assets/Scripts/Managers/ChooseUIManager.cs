using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEditor.Experimental.GraphView;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class ChooseUIManager : MonoBehaviour
{
    #region Variables

    /*
    
    ChooseUIManager has...

    1. management all ui when enhance player
    2. management input when on choose ui
    3. all variables about choose ui

    */

    [Header("Scroll View")]
    [SerializeField] ScrollRect scrollRect;
    [SerializeField] RectTransform contentPanel;
    [SerializeField] float zoomRate;
    [SerializeField] float maxZoom;
    [SerializeField] float minZoom;
    float zoomInput;

    [Header("Buttons")]
    [SerializeField] GameObject confirmButton;
    [SerializeField] GameObject baseButton;
    [SerializeField] GameObject spellRootButton;
    [SerializeField] GameObject upgradeButton;
    /*
    [SerializeField] Image[] spellButtonImages;
    [SerializeField] Color[] spellButtonColors;
    */
    int currentButtonOrder;
    GameObject currentChooseButton;
    GameObject lastChosenButton;

    [Header("Stat Texts")]
    [SerializeField] TextMeshProUGUI[] elementLevelTexts;
    [SerializeField] TextMeshProUGUI[] statTexts;
    [SerializeField] TextMeshProUGUI upText;
    [SerializeField] string maxString;
    [SerializeField] string[] upStrings;

    [Header("Variables")]
    [SerializeField] SpellCost[] spellCosts;
    [SerializeField] int elementMaxLv;
    int[] elementLevel;
    bool[] learnable;

    [Header("Spell Cost UI")]
    [SerializeField] GameObject spellCostTheme;
    [SerializeField] TextMeshProUGUI etherCostText;
    [SerializeField] TextMeshProUGUI[] elementNeedText;

    public SpellCost[] SpellCosts { get { return spellCosts; } }

    #endregion

    /*
    
    Button Mapping

    0~7. Elements
    8~. Spells

    Spell Button Color

    0. deactive
    1. active
    2. focused
    3. learned

    Up Strings

    0. up
    1. max lv
    2. condition lack
    3. exit
    4. -

    */

    void Awake()
    {
        elementLevel = new int[GameManager.Instance.TotalElementCount];
        learnable = new bool[GameManager.Instance.TotalSpellCount];
    }

    void OnEnable()
    {
        lastChosenButton = spellRootButton;
        EventSystem.current.SetSelectedGameObject(spellRootButton);
        spellCostTheme.SetActive(false);
        ChangeUpText(1);
        CheckLearnableSpell();
    }

    void Update()
    {
        #region Button Management

        // get current choose button
        currentChooseButton = EventSystem.current.currentSelectedGameObject;

        // if current button is changed
        if (currentChooseButton != lastChosenButton)
        {
            if (currentChooseButton == baseButton)
            {
                // change deny
                currentChooseButton = lastChosenButton;
                EventSystem.current.SetSelectedGameObject(lastChosenButton);
                return;
            }

            if (currentChooseButton == upgradeButton)
            {
                // upgrade last button
                Upgrade();

                // change deny
                currentChooseButton = lastChosenButton;
                EventSystem.current.SetSelectedGameObject(lastChosenButton);
                if (currentButtonOrder < GameManager.Instance.TotalElementCount)
                {
                    SetSelectedElement(currentButtonOrder);
                }
                else
                {
                    SetSelectedSpell(currentButtonOrder - GameManager.Instance.TotalElementCount);
                }
                return;
            }

            if (lastChosenButton == spellRootButton || lastChosenButton == confirmButton || lastChosenButton == null)
            {
                // continue
            }
            else if (currentButtonOrder < GameManager.Instance.TotalElementCount)
            {
                DeselectElement(currentButtonOrder);
            }
            else
            {
                DeselectSpell(currentButtonOrder - GameManager.Instance.TotalElementCount);
            }

            lastChosenButton = currentChooseButton;

            // if on scroll view
            if (currentChooseButton == null)
            {
                ChangeUpText(4);
                return;
            }

            // if on spell root
            if (currentChooseButton == spellRootButton)
            {
                // focus scroll view to this spell
                SnapTo(currentChooseButton.GetComponent<RectTransform>());
                ChangeUpText(1);
                return;
            }

            // if on confirm button
            if (currentChooseButton == confirmButton)
            {
                ChangeUpText(3);
                return;
            }

            currentButtonOrder = int.Parse(currentChooseButton.name);

            if (currentButtonOrder < GameManager.Instance.TotalElementCount)
            {
                SetSelectedElement(currentButtonOrder);
            }
            else
            {
                SetSelectedSpell(currentButtonOrder - GameManager.Instance.TotalElementCount);
            }
        }

        #endregion

        #region Zoom Management

        if (zoomInput < 0 && contentPanel.localScale.x > maxZoom)
        {
            contentPanel.localScale = new Vector3(contentPanel.localScale.x - Time.unscaledDeltaTime * zoomRate,
                contentPanel.localScale.y - Time.unscaledDeltaTime * zoomRate, contentPanel.localScale.z);
        }
        else if (zoomInput > 0 && contentPanel.localScale.x < minZoom)
        {
            contentPanel.localScale = new Vector3(contentPanel.localScale.x + Time.unscaledDeltaTime * zoomRate,
                contentPanel.localScale.y + Time.unscaledDeltaTime * zoomRate, contentPanel.localScale.z);
        }

        #endregion
    }

    void SetSelectedElement(int element)
    {
        statTexts[element].color = Color.magenta;
        elementLevelTexts[element].color = Color.magenta;

        if (elementLevel[element] == elementMaxLv)
        {
            ChangeUpText(1);
            return;
        }

        if (GameManager.Instance.CurrentEtherCrystal == 0)
        {
            ChangeUpText(2);
        }
        else
        {
            ChangeUpText(0);
        }

        if (elementLevel[element] == elementMaxLv - 1)
        {
            elementLevelTexts[element].text = maxString;
        }
        else
        {
            elementLevelTexts[element].text = (elementLevel[element] + 1).ToString();
        }

        statTexts[element].text = element switch
        {
            3 or 5 => string.Format("{0:F1}", GameManager.Instance.CurrentStats[element] + GameManager.Instance.AddAmountPerStat[element]),
            4 or 6 => string.Format("- {0:0}%", GameManager.Instance.CurrentStats[element] + GameManager.Instance.AddAmountPerStat[element]),
            _ => string.Format("+ {0:0}%", GameManager.Instance.CurrentStats[element] + GameManager.Instance.AddAmountPerStat[element]),
        };
    }

    void DeselectElement(int element)
    {
        statTexts[element].color = Color.white;
        elementLevelTexts[element].color = Color.white;

        if (elementLevel[element] == elementMaxLv)
        {
            return;
        }

        elementLevelTexts[element].text = elementLevel[element].ToString();

        statTexts[element].text = element switch
        {
            3 or 5 => string.Format("{0:F1}", GameManager.Instance.CurrentStats[element]),
            4 or 6 => string.Format("- {0:0}%", GameManager.Instance.CurrentStats[element]),
            _ => string.Format("+ {0:0}%", GameManager.Instance.CurrentStats[element]),
        };
    }

    void SetSelectedSpell(int spell)
    {
        // focus scroll view to this spell
        SnapTo(currentChooseButton.GetComponent<RectTransform>());

        if (GameManager.Instance.LearnedSpell[spell])
        {
            ChangeUpText(1);
            spellCostTheme.SetActive(false);
            return;
        }

        for (int i = 0; i < GameManager.Instance.TotalElementCount; ++i)
        {
            elementNeedText[i].color = Color.white;

            // Ether Cost
            if (spellCosts[spell].etherCost == 0)
            {
                etherCostText.text = "-";
            }
            else
            {
                etherCostText.text = spellCosts[spell].etherCost.ToString();
                etherCostText.color = Color.white;
                if (GameManager.Instance.CurrentEther < spellCosts[spell].etherCost)
                {
                    etherCostText.color = Color.red;
                }
            }

            // Need Elements
            if (spellCosts[spell].needElements[i] == 0)
            {
                elementNeedText[i].text = "-";
            }
            else
            {
                elementNeedText[i].text = spellCosts[spell].needElements[i].ToString();
                if (elementLevel[i] < spellCosts[spell].needElements[i])
                {
                    elementNeedText[i].color = Color.red;
                }
            }
        }

        if (learnable[spell])
        {
            ChangeUpText(0);
        }
        else
        {
            ChangeUpText(2);
        }

        spellCostTheme.SetActive(true);
        // spellButtonImages[spell].color = spellButtonColors[2];
    }

    void DeselectSpell(int spell)
    {
        /*
        if (GameManager.Instance.LearnedSpell[spell])
        {
            spellButtonImages[spell].color = spellButtonColors[3];
        }
        else
        {
            if (learnable[spell])
            {
                spellButtonImages[spell].color = spellButtonColors[1];
            }
            else
            {
                spellButtonImages[spell].color = spellButtonColors[0];
            }
        }
        */

        spellCostTheme.SetActive(false);
    }

    void CheckLearnableSpell()
    {
        // Check Prerequire Spells

        // Check Resources
        for (int spell = 0; spell < GameManager.Instance.TotalSpellCount; ++spell)
        {
            learnable[spell] = true;

            if (GameManager.Instance.CurrentEther >= spellCosts[spell].etherCost)
            {
                for (int elem = 0; elem < GameManager.Instance.TotalElementCount; ++elem)
                {
                    if (elementLevel[elem] < spellCosts[spell].needElements[elem])
                    {
                        learnable[spell] = false;
                        break;
                    }
                }
            }
            else
            {
                learnable[spell] = false;
            }
            
            /*
            if (learnable[spell])
            {
                spellButtonImages[spell].color = spellButtonColors[1];
            }
            else
            {
                spellButtonImages[spell].color = spellButtonColors[0];
            }
            */
        }
    }

    void SnapTo(RectTransform target)
    {
        contentPanel.anchoredPosition
            = (Vector2)scrollRect.transform.InverseTransformPoint(contentPanel.position)
            - (Vector2)scrollRect.transform.InverseTransformPoint(target.position);
    }

    void ChangeUpText(int status)
    {
        upText.text = upStrings[status];

        upText.color = status switch
        {
            0 => Color.black,
            1 => Color.blue,
            2 => Color.red,
            3 => Color.green,
            _ => Color.black,
        };
    }

    public void OnConfirmButtonClick()
    {
        GameManager.Instance.CloseChooseUI();
    }

    public void Upgrade()
    {
        if (lastChosenButton == null || lastChosenButton == confirmButton || lastChosenButton == spellRootButton)
        {
            return;
        }

        if (currentButtonOrder < GameManager.Instance.TotalElementCount)
        {
            if (elementLevel[currentButtonOrder] == elementMaxLv || GameManager.Instance.CurrentEtherCrystal == 0)
            {
                return;
            }

            // element level up
            elementLevel[currentButtonOrder]++;

            // stat up
            GameManager.Instance.ReinforcedElement(currentButtonOrder);
        }
        else
        {
            if (GameManager.Instance.LearnedSpell[currentButtonOrder - GameManager.Instance.TotalElementCount]
                || !learnable[currentButtonOrder - GameManager.Instance.TotalElementCount])
            {
                return;
            }

            GameManager.Instance.LearningSpell(currentButtonOrder - GameManager.Instance.TotalElementCount);
        }

        CheckLearnableSpell();
    }

    // Enter Pressed
    public void OnSubmit(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            if (currentChooseButton == confirmButton)
            {
                OnConfirmButtonClick();
                return;
            }

            EventSystem.current.SetSelectedGameObject(upgradeButton);
        }
    }

    public void OnZoomInOut(InputAction.CallbackContext context)
    {
        zoomInput = Mouse.current.scroll.ReadValue().y;
    }
}

[System.Serializable]
public class SpellCost
{
    public int etherCost;
    public int[] needElements;
}