using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class Start2Game : MonoBehaviour
{
    public GameObject transition;

    private const float TransitionSpeed = 2.0f;
    public string NextSceneName = "Game";
    
    private bool _isFadeIn;
    private float _transitionAlpha;
    private Image _transitionImage;

    // Start is called before the first frame update
    void Start()
    {
        _transitionImage = transition.GetComponent<Image>();
        _isFadeIn = false;
        _transitionAlpha = 0.0f;
    }

    // Update is called once per frame
    void Update()
    {
        if (_isFadeIn && _transitionImage.color.a <= 1.0f)
        {
            _transitionImage.color = new Color(0.0f, 0.0f, 0.0f, _transitionAlpha);
            _transitionAlpha += Time.deltaTime / TransitionSpeed;
        }
    }

    public void OnStartButtonClick()
    {
        _isFadeIn = true;
        StartCoroutine ("LoadScene");
    }
    
    private IEnumerator LoadScene() {
        var async = SceneManager.LoadSceneAsync(NextSceneName);

        async.allowSceneActivation = false;
        yield return new WaitForSeconds(TransitionSpeed);
        async.allowSceneActivation = true;
    }
}
