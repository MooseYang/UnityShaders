using UnityEngine;


public class ProjectorEffect : MonoBehaviour
{
	public Material projectorMaterial = null;
	private Camera projectorCam = null;
	private Matrix4x4 mScaleMatrix = new Matrix4x4();


	private void Awake()
	{
		//projectorCam = GetComponent<Camera>();
		projectorCam = new GameObject().AddComponent<Camera>();
		projectorCam.name = "Cam";

		projectorCam.aspect = 1;
		projectorCam.fieldOfView = 30;
		projectorCam.nearClipPlane = 0.01f;
		projectorCam.transform.position = this.transform.position;
		projectorCam.transform.rotation = this.transform.rotation;
		projectorCam.transform.parent = this.transform;

		mScaleMatrix.m00 = 0.5f;
		mScaleMatrix.m11 = 0.5f;
		mScaleMatrix.m22 = 0.5f;
		mScaleMatrix.m03 = 0.5f;
		mScaleMatrix.m13 = 0.5f;
		mScaleMatrix.m23 = 0.5f;
		mScaleMatrix.m33 = 1;
	}

	private void Update()
	{
		Matrix4x4 projectionMatrix = GL.GetGPUProjectionMatrix(projectorCam.projectionMatrix, false);
		Matrix4x4 viewMatrix = projectorCam.worldToCameraMatrix;
		Matrix4x4 vpMatrix = projectionMatrix * viewMatrix;

		projectorMaterial.SetMatrix("_ProjectorVPMatrix", vpMatrix);
	}
}
