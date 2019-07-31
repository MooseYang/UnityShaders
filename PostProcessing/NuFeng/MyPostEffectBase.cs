using UnityEngine;


public class MyPostEffectBase : MonoBehaviour
{
    private Material mMat;
    protected Shader mShader;


    public Material MyMaterial
    {
        get
        {
            if(mMat == null)
            {
                mMat = new Material(mShader);
                mMat.hideFlags = HideFlags.HideAndDontSave;
            }

            return mMat;
        }
    }

    protected virtual void Start() 
    {
        if(!SystemInfo.supportsImageEffects)
        {
            this.enabled = false;
            return;
        }    

        if(!mShader || !mShader.isSupported)
        {
            this.enabled = false;
            return;
        }
    }

    protected virtual void OnDestroy()
    {
        if(mMat != null)
        {
            DestroyImmediate(mMat);
        }
    }
}
