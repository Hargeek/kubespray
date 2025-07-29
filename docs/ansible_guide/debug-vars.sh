#!/bin/bash

# Ansible变量调试脚本
echo "🔍 Ansible变量调试工具"
echo "========================"

# 检查inventory文件
echo "📋 检查inventory文件..."
if [ -f "inventory/cluster01/hosts.yaml" ]; then
    echo "✅ hosts.yaml 存在"
else
    echo "❌ hosts.yaml 不存在"
    exit 1
fi

# 检查group_vars目录
echo "📁 检查group_vars目录..."
ls -la inventory/cluster01/group_vars/

echo ""
echo "🔧 调试特定变量..."

# 调试kube_version
echo "1. 查看kube_version变量:"
ansible -i inventory/cluster01/hosts.yaml all -m debug -a "var=kube_version" 2>/dev/null || echo "❌ 无法执行ansible命令"

# 调试kube_network_plugin
echo ""
echo "2. 查看kube_network_plugin变量:"
ansible -i inventory/cluster01/hosts.yaml all -m debug -a "var=kube_network_plugin" 2>/dev/null || echo "❌ 无法执行ansible命令"

# 调试container_manager
echo ""
echo "3. 查看container_manager变量:"
ansible -i inventory/cluster01/hosts.yaml all -m debug -a "var=container_manager" 2>/dev/null || echo "❌ 无法执行ansible命令"

echo ""
echo "📊 查看变量使用位置..."

# 查找变量使用位置
echo "4. 查找kube_version使用位置:"
grep -r "kube_version" roles/ --include="*.yml" --include="*.j2" | head -5

echo ""
echo "5. 查找kube_network_plugin使用位置:"
grep -r "kube_network_plugin" roles/ --include="*.yml" --include="*.j2" | head -5

echo ""
echo "🎯 运行调试playbook..."
echo "使用以下命令运行调试playbook:"
echo "ansible-playbook -i inventory/cluster01/hosts.yaml debug-variables.yml"