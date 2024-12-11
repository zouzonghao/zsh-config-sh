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


# 切换到插件目录
cd ~/.zsh

# 克隆所需插件，如果目录不存在
clone_if_not_exists() {
    if [ ! -d "$1" ]; then
        echo "克隆 $1..."
        git clone "$2" "$1"
    else
        echo "$1 已存在."
    fi
}

clone_if_not_exists zsh-dircolors-solarized https://github.com/joel-porquet/zsh-dircolors-solarized.git
clone_if_not_exists zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
clone_if_not_exists zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
clone_if_not_exists zsh-completions https://github.com/zsh-users/zsh-completions.git
clone_if_not_exists zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git


# 创建/替换 .zshrc 文件
cat > ~/.zshrc << 'EOL'
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
bindkey '^[[Z' reverse-menu-complete  # Shift+Tab 向前选择
bindkey '^I' menu-complete            # Tab 向后选择

# 定义一个函数来计算并格式化时间
setopt PROMPT_SUBST
format_time_with_offset() {
  local current_time=$(date +%s)
  # 获取当前时间和增加0小时后的秒数
  local offset_seconds=$((current_time + 0 * 3600))
  
  # 使用 date -d 或 @ 来将秒数转换为可读的时间格式
  if date --version >/dev/null 2>&1; then
    # GNU date 支持 -d 和 @
    date -d "@$offset_seconds" +"%Y-%m-%d %H:%M:%S"
  else
    # macOS 或其他不支持 -d 的系统
    date -r $offset_seconds +"%Y-%m-%d %H:%M:%S"
  fi
}

# 设置 PS1
PS1='[$(format_time_with_offset)] %F{93}%~ %f> '

# 如果存在 .dircolors 文件，则使用它
# 检测操作系统
case "$(uname -s)" in
    Darwin)
        # macOS 环境
        if [ -f "$HOME/.dircolors" ]; then
            eval "$(gdircolors $HOME/.dircolors)"
        fi
        ;;
    Linux)
        # Linux 环境
        if [ -f "$HOME/.dircolors" ]; then
            eval "$(dircolors $HOME/.dircolors)"
        fi
        alias ls='ls --color=auto'
        ;;
    *)
        # 其他环境（如 FreeBSD, Windows 等）
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

#设置编码格式
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOL

cat > ~/.dircolors<< 'EOL'
# .dircolors file for macaron style with high contrast (for white terminal background)

# Default Colors (for unknown files)
DEFAULT 00;38;5;242   # Dark Gray text for normal files (good contrast on white background)

# Directories (bold and color)
DIR 38;5;203       # Mint Green (for directories)
DIRLNK 38;5;203      # Light Peach (for symlinked directories)

# Symbolic Links
LINK 38;5;75         # Teal for symlinks

# Executable Files
EXEC 38;5;119        # Light Cyan for executable files

# Image Files (JPEG, PNG, GIF, etc.)
IMG 38;5;214         # Warm Yellow for image files (JPEG, PNG, GIF, etc.)
.jpg 38;5;214        # JPEG
.jpeg 38;5;214       # JPEG
.png 38;5;214        # PNG
.gif 38;5;214        # GIF
.bmp 38;5;214        # BMP
.webp 38;5;214       # WEBP
.avif 38;5;214       # AVIF
.mjpg 38;5;214       # MJPEG
.mjpeg 38;5;214      # MJPEG
.pbm 38;5;214        # PBM
.pgm 38;5;214        # PGM
.ppm 38;5;214        # PPM
.tga 38;5;214        # TGA
.xbm 38;5;214        # XBM
.xpm 38;5;214        # XPM
.tif 38;5;214        # TIFF
.tiff 38;5;214       # TIFF
.svg 38;5;214        # SVG
.svgz 38;5;214       # SVGZ
.mng 38;5;214        # MNG
.pcx 38;5;214        # PCX
.mov 38;5;214        # MOV
.mpg 38;5;214        # MPG
.mpeg 38;5;214       # MPEG
.m2v 38;5;214        # M2V
.mkv 38;5;214        # MKV
.webm 38;5;214       # WEBM
.webp 38;5;214       # WEBP
.ogm 38;5;214        # OGM
.mp4 38;5;214        # MP4
.m4v 38;5;214        # M4V
.mp4v 38;5;214       # MP4V
.vob 38;5;214        # VOB
.qt 38;5;214         # QT
.nuv 38;5;214        # NUV
.wmv 38;5;214        # WMV
.asf 38;5;214        # ASF
.rm 38;5;214         # RM
.rmvb 38;5;214       # RMVB
.flc 38;5;214        # FLC
.avi 38;5;214        # AVI
.fli 38;5;214        # FLI
.flv 38;5;214        # FLV
.gl 38;5;214         # GL
.dl 38;5;214         # DL
.xcf 38;5;214        # XCF
.xwd 38;5;214        # XWD
.yuv 38;5;214        # YUV
.cgm 38;5;214        # CGM
.emf 38;5;214        # EMF
.ogv 38;5;214        # OGV
.ogx 38;5;214        # OGX

