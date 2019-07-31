using UnityEngine;


public class MyBloom : MyPostEffectBase
{
    public int downSample = 1;

    public Color colorThreshold = Color.gray;
    public Color bloomColor = Color.white;
    
    [Range(0.0f, 1.0f)]
    public float bloomFactor = 0.3f;

    [Range(0.0f, 1.0f)]
    public float luminanceThreshold = 0.3f;

    private Camera currentCam;


    private void OnEnable() 
    {
        currentCam = GetComponent<Camera>();
        if(currentCam != null)
        {
            currentCam.depthTextureMode |= DepthTextureMode.Depth;
        }
    }

    protected override void Start() 
    {
        mShader = Shader.Find("Moose_Yang/MyBloom");

        base.Start();
    }

    protected override void OnDestroy()
    {
        currentCam.depthTextureMode &= ~DepthTextureMode.Depth;
        base.OnDestroy();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        if(MyMaterial != null)
        {
            RenderTexture rt1 = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format);

            //缩小
            Graphics.Blit(src, rt1);

            //阈值分割处理
            //MyMaterial.SetVector("_ColorThreshold", colorThreshold);
            MyMaterial.SetFloat("_LuminanceThreshold", luminanceThreshold);
            Graphics.Blit(rt1, rt2, MyMaterial, 0);

            //高斯模糊处理
            MyMaterial.SetVector("_Offsets", new Vector4(1, 0, 0, 0));
            Graphics.Blit(rt2, rt1, MyMaterial, 1);

            MyMaterial.SetVector("_Offsets", new Vector4(0, 1, 0, 0));
            Graphics.Blit(rt1, rt2, MyMaterial, 1);

            //Bloom混合
            MyMaterial.SetTexture("_BlurTex", rt2);
            MyMaterial.SetVector("_BloomColor", bloomColor);
            MyMaterial.SetFloat("_BloomFactor", bloomFactor);
            Graphics.Blit(src, dest, MyMaterial, 2);

            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }    
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
