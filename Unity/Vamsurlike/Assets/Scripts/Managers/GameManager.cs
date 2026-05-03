using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

public class GameManager : MonoBehaviour
{
    #region Variables

    /*
    
    GameManager has...

    1. MOST variables (element, game status...)
    2. instance can be called anywhere (get pause, using variable...)
    3. player status, enemy status total management and assign
    4. simple UI and Text management
    5. world information (kill, level...)
    6. connect with other scripts, pools

    */

    // Singleton
    static GameManager instance;
    public static GameManager Instance { get { return instance; } }

    // Enum
    public enum Element
    {
        Fire = 0,
        Water,
        Ion,
        Earth,
        Air,
        Life,
        Light,
        Darkness
    }
    public enum Layer
    {
        Player = 3,
        OuterMapWall = 6,
        Enemy = 7,
        Magnet = 8,
        UnorderedButtonUI = 14,
    }

    [Header("Player")]
    [SerializeField] PlayerController playerController;

    [Header("UI Group")]
    [SerializeField] Canvas PlayUI1;
    [SerializeField] Canvas PlayUI2;
    [SerializeField] Canvas ChooseUI1;
    [SerializeField] Canvas ChooseUI2;
    [SerializeField] Canvas PauseUI;

    [Header("UI Variables")]
    [SerializeField] ChooseUIManager chooseUIManager;

    [Header("Exp and Level")]
    [SerializeField] Slider ExpSlider;
    [SerializeField] TextMeshProUGUI levelText;
    [SerializeField] float expForLevelUp;
    [SerializeField] float expAdd;
    int level;
    float currentExp;

    [Header("Elements and Spells")]
    [SerializeField] SpellManager spellPool;
    [SerializeField] int totalElementCount;
    [SerializeField] int totalSpellCount;
    // determine learned spell
    bool[] learnedSpell;
    // determine casting this spell now
    bool[] spellCasting;
    // determine element is used by spell, so other can't use
    bool[] elementDeactive;

    [Header("Stats")]
    [SerializeField] float[] currentStats;
    [SerializeField] float[] addAmountPerStat;

    [Header("Time and Killscore")]
    [SerializeField] TextMeshProUGUI curTimeText;
    [SerializeField] TextMeshProUGUI totalKillScoreText;
    int curTime;
    int totalKillScore;

    [Header("Collectable and Current Resources")]
    [SerializeField] LayerMask collectableLayer;
    [SerializeField] MagnetField magnetField;
    [SerializeField] TextMeshProUGUI currentEtherText;
    [SerializeField] TextMeshProUGUI currentEtherCrystalText;
    [SerializeField] int currentEther;
    [SerializeField] int currentEtherCrystal;
    [SerializeField] float collectableLifeTime;
    WaitForSeconds collectableLife;

    [Header("Enemy")]
    [SerializeField] EnemyManager enemyPool;
    [SerializeField] Material defMaterial;
    [SerializeField] Material flashWhiteMaterial;
    [SerializeField] LayerMask enemyLayer;
    [SerializeField] int waterGroupCount;
    [SerializeField] int airGroupCount;
    [SerializeField] float ionCritPercentage;
    [SerializeField] float ionCritMultiply;
    [SerializeField] float appDelay;
    [SerializeField] float oneSec;
    [SerializeField] float knockBackTime;
    [SerializeField] float invincibleTime;
    WaitForSeconds fixedTimeDelay;
    WaitForSeconds appropriateDelay;
    WaitForSeconds oneSecDelay;
    WaitForSeconds enemyKnockBackTime;
    WaitForSeconds enemyInvincibleTime;

    [Header("Dominance and Inferior")]
    [SerializeField] int[] dominanceType;
    [SerializeField] int[] inferiorType;

    // Gameplay status bool variables
    bool onPause;
    bool onChoose;
    bool playerDeath;
    bool notOnLive;

    // Get properties

    public int TotalElementCount { get { return totalElementCount; } }
    public int TotalSpellCount { get { return totalSpellCount; } }
    public bool[] LearnedSpell { get { return learnedSpell; } }
    public bool[] SpellCasting { get { return spellCasting; } }

    public float[] CurrentStats { get { return currentStats; } }
    public float[] AddAmountPerStat { get { return addAmountPerStat; } }

    public float CurrentEther { get { return currentEther; } }
    public float CurrentEtherCrystal { get { return currentEtherCrystal; } }
    public LayerMask CollectableLayer { get { return collectableLayer; } }
    public WaitForSeconds CollectableLife { get { return collectableLife; } }

    public Material DefMaterial { get { return defMaterial; } }
    public Material FlashWhiteMaterial { get { return flashWhiteMaterial; } }
    public LayerMask EnemyLayer { get { return enemyLayer; } }
    public int WaterGroupCount { get { return waterGroupCount; } }
    public int AirGroupCount { get { return airGroupCount; } }
    public float IonCritPercentage { get { return ionCritPercentage; } }
    public float IonCritMultiply { get { return ionCritMultiply; } }
    public WaitForSeconds FixedTimeDelay { get { return fixedTimeDelay; } }
    public WaitForSeconds AppropriateDelay { get { return appropriateDelay; } }
    public WaitForSeconds OneSecDelay { get { return oneSecDelay; } }
    public WaitForSeconds KnockBackTime { get { return enemyKnockBackTime; } }
    public WaitForSeconds InvincibleTime { get { return enemyInvincibleTime; } }

