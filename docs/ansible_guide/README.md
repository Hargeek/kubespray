# Ansible指南文档

本目录包含了Kubespray项目中Ansible相关的详细文档和示例。

## 📁 文档列表

### 1. 变量加载机制
- **variable-loading-process.md** - Ansible变量加载和处理机制的详细说明
- **variable-loading-example.yml** - 变量加载示例

### 2. 调试工具
- **debug-variables.yml** - 调试Ansible变量的playbook
- **debug-vars.sh** - Ansible变量调试脚本
- **print-all-variables.yml** - 打印所有变量的playbook

### 3. 角色分析
- **cilium-role-analysis.md** - Cilium网络插件角色的详细分析

### 4. 自定义配置
- **custom-ansible-config.md** - Ansible自定义配置示例

## 🎯 使用说明

### 调试变量
```bash
# 运行调试脚本
./docs/ansible_guide/debug-vars.sh

# 运行调试playbook
ansible-playbook -i inventory/cluster01/hosts.yaml docs/ansible_guide/debug-variables.yml

# 打印所有变量
ansible-playbook -i inventory/cluster01/hosts.yaml docs/ansible_guide/print-all-variables.yml
```

### 查看变量加载过程
```bash
# 查看详细输出
ansible-playbook -i inventory/cluster01/hosts.yaml cluster.yml -vvv
```

### 自定义配置
参考 `custom-ansible-config.md` 了解如何自定义Ansible配置。

## 📚 相关文档

- [Ansible官方文档](https://docs.ansible.com/)
- [Kubespray文档](../README.md)
- [变量配置指南](../ansible/vars.md)

## 🔧 快速开始

1. **了解变量加载机制**: 阅读 `variable-loading-process.md`
2. **调试变量问题**: 使用 `debug-variables.yml` 或 `debug-vars.sh`
3. **自定义配置**: 参考 `custom-ansible-config.md`
4. **分析角色结构**: 阅读 `cilium-role-analysis.md`

## 📝 注意事项

- 这些文档专门为Kubespray项目设计
- 调试脚本需要在正确的inventory目录下运行
- 自定义配置需要谨慎测试
- 建议在测试环境中验证配置更改