#!/bin/bash

set -e

echo "🚀 开始安装 Zsh 配置..."

# 获取脚本所在目录，确保无论在哪里执行都能找到正确的文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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
if [ -d ".zsh" ] && [ "$(realpath .zsh)" != "$(realpath ~/.zsh)" ]; then
    cp -r .zsh/* ~/.zsh/
    echo "   ✓ 插件文件复制完成"
else
    echo "⚠️  跳过插件复制（源目录与目标目录相同或不存在）"
fi

# 复制配置文件
echo "📝 复制配置文件..."
if [ -f ".zshrc" ]; then
    cp .zshrc ~/.zshrc
    echo "   ✓ .zshrc 复制完成"
fi

if [ -f ".dircolors" ]; then
    cp .dircolors ~/.dircolors
    echo "   ✓ .dircolors 复制完成"
fi

# 🔧 修复权限（解决 zsh compinit 安全警告）
echo "🔧 修复目录权限..."

# 设置 ~/.zsh 目录权限为 755
chmod 755 ~/.zsh
echo "   ✓ ~/.zsh 权限设置为 755"

# ✅ 修复：区分目录和文件设置权限
# 目录设置为 755
find ~/.zsh -type d -exec chmod 755 {} \;
echo "   ✓ 所有子目录权限设置为 755"

# 文件设置为 644
find ~/.zsh -type f -exec chmod 644 {} \;
echo "   ✓ 所有文件权限设置为 644"

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