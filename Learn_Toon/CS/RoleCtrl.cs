using UnityEngine;


public class RoleCtrl : MonoBehaviour
{
    public string StateName = "Idle";
    private Animator ani;
    private UnityEngine.AI.NavMeshAgent agent;


	private void Start ()
	{
        ani = GetComponent<Animator>();
        ani.CrossFade(StateName, 0);
        agent = GetComponent<UnityEngine.AI.NavMeshAgent>();
	}

	private void Update ()
	{
        if (agent.hasPath && agent.remainingDistance <= 0.1f)
        {
            ani.CrossFade("Idle", 0.1f);
        }

		//直线移动
        float vertical = Input.GetAxis("Vertical");
        if (vertical != 0)
        {
			//使用Quaternion.Euler和方向向量计算新的坐标
			//四元数和向量相乘，结果是将这个向量旋转欧拉角后的新向量
			MoveTo(transform.position + Quaternion.Euler(0, transform.eulerAngles.y, 0) * (vertical > 0 ? Vector3.forward : Vector3.back));
        }

		//转向
        float horizontal = Input.GetAxis("Horizontal");
        if (horizontal != 0)
        {
            transform.eulerAngles = new Vector3(0, transform.eulerAngles.y + horizontal * 2, 0);
        }
	}

    public void MoveTo(Vector3 toPos)
    {
        agent.SetDestination(toPos);
        ani.CrossFade("Running", 0);
    }
}
