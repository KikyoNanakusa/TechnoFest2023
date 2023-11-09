using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class DoubleThresholdSlider : MonoBehaviour
{
    public Material toonMaterial;
    public GameObject doubleThresholdSliderUI;
    public GameObject doubleThresholdTextUI;

    private Slider _doubleThresholdSlider;
    private TMP_Text _doubleThresholdText;
    
    void Start()
    {
        _doubleThresholdSlider = doubleThresholdSliderUI.GetComponent<Slider>();
        _doubleThresholdText = doubleThresholdTextUI.GetComponent<TMP_Text>();
        float toonThreshold = toonMaterial.GetFloat("_ToonDoubleThreshold");
        _doubleThresholdText.text = $"閾値2:{_doubleThresholdSlider.value.ToString("N2")}";
        _doubleThresholdSlider.value = toonThreshold;
        _doubleThresholdSlider.maxValue = toonMaterial.GetFloat("_ToonThreshold");
    }

    public void ChangeToonDoubleThresholdValue()
    {
        toonMaterial.SetFloat("_ToonDoubleThreshold", _doubleThresholdSlider.value);
        _doubleThresholdSlider.maxValue = toonMaterial.GetFloat("_ToonThreshold");
        _doubleThresholdText.text = $"閾値2:{_doubleThresholdSlider.value.ToString("N2")}";
    }
    
}
