using UnityEngine;


public class CustomProjector : MonoBehaviour
{
    private Projector projector;
    private Camera cam;
    private Matrix4x4 sm;


    private void Start() 
    {
        projector = GetComponent<Projector>();

        GameObject go = new GameObject("Cam");
        cam = go.AddComponent<Camera>();   
        cam.enabled = false; 

        cam.transform.parent = this.transform;
        cam.transform.localPosition = Vector3.zero;
        cam.transform.localRotation = Quaternion.identity;

        cam.aspect = projector.aspectRatio;
        cam.nearClipPlane = projector.nearClipPlane;
        cam.farClipPlane = projector.farClipPlane;
        cam.orthographic = projector.orthographic;
        cam.orthographicSize = projector.orthographicSize;
        //cam.clearFlags = CameraClearFlags.Depth;

        sm = new Matrix4x4();
        sm.m00 = 0.5f;
        sm.m11 = 0.5f;
        sm.m22 = 0.5f;
        sm.m03 = 0.5f;
        sm.m13 = 0.5f;
        sm.m23 = 0.5f;
        sm.m33 = 1;
    }

    private void Update() 
    {
        //cam.transform.localToWorldMatrix表示的是场景里主摄像机看到的投影机的变换矩阵，不能用来变换投影机所在的坐标空间
        //即：是投影机自身的模型到世界的变换矩阵，并不是投影机看到的物体的模型到世界
        //所以，缺少了顶点到世界的变换矩阵 (在Shader里面实现)
        Matrix4x4 tm = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false) * cam.worldToCameraMatrix;

        projector.material.SetMatrix("custom_Projector", sm * tm);
    }
}
