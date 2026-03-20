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

# 设置所有者（仅在用户本地存在时执行，避免 LDAP/NIS 等远程用户问题）
current_user=$(whoami)
current_group=$(id -gn 2>/dev/null || echo "$current_user")

# 获取用户信息，区分本地用户和远程用户（LDAP/NIS 等）
user_info=$(getent passwd "$current_user" 2>/dev/null || echo "")
user_uid=$(echo "$user_info" | cut -d: -f3 2>/dev/null || echo "999999")

# uid < 1000 通常是系统用户（0=root, 1-999=系统账号），不轻易修改
# 只有本地用户才执行 chown
if [ "$user_uid" -lt 1000 ] || [ -z "$user_info" ]; then
    echo "   ℹ  用户 $current_user (uid=$user_uid) 是系统用户或非本地用户，跳过 chown"
else
    chown -R "$current_user:$current_group" ~/.zsh 2>/dev/null && echo "   ✓ ~/.zsh 所有者设置为 $current_user:$current_group" || echo "   ℹ  无法设置所有者"
fi

# 设置配置文件权限为 644
chmod 644 ~/.zshrc ~/.dircolors 2>/dev/null || true
echo "   ✓ 配置文件权限设置为 644"

# 删除可能存在的旧 compdump 文件（避免缓存问题）
rm -f ~/.zcompdump* 2>/dev/null || true
echo "   ✓ 清理旧 compdump 缓存"

# 🔧 修复 zsh compinit 安全警告
# compinit 要求相关目录和文件的权限不能过于宽松
echo "🔧 检查 compinit 安全配置..."

# 确保 ~/.zsh 目录权限正确（compinit 要求目录不能有 group/other 写权限）
chmod 755 ~/.zsh 2>/dev/null || true

# 检查是否在 zsh 环境下运行 compaudit（compaudit 是 zsh 内置命令）
if command -v zsh &> /dev/null; then
    # 获取不安全的目录
    insecure_dirs=$(zsh -c 'compaudit 2>/dev/null' 2>/dev/null || true)
    if [ -n "$insecure_dirs" ]; then
        echo "   发现不安全的目录，正在修复权限..."
        echo "$insecure_dirs" | grep "^/" | while read -r dir; do
            if [ -d "$dir" ]; then
                chmod 755 "$dir" 2>/dev/null && echo "   ✓ 修复: $dir" || true
            fi
        done
    else
        echo "   ✓ compinit 安全检查通过"
    fi
else
    echo "   ℹ  未检测到 zsh，compinit 安全检查已跳过"
    echo "   ℹ  提示：安装后首次运行 zsh 时确保 ~/.zsh 目录权限为 755"
fi

echo ""
echo "✅ 配置完成！"
echo "💡 执行以下命令生效："
echo "   exec zsh"