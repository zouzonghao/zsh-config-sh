## zsh-config-sh
zsh 配置脚本

## 修改时间偏移

修改 ` ~/.zshrc ` 文件中的

```
  # 获取当前时间和增加0小时后的秒数
  local offset_seconds=$((current_time + 0 * 3600))
```

将 `0` 改为 `8` ，即可从 UTC时区 转成 CST时区（北京时间）

## 修改终端文件颜色

修改 ` ~/.dircolors ` 文件

```
# .dircolors 文件节选如下

DIR 38;5;24
.jpg 38;5;214  
```
其中：
- DIR、.jpg 指的是文件格式
- 38;5 指的是要配置的颜色是前景色
- 24、214 指的颜色的代码

通过命令 `echo -e $(printf '\e[38;5;%dm%3d ' {0..255})`，可在终端中预览颜色代码对应的颜色
  
# Zsh Config Release

自动打包的 Zsh 配置文件，包含常用插件和配置。

## 包含内容

- zsh-dircolors-solarized
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-completions
- zsh-history-substring-search

## 快速安装（推荐）

### 方式一：从 GitHub Release 下载安装

```bash
# 1. 安装 zsh
apt install zsh    # Debian/Ubuntu
# 或 apk add zsh   # Alpine

# 2. 下载最新版本
VERSION=v1.0.0
wget https://github.com/YOUR_USERNAME/zsh-config/releases/download/${VERSION}/zsh-config-${VERSION}.tar.gz

# 3. 解压到临时目录（不要直接解压到 ~/ ，避免影响 home 目录权限）
mkdir -p /tmp/zsh-config
tar -xzf zsh-config-${VERSION}.tar.gz -C /tmp/zsh-config

# 4. 运行安装脚本
/tmp/zsh-config/install.sh

# 5. 使配置生效
source ~/.zshrc
```

### 方式二：使用 zsh-setup.sh 脚本（在线克隆插件）

```bash
# 克隆仓库并运行
git clone https://github.com/YOUR_USERNAME/zsh-config.git
cd zsh-config
bash zsh-setup.sh
```

### 校验

```bash
sha256sum -c zsh-config-${VERSION}.tar.gz.sha256
```

---

## 安全说明

本项目的安装脚本已包含以下安全保护：

1. **自动修复文件权限** — 确保 `~/.zsh` 目录及子目录不是 group/world writable，避免 `compinit` 报 insecure directories 错误
2. **保护 HOME 目录权限** — 确保 `~/` 不是 group/world writable，避免 SSH 密钥认证失败
3. **修复 SSH 目录权限** — 自动设置 `~/.ssh` 为 700，`~/.ssh/authorized_keys` 为 600
4. **备份旧配置** — 安装前自动备份现有 `.zshrc`、`.dircolors`、`.zsh`
5. **安全 shell 切换** — 使用 `chsh` 而非危险的 `sed` 替换 `/etc/passwd`

### ⚠️ 如果你已关闭 SSH 密码登录

请务必遵循以下步骤：
1. **保持当前 SSH 连接不要断开**
2. 另开一个终端测试 SSH 密钥登录
3. 确认成功后再关闭原连接

---

## 文件清单

| 文件路径 | 说明 |
|---------|------|
| `.github/workflows/release-zsh-config.yml` | GitHub Actions 工作流 |
| `configs/.zshrc` | Zsh 主配置文件 |
| `configs/.dircolors` | 目录颜色配置 |
| `configs/install.sh` | 安全安装脚本 |
| `zsh-setup.sh` | 在线安装脚本（克隆插件） |
| `README.md` | 说明文档 |
