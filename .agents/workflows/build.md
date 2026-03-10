---
description: 修改优化固件并重新编译
---

# 修改优化固件并重新编译

## 文件说明

| 文件 | 作用 |
|------|------|
| `Config/GENERAL.txt` | 插件开关（启用/禁用插件） |
| `Scripts/Packages.sh` | 第三方插件源码（从 GitHub 拉取） |
| `Scripts/Settings.sh` | 系统设置（DPI/NSS 等高级配置） |
| `.github/workflows/NN6000V2.yml` | 默认 IP、WiFi、主题等 |

## 操作步骤

// turbo-all

### 1. 拉取远程最新代码

```bash
cd /Users/its/Desktop/op && git pull origin main
```

### 2. 修改文件

按需修改上面列出的文件。常见示例：

**添加插件** — 在 `Scripts/Packages.sh` 加一行：
```bash
UPDATE_PACKAGE "插件名" "GitHub用户/仓库" "分支"
```
然后在 `Config/GENERAL.txt` 加一行：
```
CONFIG_PACKAGE_luci-app-插件名=y
```

**删除插件** — 注释掉或删掉对应行，或改 `=y` 为 `=n`

**改默认 IP** — 编辑 `.github/workflows/NN6000V2.yml` 中的 `WRT_IP`

**改 WiFi** — 编辑同文件中的 `WRT_SSID` 和 `WRT_WORD`

### 3. 提交并推送

```bash
cd /Users/its/Desktop/op && git add -A && git commit -m "修改说明" && git push origin main
```

### 4. 触发编译

打开 https://github.com/itsme6688/ImmortalWrt-NN6000V2/actions
点击左侧 **NN6000V2** → 右侧 **Run workflow** → **Run workflow**

### 5. 下载固件

等 2-3 小时编译完成后，到 https://github.com/itsme6688/ImmortalWrt-NN6000V2/releases
下载带 `link_nn6000-v2` 的固件文件，通过 U-Boot 刷入。
