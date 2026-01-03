#!/bin/bash

# Gemini Chat CLI 安装脚本
# 版本: v2.0.0

set -e

echo "╔════════════════════════════════════════╗"
echo "║     Gemini Chat CLI 安装程序           ║"
echo "║            v2.0.0                      ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 检查依赖
echo "🔍 检查依赖..."

if ! command -v curl &> /dev/null; then
    echo "❌ curl 未安装"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ python3 未安装"
    exit 1
fi

echo "✅ 依赖检查通过"
echo ""

# 确定安装目录
INSTALL_DIR="$HOME/bin"
if [ ! -d "$INSTALL_DIR" ]; then
    echo "📁 创建目录: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# 复制脚本
echo "📦 安装 gchat..."
cp bin/gchat "$INSTALL_DIR/gchat"
chmod +x "$INSTALL_DIR/gchat"

echo "📦 安装 gflashchat..."
cp bin/gflashchat "$INSTALL_DIR/gflashchat"
chmod +x "$INSTALL_DIR/gflashchat"

echo "✅ gchat 已安装到: $INSTALL_DIR/gchat"
echo "✅ gflashchat 已安装到: $INSTALL_DIR/gflashchat"
echo ""

# 检查PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "⚠️  $INSTALL_DIR 不在 PATH 中"
    echo ""
    echo "请执行以下命令之一："
    echo ""

    # 检测shell类型
    if [ -n "$ZSH_VERSION" ]; then
        echo "  echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.zshrc"
        echo "  source ~/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        echo "  echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc"
        echo "  source ~/.bashrc"
    else
        echo "  export PATH=\"\$HOME/bin:\$PATH\""
    fi
    echo ""
else
    echo "✅ PATH 已配置"
fi

# 测试安装
echo "🧪 测试安装..."
if "$INSTALL_DIR/gchat" --help > /dev/null 2>&1; then
    echo "✅ 安装成功！"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 安装完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "快速开始："
    echo "  gchat              # 交互式对话 (gemini-3-pro-preview)"
    echo "  gflashchat         # 快速对话 (gemini-3-flash-preview)"
    echo "  gchat -c           # 继续上次对话"
    echo "  gchat -p \"问题\"   # 单次提问"
    echo "  gchat --help       # 查看帮助"
    echo ""
    echo "文档位置："
    echo "  $(pwd)/README.md"
    echo "  $(pwd)/docs/"
    echo ""
else
    echo "❌ 安装失败，请检查错误信息"
    exit 1
fi