# Video Files (MP4, MKV, etc.)
VID 38;5;129         # Coral color for video files
.mp4 38;5;129        # MP4
.mkv 38;5;129        # MKV
.avi 38;5;129        # AVI
.mov 38;5;129        # MOV
.webm 38;5;129       # WEBM

# Audio Files (MP3, WAV, FLAC, etc.)
AUD 38;5;51          # Soft Blue for audio files
.mp3 38;5;51         # MP3
.wav 38;5;51         # WAV
.flac 38;5;51        # FLAC
.ogg 38;5;51         # OGG
.m4a 38;5;51         # M4A
.aac 38;5;51         # AAC
.au 38;5;51         # AU
.mid 38;5;51         # MIDI
.midi 38;5;51       # MIDI
.mka 38;5;51        # MKA
.mpc 38;5;51        # MPC
.ra 38;5;51         # RA
.oga 38;5;51        # OGA
.opus 38;5;51       # OPUS
.spx 38;5;51        # SPX
.xspf 38;5;51       # XSPF

# Text Files (TXT, MARKDOWN, etc.)
TXT 38;5;123         # Soft Pink for text files
.txt 38;5;123        # TXT
.md 38;5;123         # Markdown
.rst 38;5;123        # reStructuredText

# Code Files (JavaScript, Python, C++, etc.)
CODE 38;5;81         # Light Purple for code files
.js 38;5;81          # JavaScript
.jsx 38;5;81         # JSX (JavaScript XML)
.ts 38;5;81          # TypeScript
.tsx 38;5;81         # TypeScript (TSX)
.py 38;5;81          # Python
.java 38;5;81        # Java
.cpp 38;5;81         # C++
.hpp 38;5;81         # C++ Header
.c 38;5;81           # C
.h 38;5;81           # C Header
.rb 38;5;81          # Ruby
.go 38;5;81          # Go
.php 38;5;81         # PHP
.swift 38;5;81       # Swift
.rs 38;5;81          # Rust
.sh 38;5;45          # Shell scripts (e.g., Bash)
.bat 38;5;45 

# HTML/CSS Files
WEB 38;5;213         # Pastel Pink for web files
.html 38;5;213       # HTML
.htm 38;5;213        # HTM
.css 38;5;213        # CSS
.scss 38;5;213       # SCSS (Sassy CSS)
.less 38;5;213       # LESS (CSS preprocessor)

# YAML, JSON, TOML, INI, XML Files
CONFIG 38;5;78       # Light Green for configuration files
.yml 38;5;78         # YAML
.yaml 38;5;78        # YAML
.json 38;5;78        # JSON
.toml 38;5;78        # TOML
.ini 38;5;78         # INI
.xml 38;5;78         # XML

# LaTeX Files
LATEX 38;5;87        # Light Blue for LaTeX files
.tex 38;5;87         # TeX

# PDF Files
PDF 38;5;141         # Mint Green for PDF files
.pdf 38;5;141        # PDF

# Word Files (DOC, DOCX)
WORD 38;5;133        # Light Green for Word files
.doc 38;5;133        # DOC
.docx 38;5;133       # DOCX

# Spreadsheet Files (XLS, XLSX)
SPREADSHEET 38;5;220 # Warm Yellow for Spreadsheet files
.xls 38;5;220        # XLS
.xlsx 38;5;220       # XLSX

# Presentation Files (PPT, PPTX)
PRESENTATION 38;5;213 # Soft Pink for Presentation files
.ppt 38;5;213        # PPT
.pptx 38;5;213       # PPTX

