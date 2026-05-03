using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Nepenthes : MonoBehaviour
{
    [SerializeField] GameObject Projectile;

    PlantControl plantStatus;
    AudioSource audioSource;
    
    float shootingCooldown = 1.0f;
    bool isReadyToShoot = true;
    float force = 15f;

    void Start()
    {
        plantStatus = GetComponent<PlantControl>();
        audioSource = GetComponent<AudioSource>();
    }

    public void ShootingLeaf(Vector2 targetPos)
    {
        if (plantStatus.growLevel == 3 && isReadyToShoot)
        {
            audioSource.Play();
            isReadyToShoot = false;
            GameObject projectile = GameManager.MakeProjectile(transform.position);

            if (projectile == null) return; 

            Vector2 dir = new Vector2(targetPos.x - transform.position.x, targetPos.y - transform.position.y).normalized;
            projectile.GetComponent<Rigidbody2D>().AddForce(dir * force, ForceMode2D.Impulse);

            StartCoroutine(AfterShooting());
        }
    }

    IEnumerator AfterShooting()
    {
        var time = new WaitForSeconds(shootingCooldown);
        yield return time;
        isReadyToShoot = true;
    }
}
