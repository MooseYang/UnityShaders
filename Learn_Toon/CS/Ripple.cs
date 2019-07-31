using UnityEngine;
using System.Collections.Generic;
using System.Linq;


[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Ripple : MonoBehaviour 
{
    public float Thickness = 1;
    public float OffsetAngle = 5;
    public float Speed = 1;
    public Color Color = Color.white;

    private List<TriangleGroup> groups = new List<TriangleGroup>();
    private MeshFilter filter;
    private MeshRenderer render;


	void Start () 
    {
		//存储动态生成的Mesh信息
        filter = GetComponent<MeshFilter>();
		if (filter.sharedMesh == null)
		{
			filter.sharedMesh = CreateMesh();
		}

		//向shader传递参数
		render = GetComponent<MeshRenderer>();
	    if (render != null)
	    {
			render.material.SetFloat("_Speed", Speed);
			render.material.SetColor("_Color", Color);
		}
	}

    public Mesh CreateMesh() 
    {
        foreach (Transform child in transform.Cast<Transform>().OrderBy(item => item.name))
        {
	        TriangleGroup g = new TriangleGroup();
			//P1点
            g.Point = child.localPosition;
			//方位角a [-PI, PI]
	        float a = Mathf.Atan2(g.Point.x, g.Point.z) / Mathf.PI * 180;
			//弧度 [-180, 180]
	        float radian = Mathf.PI / 180 * (a - OffsetAngle);
			//左边的顶点
            g.LeftSidePoint = new Vector3(g.Point.x + Thickness * Mathf.Sin(radian), g.Point.y, g.Point.z + Thickness * Mathf.Cos(radian));
            radian = Mathf.PI / 180 * (a + OffsetAngle);
	        //右边的顶点
			g.RightSidePoint = new Vector3(g.Point.x + Thickness * Mathf.Sin(radian), g.Point.y, g.Point.z + Thickness * Mathf.Cos(radian));

            groups.Add(g);
        }

        Mesh mesh = new Mesh();
        List<Vector3> vertices = new List<Vector3>();
        List<Vector2> uv = new List<Vector2>();
        List<int> triangles = new List<int>();

        TriangleGroup curGroup;
        TriangleGroup nextGroup;
        for (int i = 0, len = groups.Count; i < len; i++)
        {
			// (v0,v1, v2)
			// (v2, v3, v4)
			// (v4, v5, v6)
            curGroup = groups[i];
            nextGroup = groups[(i + 1) % len];
            //v0
            vertices.Add(curGroup.Point);
            uv.Add(new Vector2(1, 1));
            //v1
            vertices.Add(nextGroup.Point);
            uv.Add(new Vector2(0, 1));
            //v2
            vertices.Add(curGroup.RightSidePoint);
            uv.Add(new Vector2(1, 0.05f));
            //v3
            vertices.Add(nextGroup.LeftSidePoint);
            uv.Add(new Vector2(0, 0.05f));
            //v4
            vertices.Add(nextGroup.Point);
            uv.Add(new Vector2(0, 1));
            //v5
            vertices.Add(nextGroup.LeftSidePoint);
            uv.Add(new Vector2(0, 0.05f));
            //v6
            vertices.Add(nextGroup.RightSidePoint);
            uv.Add(new Vector2(0, 0.05f));
        }

        int index = 0;
        for (int i = 0, len = vertices.Count; i < len; i += 7)
        {
            index = i;

	        // v0, v3, v1
			triangles.Add(index);
            triangles.Add(index + 3);
            triangles.Add(index + 1);

	        // v2, v3, v0
			triangles.Add(index + 2);
            triangles.Add(index + 3);
            triangles.Add(index);

	        // v4, v5, v6
			triangles.Add(index + 4);
            triangles.Add(index + 5);
            triangles.Add(index + 6);
        }

        mesh.vertices = vertices.ToArray();
        mesh.uv = uv.ToArray();
        mesh.triangles = triangles.ToArray();

        return mesh;
    }

    private void OnDrawGizmos() 
    {
        for (int i = 0, len = transform.childCount; i < len; i++)
        {
            Gizmos.color = Color.yellow;
            Gizmos.DrawLine(transform.GetChild(i).position, transform.GetChild((i + 1) % transform.childCount).position);

            Gizmos.color = Color.white;
            Gizmos.DrawLine(transform.GetChild(i).position, transform.position);
        }
    }
}