# Archive Files (ZIP, TAR, GZ, etc.)
ARCHIVE 38;5;45      # Peach for compressed/archived files
.7z 38;5;45          # 7Z
.ace 38;5;45         # ACE
.alz 38;5;45         # ALZ
.apk 38;5;45         # APK
.arc 38;5;45         # ARC
.arj 38;5;45         # ARJ
.bz 38;5;45          # BZ
.bz2 38;5;45         # BZ2
.cab 38;5;45         # CAB
.cpio 38;5;45        # CPIO
.crate 38;5;45       # CRATE
.deb 38;5;45         # DEB
.drpm 38;5;45        # DRPM
.dwm 38;5;45         # DWM
.dz 38;5;45          # DZ
.ear 38;5;45         # EAR
.egg 38;5;45         # EGG
.esd 38;5;45         # ESD
.gz 38;5;45          # GZ
.jar 38;5;45         # JAR
.lha 38;5;45         # LHA
.lrz 38;5;45         # LRZ
.lz 38;5;45          # LZ
.lz4 38;5;45         # LZ4
.lzh 38;5;45         # LZH
.lzma 38;5;45        # LZMA
.lzo 38;5;45         # LZO
.pyz 38;5;45         # PYZ
.rar 38;5;45         # RAR
.rpm 38;5;45         # RPM
.rz 38;5;45          # RZ
.sar 38;5;45         # SAR
.swm 38;5;45         # SWM
.t7z 38;5;45         # T7Z
.tar 38;5;45         # TAR
.taz 38;5;45         # TAZ
.tbz 38;5;45         # TBZ
.tbz2 38;5;45        # TBZ2
.tgz 38;5;45         # TGZ
.tlz 38;5;45         # TLZ
.txz 38;5;45         # TXZ
.tz 38;5;45          # TZ
.tzo 38;5;45         # TZO
.tzst 38;5;45        # TZST
.udeb 38;5;45        # UDEB
.war 38;5;45         # WAR
.whl 38;5;45         # WHL
.wim 38;5;45         # WIM
.xz 38;5;45          # XZ
.z 38;5;45           # Z
.zip 38;5;45         # ZIP
.zoo 38;5;45         # ZOO
.zst 38;5;45         # ZST

# Backup Files (files ending in ~ or #)
BACKUP 38;5;238      # Dark Gray for backup files
*~ 38;5;238          # Backup files (ending in ~)
*# 38;5;238          # Backup files (ending in #)
.bak 38;5;238        # BAK
.crdownload 38;5;238 # CRDOWNLOAD
.dpkg-dist 38;5;238  # DPKG-DIST
.dpkg-new 38;5;238   # DPKG-NEW
.dpkg-old 38;5;238   # DPKG-OLD
.dpkg-tmp 38;5;238   # DPKG-TMP
.old 38;5;238        # OLD
.orig 38;5;238       # ORIG
.part 38;5;238       # PART
.rej 38;5;238        # REJ
.rpmnew 38;5;238     # RPMNEW
.rpmorig 38;5;238    # RPMORIG
.rpmsave 38;5;238    # RPMSAVE
.swp 38;5;238        # SWP
.tmp 38;5;238        # TMP
.ucf-dist 38;5;238   # UCF-DIST
.ucf-new 38;5;238    # UCF-NEW
.ucf-old 38;5;238    # UCF-OLD

# Temporary Files (files starting with .)
TEMP 38;5;240        # Dark Gray for temporary files
.* 38;5;240          # Hidden files (files starting with .)

# Git Ignore Files
GITIGNORE 38;5;57    # Light Green for .gitignore
.gitignore 38;5;57   # .gitignore

# Docker Files (Dockerfile, docker-compose.yml)
DOCKER 38;5;58       # Light Red for Docker-related files
Dockerfile 38;5;58   # Dockerfile
docker-compose.yml 38;5;58  # docker-compose.yml

# Environment Variables Files
ENV 38;5;240        # Dark Gray for environment variables files
.env 38;5;240       # .env

# Shell Configuration Files (bashrc, zshrc, etc.)
SHELL 38;5;240      # Dark Gray for shell config files
.bashrc 38;5;240    # bashrc
.zshrc 38;5;240     # zshrc
.profile 38;5;240   # profile

# Other Files
OTHER 38;5;251      # Light Gray for miscellaneous files

EOL

echo "配置完成，请重启终端。"
