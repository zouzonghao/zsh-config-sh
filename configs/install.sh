#!/bin/bash

set -e

echo "🚀 开始安装 Zsh 配置..."

# 检查系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS

    # 检查并安装 Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew 未安装。正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew 已安装！."
    fi

    # 检查并安装 coreutils
    if ! command -v gls &> /dev/null; then
        echo "coreutils 未安装。正在安装 coreutils..."
        brew install coreutils
    else
        echo "coreutils 已安装！."
    fi
fi

# 检查并创建插件目录
if [ ! -d ~/.zsh ]; then
    echo "创建 ~/.zsh 目录..."
    mkdir -p ~/.zsh
else
    echo "~/.zsh 目录已存在."
fi

# 复制插件
echo "📦 复制插件文件..."
if [ -d ".zsh" ]; then
    cp -r .zsh/* ~/.zsh/
fi

# 复制配置文件
echo "📝 复制配置文件..."
if [ -f ".zshrc" ]; then
    cp .zshrc ~/.zshrc
fi

if [ -f ".dircolors" ]; then
    cp .dircolors ~/.dircolors
fi

# 🔧 修复权限（解决 zsh compinit 安全警告）
echo "🔧 修复目录权限..."

# 设置 ~/.zsh 目录权限为 755
chmod 755 ~/.zsh
echo "   ✓ ~/.zsh 权限设置为 755"

# 递归设置所有子目录和文件权限为 755
chmod -R 755 ~/.zsh/*
echo "   ✓ ~/.zsh/* 权限设置为 755"

# 设置所有者为当前用户（root 用户下设置为 root:root）
if [ "$(id -u)" -eq 0 ]; then
    chown -R root:root ~/.zsh
    echo "   ✓ ~/.zsh 所有者设置为 root:root"
else
    chown -R $(whoami):$(whoami) ~/.zsh
    echo "   ✓ ~/.zsh 所有者设置为 $(whoami):$(whoami)"
fi

# 设置配置文件权限为 644
chmod 644 ~/.zshrc ~/.dircolors 2>/dev/null || true
echo "   ✓ 配置文件权限设置为 644"

# 删除可能存在的旧 compdump 文件（避免缓存问题）
rm -f ~/.zcompdump* 2>/dev/null || true
echo "   ✓ 清理旧 compdump 缓存"

echo ""
echo "✅ 配置完成！"
echo "💡 执行以下命令生效："
echo "   exec zsh"