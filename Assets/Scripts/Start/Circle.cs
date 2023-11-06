using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Circle : MonoBehaviour
{
    private RectTransform _thisTransform;
    private Canvas _canvas;
    private RectTransform _canvasRect;
    private Vector2 _localPoint;
    private Material _thisMaterial;
    
    private bool _isTransition;
    private float _transitionProcess = -0.1f;
    
    void Start()
    {
        _canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        _canvasRect = _canvas.GetComponent<RectTransform>();
        _thisTransform = this.GetComponent<RectTransform>();
        _thisMaterial = this.GetComponent<Image>().material;
    }

    void Update()
    {
        if (_isTransition && _transitionProcess < 1.0)
        {
            _transitionProcess += Time.deltaTime;
            _thisMaterial.SetFloat("_Radius", _transitionProcess);
        }
        else
        {
            _isTransition = false;
            _transitionProcess = -0.1f;
            _thisMaterial.SetFloat("_Radius", _transitionProcess);
        }
    }
    
    public void OnStartButtonClick()
    {
        RectTransformUtility.ScreenPointToLocalPointInRectangle(_canvasRect, Input.mousePosition, _canvas.worldCamera, out _localPoint);
        _thisTransform.anchoredPosition = _localPoint;
        _isTransition = true;
    }
}
