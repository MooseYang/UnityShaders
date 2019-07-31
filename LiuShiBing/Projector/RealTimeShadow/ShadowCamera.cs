using UnityEngine;


/// <summary>
/// 挂载到跟随玩家移动的GameObject
/// </summary>
public class ShadowCamera : MonoBehaviour
{
    private Camera cam;
    private RenderTexture mRenderTexture;


    private void Start() 
    {
        GameObject go = new GameObject("Camera");
        cam = go.AddComponent<Camera>();

        //也可以不使用RenderToTexture.shader记录深度值 (可以不使用cam.SetReplacementShader这个方式)
        //直接判断_DepthTexture采样后的alpha值
        //alpha值不为零的像素，一定处在阴影中
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = new Color(1, 1, 1, 0);
        cam.orthographic = true;   //也可以改为透视投影的方式
        cam.orthographicSize = 10;
        cam.aspect = 1;

        cam.transform.SetParent(this.transform);
        cam.transform.position = this.transform.position;
        cam.transform.rotation = this.transform.rotation;    

        mRenderTexture = new RenderTexture(1024, 1024, 0);
        mRenderTexture.wrapMode = TextureWrapMode.Clamp;

        cam.targetTexture = mRenderTexture;
        //只渲染带有"ShadowCaster"层的物体
        cam.cullingMask = LayerMask.GetMask("ShadowCaster");
        cam.SetReplacementShader(Shader.Find("Moose_Yang/Projector/RenderToTexture"), "RenderType");

        cam.Render();

        Matrix4x4 tm = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false) * cam.worldToCameraMatrix;

        Matrix4x4 sm = new Matrix4x4();
        sm.m00 = 0.5f;
        sm.m11 = 0.5f;
        sm.m22 = 0.5f;
        sm.m03 = 0.5f;
        sm.m13 = 0.5f;
        sm.m23 = 0.5f;
        sm.m33 = 1;

        tm = sm * tm;

        Shader.SetGlobalMatrix("Custom_ProjectorMatrix", tm);
        Shader.SetGlobalTexture("_DepthTexture", mRenderTexture);
    }
}
