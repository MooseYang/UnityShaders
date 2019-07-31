using UnityEngine;


public class MyAverageBlur : MyPostEffectBase
{
    public float blurRadio;
    public int downSample = 1;
    public int iteration = 1;


    protected override void Start() 
    {
        mShader = Shader.Find("Moose_Yang/MyAverageBlur");
        base.Start();
    }

    private  void OnRenderImage(RenderTexture src, RenderTexture dest) 
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

                Graphics.Blit(rt1, rt2, MyMaterial);
                Graphics.Blit(rt2, rt1, MyMaterial);
            }

            //还原
            Graphics.Blit(rt1, dest);

            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
