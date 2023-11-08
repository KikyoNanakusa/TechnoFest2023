using System;
using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class TextBox : MonoBehaviour
{
    private bool _isClicked;
    private bool _isClickable = false;
    private IEnumerator<string> _script;
    private TMP_Text _thisText;
    
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
        _thisText = this.GetComponent<TMP_Text>();
        IEnumerable<string> enumerableScript =
            (Resources.Load("Script", typeof(TextAsset)) as TextAsset).text.Split("\n");
        _script = enumerableScript.GetEnumerator();
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
            if (!_script.MoveNext()) break;
            _thisText.text = _script.Current;
            _isClicked = false;
            Debug.Log(_script.Current);
        }
    }
}
