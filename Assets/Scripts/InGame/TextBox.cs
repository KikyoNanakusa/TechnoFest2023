using System;
using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TextBox : MonoBehaviour
{
    public GameObject renderChan;
    [SerializeField]
    public Sprite[] renderChanSprites;
    public GameObject eventManager;
    
    private bool _isClicked;
    private bool _isClickable = false;
    private IEnumerator<string> _script;
    private TMP_Text _thisText;
    private Image _renderChanImage;
    private EventObjectManager _eventObjectManager;
    
    public bool IsClicked
    {
        get{ return _isClicked; } 
        set
        {
            if (_isClickable)
            {
                _isClicked = value;
            }
        }
    }
    
    async void Start()
    {
        _eventObjectManager = eventManager.GetComponent<EventObjectManager>();
        _renderChanImage = renderChan.GetComponent<Image>();
        _thisText = this.GetComponent<TMP_Text>();
        IEnumerable<string> enumerableScript =
            (Resources.Load("Script", typeof(TextAsset)) as TextAsset).text.Split("\n");
        _script = enumerableScript.GetEnumerator();
        _renderChanImage.sprite = renderChanSprites[0];
        
        await UniTask.Delay(TimeSpan.FromSeconds(2));
        _isClickable = true;
        await UpdateTextOnClick();
    }

    private async UniTask UpdateTextOnClick()
    {
        var token = this.GetCancellationTokenOnDestroy();
        while (true)
        {
            await UniTask.WaitUntil(() => _isClicked, cancellationToken: token);
            if (_script.MoveNext() == false) {Debug.Log("Scripts End!"); break;}

            string[] script = _script.Current.Split(" ,");
            _thisText.text = script[0];
            _renderChanImage.sprite = renderChanSprites[int.Parse(script[1])];
            if (script.Length >= 3)
            {
                if (int.Parse(script[2]) == 1)
                {
                    Debug.Log("Event");
                    _eventObjectManager.EventFlag = true;
                }
            }
            _isClicked = false;
            Debug.Log(_script.Current);
        }   
    }
}
