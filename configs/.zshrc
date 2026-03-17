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
compinit

# 设置按键绑定
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete
bindkey '^I' menu-complete

# 定义一个函数来计算并格式化时间
setopt PROMPT_SUBST
format_time_with_offset() {
  local current_time=$(date +%s)
  local offset_seconds=$((current_time + 0 * 3600))
  
  if date --version >/dev/null 2>&1; then
    date -d "@$offset_seconds" +"%H:%M:%S"
  else
    date -r $offset_seconds +"%H:%M:%S"
  fi
}

# 设置 PS1
PS1='[$(format_time_with_offset)]%F{209} %F{93}%~ %f> '

# 如果存在 .dircolors 文件，则使用它
# 检测操作系统
case "$(uname -s)" in
    Darwin)
        if [ -f "$HOME/.dircolors" ]; then
            eval "$(gdircolors $HOME/.dircolors)"
        fi
        ;;
    Linux)
        if [ -f "$HOME/.dircolors" ]; then
            eval "$(dircolors $HOME/.dircolors)"
        fi
        alias ls='ls --color=auto'
        ;;
    *)
        echo "不支持自定义颜色 —— Unsupported OS: $(uname -s)"
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