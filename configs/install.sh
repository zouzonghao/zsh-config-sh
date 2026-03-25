#!/bin/bash

set -e

echo "🚀 开始安装 Zsh 配置..."

# 获取脚本所在目录，确保无论在哪里执行都能找到正确的文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 安全的 realpath 实现（兼容所有系统）
realpath_safe() {
    if command -v realpath &> /dev/null; then
        realpath "$1"
    else
        # Fallback: 使用 Python 或手动实现
        if command -v python3 &> /dev/null; then
            python3 -c "import os; print(os.path.realpath('$1'))"
        else
            # 最简单的情况：如果是相对路径，手动解析
            if [[ "$1" = /* ]]; then
                echo "$1"
            else
                echo "$(pwd)/$1"
            fi
        fi
    fi
}
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "Homebrew 未安装。正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew 已安装！"
    fi

    if ! command -v gls &> /dev/null; then
        echo "coreutils 未安装。正在安装 coreutils..."
        brew install coreutils
    else
        echo "coreutils 已安装！"
    fi

elif [[ "$OSTYPE" == "linux-gnu" ]] || [[ "$OSTYPE" == "linux-musl" ]]; then
    # Linux (包括 Alpine)
    if [ -f /etc/alpine-release ]; then
        # Alpine Linux
        echo "检测到 Alpine Linux，正在安装依赖..."
        if ! command -v zsh &> /dev/null; then
            echo "zsh 未安装。正在安装..."
            apk add --no-cache zsh
        fi
        if ! command -v realpath &> /dev/null; then
            echo "coreutils 未安装。正在安装..."
            apk add --no-cache coreutils
        fi
        if ! command -v compaudit &> /dev/null; then
            echo "compinit 相关功能不可用，请在安装后手动运行 zsh"
        fi
    else
        # 其他 Linux 发行版
        if ! command -v realpath &> /dev/null; then
            echo "coreutils 未安装。正在安装..."
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y coreutils
            elif command -v yum &> /dev/null; then
                yum install -y coreutils
            elif command -v dnf &> /dev/null; then
                dnf install -y coreutils
            fi
        fi
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
if [ -d ".zsh" ] && [ "$(realpath_safe .zsh)" != "$(realpath_safe ~/.zsh)" ]; then
    cp -r .zsh/* ~/.zsh/
    echo "   ✓ 插件文件复制完成"
else
    echo "⚠️  跳过插件复制（源目录与目标目录相同或不存在）"
fi

# 复制配置文件
echo "📝 复制配置文件..."
if [ -f ".zshrc" ]; then
    # 检查源文件和目标文件是否是同一个文件
    if [ "$(realpath_safe .zshrc)" = "$(realpath_safe ~/.zshrc)" ]; then
        echo "⚠️  跳过 .zshrc 复制（源文件与目标文件相同）"
    else
        cp .zshrc ~/.zshrc
        echo "   ✓ .zshrc 复制完成"
    fi
fi

if [ -f ".dircolors" ]; then
    if [ "$(realpath_safe .dircolors)" = "$(realpath_safe ~/.dircolors)" ]; then
        echo "⚠️  跳过 .dircolors 复制（源文件与目标文件相同）"
    else
        cp .dircolors ~/.dircolors
        echo "   ✓ .dircolors 复制完成"
    fi
fi

# 删除可能存在的旧 compdump 文件（避免缓存问题）
rm -f ~/.zcompdump* 2>/dev/null || true
echo "   ✓ 清理旧 compdump 缓存"

echo ""
echo "✅ 配置完成！"
echo "💡 执行以下命令生效："
echo "   exec zsh"