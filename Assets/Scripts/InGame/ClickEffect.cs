using System;
using UnityEngine;
using UnityEngine.UI;

public class ClickEffect : MonoBehaviour
{
    private float _radius = -0.1f;

    private Material _thisMaterial;
    
    void Start()
    {
        _thisMaterial = this.GetComponent<Image>().material;
        _thisMaterial.SetFloat("_Radius", _radius);
    }

    private void Update()
    {
        if (_radius <= 1.0f)
        {
            _thisMaterial.SetFloat("_Radius", _radius);
            _radius += 0.02f;
        }
        else
        {
            DestroySelf();
        }
    }

    private void DestroySelf()
    {
        Destroy(this.gameObject);
    }
    //
    // private void OnDestroy()
    // {
    //     Destroy(_thisMaterial);
    // }
}
