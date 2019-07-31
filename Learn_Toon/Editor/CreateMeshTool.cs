using UnityEngine;
using UnityEditor;


public class CreateMeshTool 
{
    [MenuItem("ToonWater/CreateRippleMesh")]
    static void CreateRippleMesh() 
    {
        Transform[] selection = Selection.GetTransforms(SelectionMode.Editable | SelectionMode.ExcludePrefab);
        MeshFilter filter;
        Ripple ripple;
        foreach (Transform sel in selection)
        {
            filter = sel.gameObject.GetComponent<MeshFilter>();
            ripple = sel.gameObject.GetComponent<Ripple>();
            if (filter != null && ripple != null)
            {
                filter.sharedMesh = ripple.CreateMesh();
                Debug.Log(sel.name + " Ripple网格创建完毕！");
            }
        }
    }

    [MenuItem("ToonWater/CreateCoastLineMesh")]
    static void CreateCoastLineMesh() 
    {
        Transform[] selection = Selection.GetTransforms(SelectionMode.Editable | SelectionMode.ExcludePrefab);
        MeshFilter filter;
        CoastLine coastLine;
        foreach (Transform sel in selection)
        {
            filter = sel.gameObject.GetComponent<MeshFilter>();
            coastLine = sel.gameObject.GetComponent<CoastLine>();
            if (filter != null && coastLine != null)
            {
                filter.sharedMesh = coastLine.CreateMesh();
                Debug.Log(sel.name + " CoastLine网格创建完毕！");
            }
        }
    }
}
