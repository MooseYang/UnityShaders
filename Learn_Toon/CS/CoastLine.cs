using UnityEngine;
using System.Collections.Generic;
using System.Linq;


[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class CoastLine : MonoBehaviour 
{
    public Transform PointsParent;
    public float Thickness = 2;
    public float OutsideOffsetY = 0;
    List<Vector3> insideVertices;
    List<Vector3> outsideVertices;
    MeshFilter filter;
    MeshRenderer render;


	private void Start () 
    {
        if (PointsParent == null)
        {
            enabled = false;
            return;
        }

        filter = GetComponent<MeshFilter>();
        render = GetComponent<MeshRenderer>();
        if (filter.sharedMesh == null)
        {
            filter.sharedMesh = CreateMesh();
        }
	}

	/// <summary>
	/// 创建内部和外部的多边形的顶点
	/// </summary>
    private void CreateVertices() 
    {
        List<Vector3> points = new List<Vector3>();
        foreach (Transform child in PointsParent.transform.Cast<Transform>().OrderBy(item => item.name))
        {
            points.Add(child.localPosition);
        }

        insideVertices = new List<Vector3>();
        outsideVertices = new List<Vector3>();
        Vector3 pCur, pPre, pNext, dLeft, dRight, cross, pPlus;

        for (int i = 0, len = points.Count; i < len; i++)
        {
            pCur = points[i];
            pPre = points[i - 1 < 0 ? len - 1 : i - 1];
            pNext = points[(i + 1) % len];
            dLeft = new Vector3(pPre.x, pCur.y, pPre.z) - pCur;
            dRight = new Vector3(pNext.x, pCur.y, pNext.z) - pCur;
            cross = Vector3.Cross(dLeft.normalized, dRight.normalized);
            pPlus = dLeft.normalized + dRight.normalized;
            insideVertices.Add(pCur);

            if (cross.y >= 0)
            {
                //dRight向量位于dLeft向量的顺时针方向或两个向量平行
                outsideVertices.Add(pCur + pPlus.normalized * Thickness + new Vector3(0, OutsideOffsetY, 0));
            }
            else
            {
                outsideVertices.Add(pCur + pPlus.normalized * -1 * Thickness + new Vector3(0, OutsideOffsetY, 0));
            }
        }
    }
	
    public Mesh CreateMesh() 
    {
        CreateVertices();

        Mesh mesh = new Mesh();

        List<Vector3> vertices = new List<Vector3>();
        List<Vector2> uv = new List<Vector2>();
        for (int i = 0, len = insideVertices.Count; i < len; i++)
        {
			//构成一个梯形
            vertices.Add(insideVertices[i]);
            uv.Add(new Vector2(1, 1));
            vertices.Add(insideVertices[(i + 1) % len]);
            uv.Add(new Vector2(0, 1));
            vertices.Add(outsideVertices[i]);
            uv.Add(new Vector2(1, 0));
            vertices.Add(outsideVertices[(i + 1) % len]);
            uv.Add(new Vector2(0, 0));
        }

        List<int> triangles = new List<int>();
        for (int i = 0, len = vertices.Count; i < len; i+=4)
        {
			// v0,v3, v1
            triangles.Add(i);
            triangles.Add(i + 3);
            triangles.Add(i + 1);

			// v2, v3, v0
            triangles.Add(i + 2);
            triangles.Add(i + 3);
            triangles.Add(i);
        }

        mesh.vertices = vertices.ToArray();
        mesh.uv = uv.ToArray();
        mesh.triangles = triangles.ToArray();

        return mesh;
    }

    void OnDrawGizmos()
    {
	    if (PointsParent == null) return;
        
        CreateVertices();

        Gizmos.color = Color.yellow;
        for (int i = 0, len = insideVertices.Count; i < len; i++)
        {
            Gizmos.DrawLine(transform.position + insideVertices[i], transform.position + insideVertices[(i + 1) % len]);
        }
        Gizmos.color = Color.blue;
        for (int i = 0, len = outsideVertices.Count; i < len; i++)
        {
            Gizmos.DrawLine(transform.position + outsideVertices[i], transform.position + outsideVertices[(i + 1) % len]);
        }
        Gizmos.color = Color.green;
        for (int i = 0, len = insideVertices.Count; i < len; i++)
        {
            Gizmos.DrawLine(transform.position + insideVertices[i], transform.position + outsideVertices[i]);
        }
    }
}
