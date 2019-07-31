using UnityEngine;


public class MyDOF : MyPostEffectBase
{
    public float blurRadio;
    public int downSample = 1;
    public int iteration = 1;
    public float foucsVal = 0.3f;

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
        mShader = Shader.Find("Moose_Yang/MyDOF");

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

            for(int i = 0; i < iteration; i++)
            {
                MyMaterial.SetFloat("_BlurRadio", blurRadio);

                Graphics.Blit(rt1, rt2, MyMaterial, 0);
                Graphics.Blit(rt2, rt1, MyMaterial, 0);
            }

            MyMaterial.SetTexture("_BlurTex", rt1);
            MyMaterial.SetFloat("_foucsVal", foucsVal);
            Graphics.Blit(src, dest, MyMaterial, 1);

            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }    
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
