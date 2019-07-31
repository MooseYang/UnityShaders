using UnityEngine;
using System.Collections.Generic;


public class Sun : MonoBehaviour
{
    public Transform SunShine;
    public Transform SunPoints;
    public float Strong = 10;
    private List<Transform> points;


	void Start ()
	{
        points = new List<Transform>();

        for (int i = 0, len = SunPoints.childCount; i < len; i++)
        {
            points.Add(SunPoints.GetChild(i));
        }
	}
	
	void Update ()
	{
        Transform cameraTrans = Camera.main.transform;

        Vector3 d0 = (transform.position - cameraTrans.position).normalized;
        Vector3 d1 = cameraTrans.forward;

        float dot = Mathf.Clamp01(Vector3.Dot(d0, d1));

        Vector3 cross = Vector3.Cross(d0, d1);

		//太阳光随着摄像机的位置角度的改变而旋转
        SunPoints.localEulerAngles = new Vector3(5 * Mathf.Pow(dot, 4), cross.y * 90, SunPoints.localEulerAngles.z);
        SunShine.transform.localScale = new Vector3(Strong, Strong, Strong) * Mathf.Pow(dot, 4);

        transform.LookAt(cameraTrans.position);
        SunShine.LookAt(cameraTrans.position);

        float size, sizeStep0 = 0, sizeStep1 = 0;
        for (int i = 0, len = points.Count; i < len; i++)
        {
            points[i].LookAt(cameraTrans.position);
            size = i % 2 == 0 ? 0.15f + sizeStep0++ * 0.1f : 0.3f + sizeStep1++ * 0.2f;
            points[i].localScale = new Vector3(size, size, size) * Mathf.Pow(dot, 4);
        }
	}
}