    public int[] DominanceType { get { return dominanceType; } }
    public int[] InferiorType { get { return inferiorType; } }

    public bool OnPause { get { return onPause; } }
    public bool OnChoose { get { return onChoose; } }
    public bool PlayerDeath { get { return playerDeath; } }
    public bool NotOnLive { get { return notOnLive; } }

    #endregion

    /*
    
    ***********************

    Stat Mapping
    
    0. damage
    1. speed
    2. luck
    3. max HP
    4. dodge cooldown
    5. regen HP 
    6. spell cooldown 
    7. more exp, more be damaged

    Spell Mapping

    0~7. Default Element Spells

    ***********************

    */

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if (instance != this)
        {
            Destroy(this.gameObject);
        }

        // init waitforseconds
        collectableLife = new WaitForSeconds(collectableLifeTime);
        fixedTimeDelay = new WaitForSeconds(Time.fixedDeltaTime);
        appropriateDelay = new WaitForSeconds(appDelay);
        oneSecDelay = new WaitForSeconds(oneSec);
        enemyKnockBackTime = new WaitForSeconds(knockBackTime);
        enemyInvincibleTime = new WaitForSeconds(invincibleTime);

        // init UI
        PlayUI1.enabled = true;
        PlayUI2.enabled = true;
        ChooseUI1.enabled = false;
        ChooseUI2.enabled = false;
        PauseUI.enabled = false;

        chooseUIManager.enabled = false;

        currentEtherText.text = currentEther.ToString();
        currentEtherCrystalText.text = currentEtherCrystal.ToString();

        // init arrays
        spellCasting = new bool[totalSpellCount];
        elementDeactive = new bool[totalElementCount];
        learnedSpell = new bool[totalSpellCount];
    }

    void Start()
    {
        // Timer
        StartCoroutine(TimeControl());

        // Game Start
        OpenChooseUI();
    }

    public void OnCancel(InputAction.CallbackContext context)
    {
        if (playerDeath)
        {
            return;
        }

        if (context.started)
        {
            if (onPause)
            {
                if (!onChoose)
                {
                    notOnLive = false;
                    Time.timeScale = 1;
                }
                onPause = false;

                // pause ui hide
                PauseUI.enabled = true;
            }
            else
            {
                notOnLive = true;
                onPause = true;
                Time.timeScale = 0;

                // pause ui
                PauseUI.enabled = false;
            }
        }
    }

    public void GetExp(float exp)
    {
        currentExp += exp * (1 + 0.01f * currentStats[7]);
        if(currentExp >= expForLevelUp)
        {
            currentExp -= expForLevelUp;
            expForLevelUp += expAdd;

            currentEtherCrystalText.text = (++currentEtherCrystal).ToString();

            OpenChooseUI();
        }

        ExpSlider.value = currentExp / expForLevelUp;

        // KillScore
        totalKillScoreText.text = (++totalKillScore).ToString();
    }

    public void GetEther(int ether)
    {
        currentEther += ether;
        currentEtherText.text = currentEther.ToString();
    }

    void OpenChooseUI()
    {
        // stop game time
        notOnLive = true;
        Time.timeScale = 0;

        // level up
        levelText.text = string.Format("Lv. {0}", ++level);

        // element ui
        chooseUIManager.enabled = true;

        onChoose = true;
        ChooseUI1.enabled = true;
        ChooseUI2.enabled = true;
    }

    public void CloseChooseUI()
    {
        // choose end
        chooseUIManager.enabled = false;

        onChoose = false;
        ChooseUI1.enabled = false;
        ChooseUI2.enabled = false;
        notOnLive = false;
        Time.timeScale = 1;
    }

    public void ReinforcedElement(int element)
    {
        currentEtherCrystalText.text = (--currentEtherCrystal).ToString();

        // stat level up
        currentStats[element] += addAmountPerStat[element];

        if(element == (int)Element.Ion)
        {
            magnetField.ResetColliderRadius();
        }
        else if (element == (int)Element.Earth)
        {
            playerController.Healed(10);
        }
        else if (element == (int)Element.Light)
        {
            spellPool.SpellCooldownChange();
        }
    }

    public void LearningSpell(int spell)
    {
        learnedSpell[spell] = true;
        spellCasting[spell] = true;

        // pay resource
        currentEther -= chooseUIManager.SpellCosts[spell].etherCost;
        currentEtherText.text = currentEther.ToString();

        // used element deactive


        // cast spell
        spellPool.CastSpell(spell);
    }

    public void Death()
    {
        playerDeath = true;

        PlayUI1.enabled = false;
        PlayUI2.enabled = false;

        StartCoroutine(Result());
    }

    IEnumerator Result()
    {
        yield return new WaitForSeconds(7.77f);

        // result ui
    }

    IEnumerator TimeControl()
    {
        var time = new WaitForSeconds(1);
        while (!playerDeath)
        {
            yield return time;
            curTime++;
            curTimeText.text = string.Format("{0:D2}:{1:D2}", curTime/60, curTime%60);
        }
    }
}