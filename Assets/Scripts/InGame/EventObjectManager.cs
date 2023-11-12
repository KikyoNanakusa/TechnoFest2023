using System;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.SceneManagement;

public class EventObjectManager : MonoBehaviour
{
    public GameObject sphere;
    public Material unlit;
    public Material lit;
    public Material toon;
    public Material doubleToon;
    public GameObject lightDir;
    public GameObject normalDir;
    public GameObject thresholdSlider;
    public GameObject doubleThresholdSlider;
    public GameObject natsuko;
    public GameObject natsukoBody;
    public Material cyberFade;
    public Material sphereFade;
    public Material distractFade;
    public GameObject transition;
    
    private bool _eventFlag = false;
    private MeshRenderer _sphereMeshRenderer;
    private Material _sphereLitMaterial;
    private Animator _natsukoAnimator;
    
    public bool EventFlag
    {
        get { return _eventFlag; }
        set { _eventFlag = value; }
    }
    
    async void Start()
    {
        _natsukoAnimator = natsuko.GetComponent<Animator>();
        sphere.SetActive(false);
        lightDir.SetActive(false);
        normalDir.SetActive(false);
        thresholdSlider.SetActive(false);
        doubleThresholdSlider.SetActive(false);
        // natsuko.SetActive(false);
        natsukoBody.GetComponent<SkinnedMeshRenderer>().material = cyberFade;
        lit.SetFloat("_TOONDOUBLESHADE", 0);
        toon.SetFloat("_TOONDOUBLESHADE", 0);
        lit.SetFloat("_TOON", 0);
        _sphereMeshRenderer = sphere.GetComponent<MeshRenderer>();
        _sphereMeshRenderer.material = unlit;

        await ProgressEvents();
    }

    private async UniTask ProgressEvents()
    {
        Debug.Log("progressEvent");
        var token = this.GetCancellationTokenOnDestroy();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateSphere();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        SetSphereMaterialLit();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateLightDir();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateNormalDir();

        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        DeactivateArrows();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        SetSphereMaterialToon();

        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateToonThreshold();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateToonDoubleThreshold();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        await CyberFadeIn();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        SphereFadeIn();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        DistractFadeOut();

        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ExitGame();        
    }

    private void ActivateSphere()
    {
        sphere.SetActive(true);
        _eventFlag = false;
    }

    private void SetSphereMaterialLit()
    {
        _sphereMeshRenderer.material = lit;
        _eventFlag = false;
    }

    private void ActivateLightDir()
    {
        lightDir.SetActive(true);
        _eventFlag = false;
    }

    private void ActivateNormalDir()
    {
        normalDir.SetActive(true);
        _eventFlag = false;
    }

    private void DeactivateArrows()
    {
        lightDir.SetActive(false);
        normalDir.SetActive(false);
        _eventFlag = false;
    }

    private void SetSphereMaterialToon()
    {
        _sphereMeshRenderer.material = toon;
        _eventFlag = false;
    }

    private void ActivateToonThreshold()
    {
        thresholdSlider.SetActive(true);
        _eventFlag = false;
    }

    private void ActivateToonDoubleThreshold()
    {
        _sphereMeshRenderer.material = doubleToon;
        toon.SetFloat("_TOONDOUBLESHADE", 1);
        doubleThresholdSlider.SetActive(true);
        _eventFlag = false;
    }

    private async UniTask CyberFadeIn()
    {
        natsuko.SetActive(true);
        _natsukoAnimator.SetTrigger("CyberFadeIn");
        await UniTask.Delay(TimeSpan.FromSeconds(2));
        _natsukoAnimator.SetTrigger("CyberFadeOut");

        _eventFlag = false;
    }

    private void SphereFadeIn()
    {
        natsukoBody.GetComponent<SkinnedMeshRenderer>().material = sphereFade;
        _natsukoAnimator.SetTrigger("SphereFadeIn");
        _eventFlag = false;
    }

    private void DistractFadeOut()
    {
        natsukoBody.GetComponent<SkinnedMeshRenderer>().material = distractFade;
        _natsukoAnimator.SetTrigger("DistractFadeOut");
        _eventFlag = false;
    }

    private async UniTask ExitGame()
    {
        transition.GetComponent<Transition>().FadeOut();
        await UniTask.Delay(TimeSpan.FromSeconds(3f));
        _eventFlag = false;
        SceneManager.LoadScene("Start");
    }
}
