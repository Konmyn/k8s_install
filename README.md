# kubernetes 1.12.8 + DAP 自动安装包

## 安装要求

- 系统版本： 纯净安装的 CentOS Linux release 7.6.1810 (Core)
- 所有主机使用root账户，且登录密放到项目下的 password.txt 中
- 所有主机的IP和主机名更新到 auto-controller.sh 脚本的 HOSTIP HOSTNAME 变量中

## 安装步骤

- 打包本项目： `./maktar.sh`，将打包好的 k8s_install.tar 放到 k8s 集群的第一台节点上（master节点）的 /root 路径下
- 解压 `tar xvf k8s_install.tar` 后进入到解压出的路径下 k8s_install
- 运行解压包中的脚本 `./auto-controller.sh` 等待安装完成，enjoy!

## TODO

- DAP的部署
- 支持带GPU的机器
- k8s高可用
- 细节优化

ps： 本仓库只存储代码，安装包因为太大，放不进来，需要单独提供