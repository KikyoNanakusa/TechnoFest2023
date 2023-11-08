using Cysharp.Threading.Tasks;
using UnityEngine;

public class Cursor : MonoBehaviour
{
    public GameObject overlayCanvas;
    public GameObject clickEffect;

    private Canvas _overlayCanvas;
    private RectTransform _overlayCanvasRect;
    private Vector2 _screenPoint;
    private bool _isClicked = false;
    private bool _isClickable = false;

    public bool IsClicked
    {
        get { return _isClicked;}
        set
        {
            if (value != _isClicked && _isClickable)
            {
                _isClicked = value;
            }
        }
    }
    
    async void Start()
    {
        _overlayCanvas = overlayCanvas.GetComponent<Canvas>();
        _overlayCanvasRect = overlayCanvas.GetComponent<RectTransform>();

        await UniTask.WaitForSeconds(2.0f);
        _isClickable = true;
        await WaitForClick();
    }

    private async UniTask WaitForClick()
    {
        var token = this.GetCancellationTokenOnDestroy();
        while (_isClickable)
        {
            await UniTask.WaitUntil(() => Input.GetMouseButtonDown(0), cancellationToken:token);
            RectTransformUtility.ScreenPointToLocalPointInRectangle(_overlayCanvasRect, Input.mousePosition, _overlayCanvas.worldCamera, out _screenPoint);
            var effectPrefab = Instantiate(clickEffect, _overlayCanvasRect);
            effectPrefab.GetComponent<RectTransform>().anchoredPosition = _screenPoint;
        }
    }
}
