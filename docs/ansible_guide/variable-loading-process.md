# Ansible变量加载和处理机制

## 1. 变量加载顺序

```
1. role defaults (最低优先级)
   ├── roles/kubespray-defaults/defaults/main/main.yml
   ├── roles/kubernetes/defaults/main.yml
   └── 其他role的defaults

2. inventory vars
   ├── inventory/cluster01/hosts.yaml (主机变量)
   └── inventory/cluster01/group_vars/ (组变量)

3. playbook vars
   ├── playbooks/cluster.yml (playbook变量)
   └── 其他playbook文件

4. host facts (自动收集的主机信息)
   ├── ansible_default_ipv4
   ├── ansible_distribution
   └── 其他系统信息

5. registered vars (任务执行结果)
   ├── 命令输出
   └── 文件内容

6. set_fact (动态设置)
   ├── 条件变量
   └── 计算变量

7. extra vars (最高优先级)
   ├── 命令行参数 (-e)
   └── 外部文件
```

## 2. 变量覆盖机制

### 示例：kube_version变量
```yaml
# 1. 默认值 (roles/kubespray-defaults/defaults/main/main.yml)
kube_version: v1.31.4

# 2. 组变量覆盖 (inventory/cluster01/group_vars/k8s_cluster/k8s-cluster.yml)
kube_version: v1.30.6

# 3. 命令行覆盖
ansible-playbook -e "kube_version=v1.29.0"

# 最终结果: kube_version = v1.29.0
```

## 3. 条件变量加载

### 网络插件变量
```yaml
# 根据kube_network_plugin选择不同的配置
kube_network_plugin: cilium

# 条件加载cilium相关变量
- include_vars: k8s-net-cilium.yml
  when: kube_network_plugin == 'cilium'
```

## 4. 变量使用示例

### 在模板中使用
```jinja2
# roles/kubernetes/control-plane/templates/kubeadm-config.yaml.j2
apiVersion: {{ kubeadm_config_api_version }}
kind: InitConfiguration
kubernetesVersion: {{ kube_version }}
```

### 在任务中使用
```yaml
# roles/kubernetes/node/tasks/main.yml
- name: Install kubelet
  package:
    name: kubelet-{{ kube_version }}
    state: present
```

## 5. 变量调试方法

### 查看变量值
```bash
# 查看特定变量
ansible -i inventory/cluster01/hosts.yaml all -m debug -a "var=kube_version"

# 查看所有变量
ansible -i inventory/cluster01/hosts.yaml all -m debug -a "var=hostvars[inventory_hostname]"
```

### 查看变量来源
```bash
# 查看变量加载过程
ansible-playbook -i inventory/cluster01/hosts.yaml cluster.yml -vvv
```