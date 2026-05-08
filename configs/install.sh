#!/bin/sh
# zsh-config 安装脚本
# 安全安装：修复权限、保护SSH、提供回退机制

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# ========================================
# 1. 检查 zsh 是否已安装
# ========================================
if ! command -v zsh >/dev/null 2>&1; then
    error "zsh 未安装！请先安装 zsh："
    echo "  Debian/Ubuntu: apt install zsh"
    echo "  Alpine:        apk add zsh"
    echo "  CentOS/RHEL:   yum install zsh"
    echo "  macOS:         brew install zsh"
    exit 1
fi

info "zsh 已安装: $(command -v zsh)"

# ========================================
# 2. 检查必要文件是否存在
# ========================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$SCRIPT_DIR/.zshrc" ]; then
    error "未找到 .zshrc 文件，请确认在正确的解压目录中运行此脚本"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/.zsh" ]; then
    error "未找到 .zsh 插件目录，请确认 tarball 解压完整"
    exit 1
fi

info "配置文件检查通过"

# ========================================
# 3. 备份现有配置
# ========================================
BACKUP_DIR="$HOME/.zsh-config-backup-$(date +%Y%m%d%H%M%S)"

backup_file() {
    if [ -e "$1" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$1" "$BACKUP_DIR/"
        info "已备份: $1 -> $BACKUP_DIR/"
    fi
}

backup_file "$HOME/.zshrc"
backup_file "$HOME/.dircolors"
backup_file "$HOME/.zsh"

if [ -d "$BACKUP_DIR" ]; then
    info "备份目录: $BACKUP_DIR"
    echo "  回退命令: cp -a $BACKUP_DIR/.zshrc $HOME/ && cp -a $BACKUP_DIR/.dircolors $HOME/ && rm -rf $HOME/.zsh && cp -a $BACKUP_DIR/.zsh $HOME/"
fi

# ========================================
# 4. 复制文件到 HOME 目录
# ========================================
info "复制配置文件..."

# 复制 .zsh 插件目录
if [ -d "$HOME/.zsh" ]; then
    # 合并：只复制不存在的插件，更新已存在的
    for plugin_dir in "$SCRIPT_DIR/.zsh"/*; do
        plugin_name="$(basename "$plugin_dir")"
        if [ -d "$HOME/.zsh/$plugin_name" ]; then
            info "插件 $plugin_name 已存在，更新..."
            rm -rf "$HOME/.zsh/$plugin_name"
        fi
        cp -a "$plugin_dir" "$HOME/.zsh/"
    done
else
    cp -a "$SCRIPT_DIR/.zsh" "$HOME/.zsh"
fi

# 复制 .zshrc
cp -a "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

# 复制 .dircolors（如果存在）
if [ -f "$SCRIPT_DIR/.dircolors" ]; then
    cp -a "$SCRIPT_DIR/.dircolors" "$HOME/.dircolors"
fi

info "文件复制完成"

# ========================================
# 5. 修复权限 — 核心步骤，解决 compinit 和 SSH 问题
# ========================================
info "修复文件权限..."

# 修复 ~/.zsh 目录及子目录权限：确保不是 group/world writable
chmod -R go-w "$HOME/.zsh"

# 确保插件目录属主正确
chown -R "$(id -u):$(id -g)" "$HOME/.zsh" 2>/dev/null || true

# 修复 .zshrc 和 .dircolors 权限
chmod go-w "$HOME/.zshrc"
chown "$(id -u):$(id -g)" "$HOME/.zshrc" 2>/dev/null || true

if [ -f "$HOME/.dircolors" ]; then
    chmod go-w "$HOME/.dircolors"
    chown "$(id -u):$(id -g)" "$HOME/.dircolors" 2>/dev/null || true
fi

# 关键：修复 HOME 目录权限 — SSH 要求 home 目录不能 group/world writable
chmod go-w "$HOME"
chown "$(id -u):$(id -g)" "$HOME" 2>/dev/null || true

info "权限修复完成"

# ========================================
# 6. 检查并修复 SSH 目录权限
# ========================================
info "检查 SSH 目录权限..."

if [ -d "$HOME/.ssh" ]; then
    chmod 700 "$HOME/.ssh"
    chown "$(id -u):$(id -g)" "$HOME/.ssh" 2>/dev/null || true

    if [ -f "$HOME/.ssh/authorized_keys" ]; then
        chmod 600 "$HOME/.ssh/authorized_keys"
        chown "$(id -u):$(id -g)" "$HOME/.ssh/authorized_keys" 2>/dev/null || true
    fi

    # 其他 SSH 密钥文件也设为 600
    for keyfile in "$HOME/.ssh"/id_* "$HOME/.ssh"/config; do
        if [ -f "$keyfile" ]; then
            chmod 600 "$keyfile"
            chown "$(id -u):$(id -g)" "$keyfile" 2>/dev/null || true
        fi
    done

    info "SSH 目录权限已修复"
else
    warn "未找到 ~/.ssh 目录，跳过 SSH 权限检查"
fi

# ========================================
# 7. 清理 compinit 缓存（避免旧缓存导致的问题）
# ========================================
rm -f "$HOME/.zcompdump"*

# ========================================
# 8. 安全切换默认 Shell
# ========================================
CURRENT_SHELL="$(basename "$SHELL" 2>/dev/null || echo "unknown")"

if [ "$CURRENT_SHELL" = "zsh" ]; then
    info "当前 shell 已经是 zsh，无需切换"
else
    warn "当前 shell 是: $CURRENT_SHELL"
    echo ""
    echo "切换默认 shell 为 zsh 需要执行: chsh -s \$(which zsh)"
    echo ""
    echo "  *** 安全提示 ***"
    echo "  如果你已关闭 SSH 密码登录（仅使用密钥），请确保："
    echo "  1. 当前 SSH 连接不要断开"
    echo "  2. 先用新终端测试: ssh -p <port> user@host"
    echo "  3. 确认可以登录后再关闭当前连接"
    echo ""

    if [ -t 0 ]; then
        printf "是否现在切换默认 shell 为 zsh？[y/N] "
        read -r answer
        case "$answer" in
            [yY][eE][sS]|[yY])
                if chsh -s "$(command -v zsh)" 2>/dev/null; then
                    info "默认 shell 已切换为 zsh"
                    info "请保持当前 SSH 连接，用新终端测试登录后再关闭此连接！"
                else
                    error "chsh 失败，你可能需要: sudo chsh -s \$(which zsh) $USER"
                fi
                ;;
            *)
                info "跳过 shell 切换。稍后可手动执行: chsh -s \$(which zsh)"
                ;;
        esac
    else
        info "非交互模式，跳过 shell 切换。请手动执行: chsh -s \$(which zsh)"
    fi
fi

# ========================================
# 9. 最终权限验证
# ========================================
info "验证关键权限..."

HOME_PERM="$(stat -c '%a' "$HOME" 2>/dev/null || stat -f '%Lp' "$HOME" 2>/dev/null || echo "unknown")"
ZSH_PERM="$(stat -c '%a' "$HOME/.zsh" 2>/dev/null || stat -f '%Lp' "$HOME/.zsh" 2>/dev/null || echo "unknown")"

info "HOME 目录权限: $HOME_PERM (应为 7xx，不能 group/world writable)"
info "~/.zsh 目录权限: $ZSH_PERM"

if [ -d "$HOME/.ssh" ]; then
    SSH_PERM="$(stat -c '%a' "$HOME/.ssh" 2>/dev/null || stat -f '%Lp' "$HOME/.ssh" 2>/dev/null || echo "unknown")"
    info "~/.ssh 目录权限: $SSH_PERM (应为 700)"
fi

echo ""
info "======================================"
info "  安装完成！"
info "======================================"
echo ""
echo "  执行以下命令使配置生效："
echo "    source ~/.zshrc"
echo ""
echo "  或重启终端 / 重新登录 SSH"
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "  如需回退，执行："
    echo "    cp -a $BACKUP_DIR/.zshrc $HOME/"
    echo "    cp -a $BACKUP_DIR/.dircolors $HOME/"
    echo "    rm -rf $HOME/.zsh"
    echo "    cp -a $BACKUP_DIR/.zsh $HOME/"
    echo ""
fi
echo "  *** 重要安全提醒 ***"
echo "  如果你关闭了 SSH 密码登录，请务必："
echo "  1. 保持当前 SSH 连接不断开"
echo "  2. 另开一个终端测试 SSH 登录"
echo "  3. 确认成功后再关闭原连接"
