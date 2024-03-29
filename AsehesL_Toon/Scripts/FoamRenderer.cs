﻿using UnityEngine;


public class FoamRenderer : MonoBehaviour
{
	public Renderer[] foamInteracters;
    public float flowspeed;
    public float offsetspeed;

    private bool m_IsInitialized;
    private Bounds m_Bounds;
    private FoamRenderCamera m_Camera;
	private MeshRenderer m_MeshRenderer;
    private MeshFilter m_MeshFilter;


	void Start ()
	{
	    m_IsInitialized = Init();
	}

	private bool Init()
	{
		m_MeshFilter = GetComponent<MeshFilter>();
		if (!m_MeshFilter || !m_MeshFilter.sharedMesh)
			return false;

		m_MeshRenderer = GetComponent<MeshRenderer>();
		if (!m_MeshRenderer)
			return false;

		m_Bounds = m_MeshRenderer.bounds;
		Vector3 size = Vector3.Max(m_Bounds.size, Vector3.one);
		m_Bounds.size = size;

		m_Camera = CreateCamera();

		return true;
	}

	private FoamRenderCamera CreateCamera()
	{
		GameObject camGo = new GameObject("[Foam Render Camera]");
		camGo.transform.SetParent(transform);
		camGo.transform.position = m_Bounds.center;
		camGo.transform.rotation = Quaternion.Euler(90, 0, 0);

		Camera cam = camGo.AddComponent<Camera>();
		cam.orthographic = true;
		cam.aspect = m_Bounds.size.x / m_Bounds.size.z;
		cam.orthographicSize = m_Bounds.size.z * 0.5f;
		cam.nearClipPlane = -m_Bounds.size.y * 0.5f;
		cam.farClipPlane = m_Bounds.size.y * 0.5f;
		cam.cullingMask = 0;
		cam.allowHDR = false;
		cam.backgroundColor = Color.black;
		cam.clearFlags = CameraClearFlags.SolidColor;
		cam.depthTextureMode |= DepthTextureMode.Depth;

		return camGo.AddComponent<FoamRenderCamera>();
	}

	void OnRenderObject() 
    {
		if (!m_IsInitialized)
			return;

		m_Camera.RenderDepth(m_MeshRenderer);

	    for (int i = 0; i < foamInteracters.Length; i++)
	    {
            if(foamInteracters[i] && m_Bounds.Intersects(foamInteracters[i].bounds))
                m_Camera.RenderInteract(foamInteracters[i]);
	    }

        m_Camera.RenderFoam(m_MeshRenderer, flowspeed, offsetspeed);

        m_MeshRenderer.sharedMaterial.SetTexture("_InteractFoam", m_Camera.foamTexture);
	}

	//private void OnRenderObject()
	//{
	//	if (!m_IsInitialized)
	//		return;
	//	m_Camera.RenderDepth(m_MeshRenderer);
	//}

    void OnDrawGizmosSelected()
    {
        if (m_IsInitialized)
        {
            Gizmos.color = Color.cyan;
            Gizmos.DrawWireCube(m_Bounds.center, m_Bounds.size);
        }
    }
}
