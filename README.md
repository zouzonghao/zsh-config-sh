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
  
