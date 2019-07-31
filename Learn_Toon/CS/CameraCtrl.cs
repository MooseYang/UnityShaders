using UnityEngine;


/// <summary>
/// 相机跟随玩家移动的逻辑算法
/// </summary>


public class CameraCtrl : MonoBehaviour 
{
    public Transform Target;
    public float BaseHeight = 3;
    public float AngleA = 45;
    public float Distance = 3;
    public float TargetHeight = 2;

    private Vector3 oldMousePos;
    private float angleOffsetY;       //控制左右的变化率 (Yaw)
    private float targetOffsetHeight; //控制上下的变化率 (Pitch)

	
	private void Update () 
    {
		//计算相机和玩家的相对位置 (跟随)
        transform.position = Target.position + new Vector3(0, BaseHeight, 0) + 
        Quaternion.Euler(0, AngleA + angleOffsetY, 0) * Vector3.back * Distance;

		//计算相机的观察范围 (看向玩家的头部)
        transform.rotation = Quaternion.LookRotation((Target.position + new Vector3(0, TargetHeight + targetOffsetHeight, 0))
        - transform.position);;
    }

    private void OnGUI() 
    {
        if (Event.current.type == EventType.MouseDown)
        {
            oldMousePos = Input.mousePosition;
        }
        else if (Event.current.type == EventType.MouseDrag)
        {
			//只需要方向
            Vector3 offsetPos = (Input.mousePosition - oldMousePos).normalized;
			//x方向的变化率，表示：左右的变化
            angleOffsetY += offsetPos.x * 2;
			//y方向的变化率，表示：上下的变化
            targetOffsetHeight = Mathf.Clamp(targetOffsetHeight + offsetPos.y * 0.1f, 0, TargetHeight * 1.5f);

            oldMousePos = Input.mousePosition;
        }
    }
}
