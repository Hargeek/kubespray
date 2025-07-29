# Ansible自定义配置示例

## 1. 自定义目录结构

### 默认结构
```
inventory/cluster01/
├── hosts.yaml
├── group_vars/
│   ├── all/
│   └── k8s_cluster/
└── host_vars/
    └── master1/
```

### 自定义结构
```
inventory/cluster01/
├── hosts.yaml
├── variables/          # 自定义group_vars目录
│   ├── global/        # 替代all
│   └── cluster/       # 替代k8s_cluster
└── host_variables/    # 自定义host_vars目录
    └── master1/
```

## 2. 配置自定义路径

### ansible.cfg 配置
```ini
[defaults]
# 自定义roles路径
roles_path = ./my_roles:/usr/share/ansible/roles

# 自定义inventory路径
inventory = ./my_inventory

# 忽略的文件扩展名
inventory_ignore_extensions = ~, .orig, .bak, .ini, .cfg, .retry, .pyc, .pyo, .creds, .gpg

[inventory]
# 忽略的目录模式
ignore_patterns = artifacts, credentials, temp
```

### 环境变量配置
```bash
# 设置自定义inventory路径
export ANSIBLE_INVENTORY=./my_inventory

# 设置自定义roles路径
export ANSIBLE_ROLES_PATH=./my_roles

# 设置自定义配置文件
export ANSIBLE_CONFIG=./my_ansible.cfg
```

## 3. 自定义变量加载

### 使用include_vars自定义加载
```yaml
# tasks/custom_vars.yml
- name: Load custom variables
  include_vars: "{{ item }}"
  with_first_found:
    - files:
        - "{{ inventory_dir }}/custom_vars/{{ ansible_distribution }}.yml"
        - "{{ inventory_dir }}/custom_vars/default.yml"
      paths:
        - "{{ inventory_dir }}/custom_vars"
      skip: true
```

### 使用vars_files自定义加载
```yaml
# playbooks/custom_cluster.yml
---
- name: Custom cluster deployment
  hosts: all
  vars_files:
    - "{{ inventory_dir }}/custom_vars/global.yml"
    - "{{ inventory_dir }}/custom_vars/{{ ansible_distribution }}.yml"
  tasks:
    - name: Use custom variables
      debug:
        msg: "Custom var: {{ my_custom_var }}"
```

## 4. 自定义文件命名

### 自定义inventory文件名
```bash
# 使用自定义文件名
ansible-playbook -i inventory/cluster01/my_hosts.yml cluster.yml
```

### 自定义playbook文件名
```bash
# 使用自定义playbook
ansible-playbook -i inventory/cluster01/hosts.yaml my_deploy.yml
```

### 自定义变量文件名
```yaml
# 在playbook中指定自定义变量文件
---
- name: Custom deployment
  hosts: all
  vars_files:
    - "{{ inventory_dir }}/my_variables.yml"
    - "{{ inventory_dir }}/my_config.yml"
```

## 5. 实际应用示例

### 项目结构
```
my_kubespray/
├── ansible.cfg
├── my_inventory/
│   └── cluster01/
│       ├── hosts.yaml
│       ├── variables/
│       │   ├── global.yml
│       │   ├── cluster.yml
│       │   └── network.yml
│       └── host_variables/
│           └── master1.yml
├── my_roles/
│   └── my_custom_role/
│       ├── defaults/
│       ├── tasks/
│       └── templates/
└── my_playbooks/
    ├── cluster.yml
    └── custom_deploy.yml
```

### 自定义ansible.cfg
```ini
[defaults]
inventory = ./my_inventory
roles_path = ./my_roles
host_key_checking = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp
fact_caching_timeout = 86400

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=30m -o ConnectionAttempts=100

[inventory]
ignore_patterns = artifacts, credentials, temp
```

### 自定义变量加载
```yaml
# my_inventory/cluster01/variables/global.yml
---
# 全局变量
my_global_var: "global_value"
my_custom_config:
  enabled: true
  timeout: 300

# my_inventory/cluster01/variables/cluster.yml
---
# 集群变量
my_cluster_name: "my-custom-cluster"
my_network_plugin: "my-custom-plugin"
```

## 6. 限制和注意事项

### 不能自定义的部分
1. **变量加载优先级顺序** - 这是Ansible核心机制
2. **Ansible内置变量名** - 如 `ansible_user`, `ansible_host`
3. **模块名称** - 如 `debug`, `template`, `copy`
4. **任务关键字** - 如 `name`, `hosts`, `tasks`

### 可以自定义的部分
1. **目录名称** - 通过配置和环境变量
2. **文件名称** - 完全自定义
3. **变量名称** - 除了内置变量
4. **角色名称** - 完全自定义
5. **标签名称** - 完全自定义

## 7. 最佳实践

### 命名规范
```yaml
# 使用前缀避免冲突
my_custom_var: "value"
my_plugin_config:
  enabled: true

# 使用描述性名称
cluster_network_config:
  plugin: "my_plugin"
  mode: "bridge"
```

### 目录组织
```
project/
├── ansible.cfg              # 主配置文件
├── inventory/               # 标准inventory目录
├── roles/                   # 标准roles目录
├── playbooks/              # 自定义playbook目录
├── variables/              # 自定义变量目录
└── templates/              # 自定义模板目录
```

### 配置管理
```bash
# 使用环境变量
export ANSIBLE_CONFIG=./my_ansible.cfg
export ANSIBLE_INVENTORY=./my_inventory

# 使用命令行参数
ansible-playbook -i my_inventory/cluster01/hosts.yaml my_playbooks/cluster.yml
```