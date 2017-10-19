# Virtual-Machine-Manager
创建或删除基于"CentOS7.4-Base"的差异镜像

账户：root
密码：123456

使用说明：
以下内容以n代替任意数字

执行方式一：
bash vmm.sh n
n > 0
连续创建或重置n个差异镜像“CentOS7.4-Auto-n”
n = 0
删除所有差异镜像“CentOS7.4-Auto-n”

执行方式二：
bash vmm.sh
Command:> n
n > 0
创建或重置指定的差异镜像"CentOS7.4-n"
n = 0
删除所有差异镜像"CentOS7.4-n"
n < 0
仅删除指定的差异镜像"CentOS7.4-n"
n = -0
删除所有已存在的虚拟机镜像！

退出脚本请直接按"Ctrl+C"
