## zsh-config-sh
zsh 配置脚本

## 修改时间偏移

修改 ` ./zshrc ` 文件中的

```
  # 获取当前时间和增加0小时后的秒数
  local offset_seconds=$((current_time + 0 * 3600))
```

将 `0` 改为 `8` ，即可从 UTC时区 转成 CST时区（北京时间）

## 修改终端文件颜色

修改 ` .dircolors ` 文件

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

## 快速安装

```bash
# 下载最新版本
VERSION=v1.0.0
wget https://github.com/YOUR_USERNAME/zsh-config/releases/download/${VERSION}/zsh-config-${VERSION}.tar.gz

# 解压到 home 目录
tar -xzf zsh-config-${VERSION}.tar.gz -C ~/

# 运行安装脚本
~/install.sh

# 重启 zsh
exec zsh
```

## 校验

```bash
sha256sum -c zsh-config-${VERSION}.tar.gz.sha256
```
```

---

## 🚀 使用步骤

### 步骤 1: 创建仓库

```bash
mkdir zsh-config
cd zsh-config
git init
```

### 步骤 2: 创建目录和文件

```bash
mkdir -p .github/workflows configs
```

然后将上面 5 个文件的内容分别保存到对应路径。

### 步骤 3: 提交并推送

```bash
git add .
git commit -m "Initial zsh config"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/zsh-config.git
git push -u origin main
```

### 步骤 4: 触发发布

```bash
# 方式1: 打标签
git tag v1.0.0
git push origin v1.0.0

# 方式2: GitHub 页面手动触发
# Actions → Release Zsh Config → Run workflow
```

### 步骤 5: 下载和使用

```bash
# 从 Releases 下载
wget https://github.com/YOUR_USERNAME/zsh-config/releases/download/v1.0.0/zsh-config-v1.0.0.tar.gz

# 解压
tar -xzf zsh-config-v1.0.0.tar.gz -C ~/

# 安装
~/install.sh

# 生效
exec zsh
```

---

## 📋 文件清单总结

| 文件路径 | 说明 |
|---------|------|
| `.github/workflows/release-zsh-config.yml` | GitHub Actions 工作流 |
| `configs/.zshrc` | Zsh 主配置文件 |
| `configs/.dircolors` | 目录颜色配置 |
| `configs/install.sh` | 安装脚本 |
| `README.md` | 说明文档 |