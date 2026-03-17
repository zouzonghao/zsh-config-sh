#!/bin/bash

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

# 设置权限
chmod 644 ~/.zshrc ~/.dircolors 2>/dev/null || true

echo ""
echo "✅ 配置完成，请重启终端。"
echo "💡 执行以下命令生效："
echo "   exec zsh"