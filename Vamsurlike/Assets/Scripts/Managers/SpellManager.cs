using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class SpellManager : MonoBehaviour
{
    #region Variables

    /* 
    
    SpellManager has...
    
    1. spell prefabs
    2. spell pool list
    3. make spell with type, with cooldown
      
    */

    [SerializeField] GameObject[] spells;
    [SerializeField] float[] defSpellCooldowns;

    List<GameObject>[] spellObjectPool;

    WaitForSeconds[] spellCooldowns;

    #endregion

    void Awake()
    {
        // object pool init
        spellObjectPool = new List<GameObject>[spells.Length];
        spellCooldowns = new WaitForSeconds[spells.Length];
        for (int i = 0; i < spells.Length; ++i)
        {
            spellObjectPool[i] = new List<GameObject>();
            spellCooldowns[i] = new WaitForSeconds(defSpellCooldowns[i]);
        }
    }

    public void CastSpell(int type)
    {
        StartCoroutine(CastSpellCoroutine(type));
    }

    IEnumerator CastSpellCoroutine(int type)
    {
        yield return spellCooldowns[type];

        while (GameManager.Instance.SpellCasting[type] && !GameManager.Instance.PlayerDeath)
        {
            SetSpellObjectActive(type);
            yield return spellCooldowns[type];
        }
    }

    void SetSpellObjectActive(int type)
    {
        GameObject freeObj = null;

        foreach (GameObject obj in spellObjectPool[type])
        {
            if (!obj.activeSelf)
            {
                freeObj = obj;
                freeObj.SetActive(true);
                break;
            }
        }

        if (!freeObj)
        {
            freeObj = Instantiate(spells[type], transform);
            spellObjectPool[type].Add(freeObj);
        }
    }

    public void SpellCooldownChange()
    {
        for (int i = 0; i < spells.Length; ++i)
        {
            spellCooldowns[i] = new WaitForSeconds(defSpellCooldowns[i] * (1 - (GameManager.Instance.CurrentStats[(int)GameManager.Element.Light] * 0.01f)));
        }
    }
}
