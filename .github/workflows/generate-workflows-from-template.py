#!/usr/bin/env python3
"""
脚本用于基于模板生成Linux和Windows的GitHub Actions配置文件
"""

import os

def generate_yaml_from_template(template_file, virtual_machine, os_label, output_file):
    """
    从模板生成YAML配置文件
    
    Args:
        template_file: 模板文件路径
        virtual_machine: 虚拟机名称
        os_label: 操作系统标签
        output_file: 输出文件路径
    """
    
    # 读取模板内容
    with open(template_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 替换占位符
    content = content.replace('<<<virtual-machine>>>', virtual_machine)
    content = content.replace('<<<os-label>>>', os_label)
    
    # 写入输出文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"已生成: {output_file}")

def main():
    # 模板文件路径
    template_file = "test-docker-images.yml.template"
    
    # 检查模板文件是否存在
    if not os.path.exists(template_file):
        print(f"错误: 模板文件 '{template_file}' 不存在")
        return
    
    # 生成Linux版本
    generate_yaml_from_template(
        template_file=template_file,
        virtual_machine="linux",
        os_label="ubuntu",
        output_file="test-docker-images-on-linux.yml"
    )
    
    # 生成Windows版本
    generate_yaml_from_template(
        template_file=template_file,
        virtual_machine="windows", 
        os_label="windows",
        output_file="test-docker-images-on-windows.yml"
    )
    
    print("\n生成完成!")

if __name__ == "__main__":
    main()
