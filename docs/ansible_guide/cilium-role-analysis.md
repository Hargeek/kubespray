# Cilium网络插件角色分析

## 📁 目录结构

```
roles/network_plugin/cilium/
├── defaults/
│   └── main.yml          # 默认变量定义
├── tasks/
│   ├── main.yml          # 主任务文件
│   ├── install.yml       # 安装任务
│   ├── apply.yml         # 应用配置任务
│   ├── check.yml         # 检查任务
│   ├── reset.yml         # 重置任务
│   └── reset_iface.yml   # 重置接口任务
└── templates/
    ├── 000-cilium-portmap.conflist.j2  # CNI配置文件模板
    ├── cilium/           # Cilium核心组件模板
    ├── cilium-operator/  # Cilium操作器模板
    └── hubble/           # Hubble监控模板
```

## 🔧 各目录功能详解

### 1. defaults/ 目录
**作用**: 定义Cilium的默认配置变量

**主要变量**:
```yaml
# Cilium版本
cilium_version: "v1.15.9"

# Hubble配置
cilium_enable_hubble: false
hubble_enabled: false

# 网络配置
cilium_tunnel_mode: "vxlan"
cilium_identity_allocation_mode: "kvstore"

# 资源限制
cilium_operator_replicas: 2
cilium_resources:
  limits:
    cpu: "500m"
    memory: "500Mi"
```

### 2. tasks/ 目录
**作用**: 定义Ansible任务执行逻辑

#### main.yml - 主任务文件
```yaml
---
- name: Include install tasks
  import_tasks: install.yml
  tags: network

- name: Include apply tasks
  import_tasks: apply.yml
  tags: network
```

#### install.yml - 安装任务
**功能**:
- 下载Cilium二进制文件
- 安装Cilium CLI工具
- 准备配置文件

**关键任务**:
```yaml
- name: Download Cilium
  include_tasks: "../../../download/tasks/download_file.yml"
  vars:
    download: "{{ download_defaults | combine(downloads.cilium) }}"

- name: Install Cilium CLI
  copy:
    src: "{{ local_release_dir }}/cilium-{{ cilium_version }}/linux-{{ image_arch }}/cilium"
    dest: "{{ bin_dir }}/cilium"
    mode: "0755"
```

#### apply.yml - 应用配置任务
**功能**:
- 生成Kubernetes清单文件
- 应用Cilium DaemonSet
- 配置网络策略

**关键任务**:
```yaml
- name: Generate Cilium manifests
  template:
    src: "{{ item }}.j2"
    dest: "{{ kube_config_dir }}/{{ item }}"
    mode: "0644"
  with_items:
    - cilium-config.yml
    - cilium-ds.yml
    - cilium-cr.yml
```

### 3. templates/ 目录
**作用**: 包含Jinja2模板文件，用于生成配置文件

#### cilium/ 子目录
**功能**: Cilium核心组件模板

**主要模板**:
- `config.yml.j2` - Cilium配置映射
- `ds.yml.j2` - Cilium DaemonSet
- `cr.yml.j2` - Cilium ClusterRole

#### cilium-operator/ 子目录
**功能**: Cilium操作器模板

**主要模板**:
- `deploy.yml.j2` - Cilium操作器部署

#### hubble/ 子目录
**功能**: Hubble监控组件模板

**主要模板**:
- Hubble DaemonSet和Service配置

## 🎯 如何设计自己的步骤

### 1. 创建新的网络插件角色

```bash
# 创建角色目录结构
mkdir -p roles/network_plugin/my_plugin/{defaults,tasks,templates,handlers}
```

### 2. 定义默认变量 (defaults/main.yml)

```yaml
---
# My Plugin默认配置
my_plugin_version: "v1.0.0"
my_plugin_enabled: true
my_plugin_config:
  mode: "bridge"
  mtu: 1500
```

### 3. 创建任务文件 (tasks/main.yml)

```yaml
---
- name: Include install tasks
  import_tasks: install.yml
  tags: network

- name: Include apply tasks
  import_tasks: apply.yml
  tags: network
```

### 4. 创建安装任务 (tasks/install.yml)

```yaml
---
- name: Download My Plugin
  include_tasks: "../../../download/tasks/download_file.yml"
  vars:
    download: "{{ download_defaults | combine(downloads.my_plugin) }}"

- name: Install My Plugin binary
  copy:
    src: "{{ local_release_dir }}/my_plugin-{{ my_plugin_version }}/my_plugin"
    dest: "{{ bin_dir }}/my_plugin"
    mode: "0755"
```

### 5. 创建应用任务 (tasks/apply.yml)

```yaml
---
- name: Generate My Plugin manifests
  template:
    src: "{{ item }}.j2"
    dest: "{{ kube_config_dir }}/{{ item }}"
    mode: "0644"
  with_items:
    - my_plugin-config.yml
    - my_plugin-ds.yml

- name: Apply My Plugin manifests
  kube:
    kubectl: "{{ bin_dir }}/kubectl"
    filename: "{{ kube_config_dir }}/{{ item }}"
    state: "latest"
  with_items:
    - my_plugin-config.yml
    - my_plugin-ds.yml
```

### 6. 创建模板文件 (templates/)

```jinja2
# templates/my_plugin-config.yml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-plugin-config
  namespace: kube-system
data:
  config: |
    {
      "mode": "{{ my_plugin_config.mode }}",
      "mtu": {{ my_plugin_config.mtu }}
    }
```

### 7. 集成到Kubespray

#### 修改网络插件选择逻辑
```yaml
# roles/network_plugin/meta/main.yml
dependencies:
  - role: network_plugin/calico
    when: kube_network_plugin == 'calico'
  - role: network_plugin/cilium
    when: kube_network_plugin == 'cilium'
  - role: network_plugin/my_plugin
    when: kube_network_plugin == 'my_plugin'
```

#### 添加下载配置
```yaml
# roles/kubespray-defaults/defaults/main/download.yml
downloads:
  my_plugin:
    version: "{{ my_plugin_version }}"
    url: "https://github.com/myorg/my_plugin/releases/download/{{ my_plugin_version }}/my_plugin-{{ my_plugin_version }}-linux-{{ image_arch }}.tar.gz"
```

## 🔍 调试机制

### 1. 预部署检查

```bash
# 检查配置
ansible-playbook -i inventory/cluster01/hosts.yaml --check cluster.yml

# 只运行特定标签
ansible-playbook -i inventory/cluster01/hosts.yaml --tags network cluster.yml

# 详细输出
ansible-playbook -i inventory/cluster01/hosts.yaml -vvv cluster.yml
```

### 2. 变量调试

```bash
# 打印所有变量
ansible-playbook -i inventory/cluster01/hosts.yaml print-all-variables.yml

# 检查特定变量
ansible -i inventory/cluster01/hosts.yaml all -m debug -a "var=kube_network_plugin"
```

### 3. 分步调试

```bash
# 只运行网络插件安装
ansible-playbook -i inventory/cluster01/hosts.yaml --tags network --limit k8s_cluster cluster.yml

# 只运行特定角色
ansible-playbook -i inventory/cluster01/hosts.yaml --tags cilium cluster.yml
```

## 📝 最佳实践

### 1. 变量命名规范
- 使用小写字母和下划线
- 添加插件前缀避免冲突
- 提供合理的默认值

### 2. 任务组织
- 将复杂任务分解为小任务
- 使用标签便于选择性执行
- 添加适当的错误处理

### 3. 模板设计
- 使用条件语句处理不同配置
- 提供配置验证
- 添加注释说明

### 4. 测试验证
- 创建单元测试
- 验证配置正确性
- 测试不同环境兼容性