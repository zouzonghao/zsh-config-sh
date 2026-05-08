# 设置历史记录
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# 加载插件
source ~/.zsh/zsh-dircolors-solarized/zsh-dircolors-solarized.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# 添加 zsh-completions 到 fpath
fpath=(~/.zsh/zsh-completions/src $fpath)

# 补全设置
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' complete-all true
zstyle ':completion:*' accept-exact true
zstyle ':completion:*' verbose true
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# 启用自动补全
autoload -Uz compinit
# -u: 忽略不安全目录检查（避免交互式提示阻塞 SSH 登录）
# -C: 跳过补全函数变更检查，直接使用缓存（大幅加速启动）
# 如果缓存不存在会自动创建，后续启动无需重新扫描所有补全函数
compinit -u -C

# 设置按键绑定
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete
bindkey '^I' menu-complete

# 设置 PS1 — 使用 zsh 内置时间格式，零 fork 开销
# %D{%H:%M:%S} 是 zsh 内置 prompt escape，不需要调用外部 date 命令
# 如果需要时区偏移，修改 offset_hours 变量（例如 +8 为北京时间）
setopt PROMPT_SUBST
zsh_config_offset_hours=0
PS1='[%D{%H:%M:%S}]%F{209} %F{93}%~ %f> '

# 如果存在 .dircolors 文件，则使用它
case "$(uname -s)" in
    Darwin)
        # macOS 环境
        if [ -f "$HOME/.dircolors" ]; then
            eval "$(gdircolors $HOME/.dircolors 2>/dev/null)"
        fi
        ;;
    Linux)
        # Linux 环境
        if [ -f "$HOME/.dircolors" ]; then
            if command -v gdircolors &> /dev/null; then
                eval "$(gdircolors $HOME/.dircolors)"
            else
                eval "$(dircolors $HOME/.dircolors)"
            fi
        fi
        ;;
esac

# 设置基本别名
if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='gls --color=auto'
else
    alias ls='ls --color=auto'
fi
alias ll='ls -lah'
alias grep='grep --color=auto'

# 启用命令行编辑
bindkey -e

# 补全相关选项
setopt AUTO_LIST
setopt AUTO_MENU
setopt MENU_COMPLETE

# 设置编码格式
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
