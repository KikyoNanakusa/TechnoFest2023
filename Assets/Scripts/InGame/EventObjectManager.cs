using Cysharp.Threading.Tasks;
using UnityEngine;

public class EventObjectManager : MonoBehaviour
{
    public GameObject sphere;
    public Material unlit;
    public Material lit;
    public GameObject lightDir;
    public GameObject normalDir;

    private bool _eventFlag = false;
    private MeshRenderer _sphereMeshRenderer;
    private Material _sphereLitMaterial;
    
    public bool EventFlag
    {
        get { return _eventFlag; }
        set { _eventFlag = value; }
    }
    
    async void Start()
    {
        sphere.SetActive(false);
        lightDir.SetActive(false);
        normalDir.SetActive(false);
        _sphereMeshRenderer = sphere.GetComponent<MeshRenderer>();
        _sphereMeshRenderer.material = unlit;

        await ProgressEvents();
    }

    private async UniTask ProgressEvents()
    {
        Debug.Log("progressEvent");
        var token = this.GetCancellationTokenOnDestroy();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        Debug.Log("ActivateSpere");
        ActivateSphere();

        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        SetSphereMaterialLit();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateLightDir();
        
        await UniTask.WaitUntil(() => _eventFlag, cancellationToken: token);
        ActivateNormalDir();
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
}
