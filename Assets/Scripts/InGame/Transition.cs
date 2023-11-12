using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Transition : MonoBehaviour
{
    private Animator _transitionAnimator;
    
    void Start()
    {
        _transitionAnimator = this.GetComponent<Animator>();
        FadeOut();
    }

    public void FadeOut()
    {
        _transitionAnimator.SetTrigger("FadeOut");
    }

    private void FadeIn()
    {
        _transitionAnimator.SetTrigger("FadeIn");
    }
}
