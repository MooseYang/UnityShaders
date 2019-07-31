using UnityEngine;


/// <summary>
/// 该脚本挂载到平面上
/// </summary>
public class MyMirrorReflection : MonoBehaviour
{
    private Camera mReflectionCam;
    private RenderTexture mRenderTex;
    public float m_ClipPlaneOffset = 0.07f;


    private void Start()
    {
        mRenderTex = new RenderTexture(1024, 1024, 16);
        mRenderTex.hideFlags = HideFlags.DontSave;

        GameObject go = new GameObject("ReflectionCam");
        go.hideFlags = HideFlags.HideAndDontSave;

        mReflectionCam = go.AddComponent<Camera>();
        mReflectionCam.enabled = false;
        //mReflectionCam.transform.position = transform.position;
        //mReflectionCam.transform.rotation = transform.rotation;
        mReflectionCam.gameObject.AddComponent<FlareLayer>();

        Renderer r = GetComponent<Renderer>();
        r.material.SetTexture("_MirrorTex", mRenderTex);
    }

    private void OnDisable() 
    {
        if(mRenderTex != null)
        {
            DestroyImmediate(mRenderTex);
            mRenderTex = null;
        }
    }

    private void OnWillRenderObject()       
    {
        //Camera.main是运行时的主摄像机
        //Camera.current在编辑器下，可以运行 (Scene视口可以生效)
        Camera src = Camera.current;
        if (src == null) return;

        mReflectionCam.clearFlags = src.clearFlags;
        mReflectionCam.backgroundColor = src.backgroundColor;
        mReflectionCam.farClipPlane = src.farClipPlane;
        mReflectionCam.nearClipPlane = src.nearClipPlane;
        mReflectionCam.orthographic = src.orthographic;
        mReflectionCam.fieldOfView = src.fieldOfView;
        mReflectionCam.aspect = src.aspect;
        mReflectionCam.orthographicSize = src.orthographicSize;
        //排除指定层，不然会出现递归的错误  (然后将地面预制件的Layer设置为"Water")
        mReflectionCam.cullingMask = ~(1<<LayerMask.NameToLayer("Water"));

        Vector3 normal = this.transform.up;
        Vector3 pos = this.transform.position;

        float d = -Vector3.Dot(normal, pos) - m_ClipPlaneOffset;
        Vector4 plane = new Vector4(normal.x, normal.y, normal.z, d);

        Matrix4x4 reflectionMatrix = Matrix4x4.zero;
        CalculateReflectionMatrix(ref reflectionMatrix, plane);
        mReflectionCam.worldToCameraMatrix = src.worldToCameraMatrix * reflectionMatrix;
        mReflectionCam.targetTexture = mRenderTex;

        Vector4 clipPlane = CameraSpacePlane(mReflectionCam, pos, normal, 1.0f);
        //Matrix4x4 projection = src.CalculateObliqueMatrix(clipPlane);
        Matrix4x4 projection = CalculateObliqueMatrix(clipPlane, src.projectionMatrix);
        mReflectionCam.projectionMatrix = projection;

        //解决镜像的法线没有翻转的问题
        GL.invertCulling = true;

        mReflectionCam.Render();

        GL.invertCulling = false;
    }

    private Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign)
    {
        Vector3 offsetPos = pos + normal * m_ClipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos); //矩阵乘以点
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;  //矩阵乘以向量
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));
    }

    private Matrix4x4 CalculateObliqueMatrix(Vector4 clipPlane, Matrix4x4 projection)
    {
        Vector4 Q = projection.inverse * new Vector4(sgn(clipPlane.x), sgn(clipPlane.y), 1, 1);

        float cq = Vector4.Dot(Q, clipPlane);

        Vector4 C = clipPlane * 2.0f / cq;

        projection.m20 = C.x;
        projection.m21 = C.y;
        projection.m22 = C.z + 1;
        projection.m23 = C.w;

        return projection;
    }

    private float sgn(float a)
    {
        if (a > 0.0f) return 1.0f;
        if (a < 0.0f) return -1.0f;
        return 0.0f;
    }

    private void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
    }
}
