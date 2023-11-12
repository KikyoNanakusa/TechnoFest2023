using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ThresholdSlider : MonoBehaviour
{
    public Material toonMaterial;
    public Material doubleToonMaterial;
    public GameObject thresholdSliderUI;
    public GameObject thresholdTextUI;

    private Slider _thresholdSlider;
    private TMP_Text _thresholdText;
    
    void Start()
    {
        _thresholdSlider = thresholdSliderUI.GetComponent<Slider>();
        _thresholdText = thresholdTextUI.GetComponent<TMP_Text>();
        float toonThreshold = toonMaterial.GetFloat("_ToonThreshold");
        _thresholdText.text = $"閾値:{_thresholdSlider.value.ToString("N2")}";
        _thresholdSlider.value = toonThreshold;
    }

    public void ChangeToonThresholdValue()
    {
        toonMaterial.SetFloat("_ToonThreshold", _thresholdSlider.value);
        doubleToonMaterial.SetFloat("_ToonThreshold", _thresholdSlider.value);
        _thresholdText.text = $"閾値:{_thresholdSlider.value.ToString("N2")}";
    }
    
}
