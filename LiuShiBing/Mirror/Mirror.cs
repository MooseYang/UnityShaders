using UnityEngine;

/// <summary>
/// 测试镜面反射效果
/// 实现绘制一个球体相对称的镜面球体
/// 该脚本挂载到平面上
/// </summary>
public class Mirror : MonoBehaviour
{
    public Transform sphere;


    private void Start() 
    {
        //平面的法线
        Vector3 N = this.transform.up;
        //平面上一点O
        Vector3 oPos = this.transform.position;
        //球体上一点到平面上一点的向量
        Vector3 po = oPos - sphere.transform.position;
        //球体上一点到平面上的垂直距离
        float distance = -Vector3.Dot(N, po); 

        //根据distance计算出球体的虚像球体
        GameObject go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        go.transform.position = sphere.position - N * distance * 2;     
    }
}
