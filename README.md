# NN6000V2 定制固件

基于 [ImmortalWrt](https://github.com/guorong697/immortalwrt) 编译的**连我科技 NN6000 V2** 定制固件，全系 NSS 硬件加速。

## 📥 下载固件

到 [Releases](https://github.com/itsme6688/ImmortalWrt-NN6000V2/releases) 下载最新固件，选择 `factory` 版本通过 U-Boot 刷入。

## 📋 固件信息

| 项目 | 值 |
|------|-----|
| 平台 | Qualcomm IPQ6000 (qualcommax/ipq60xx) |
| 登录地址 | `192.168.10.1` |
| 登录密码 | 无（空密码） |
| WiFi 名称 | `OWRT` |
| WiFi 密码 | `12345678` |
| 内核版本 | 6.12.x |

## 🔌 插件列表

### 科学上网
- **OpenClash** — Clash 规则分流代理
- **Passwall / Passwall2** — 多协议代理

### 安全过滤
- **OpenAppFilter (OAF)** — DPI 深度包检测 + 应用过滤

### 组网
- Tailscale / ZeroTier / EasyTier / EasyMesh / VNT

### 文件下载
- Samba4 / FileBrowser / QuickFile / qBittorrent

### 监控工具
- Netdata / ttyd / NetSpeedTest / CoreMark

### 系统管理
- AutoReboot / 分区扩容 / DiskMan / FanControl / WOL Plus

### 固件内置优化
- **LuCI 加载加速** — uwsgi 常驻进程 + 静态资源缓存 + ubus 并发提升（TTFB 10s → 0.1s）
- **Netdata 显示修复** — Nginx 反代解决 HTTPS 下 iframe 混合内容拦截

### 网络功能
- DDNS-Go / UPnP / IPTV Helper / MosDNS

### 硬件加速
- **NSS 硬件加速** + SQM-NSS 智能队列

### 主题
- Argon（默认）/ Aurora / Kucat

## 🔧 自定义编译

1. Fork 本仓库
2. 修改 `Config/GENERAL.txt`（插件开关）和 `Scripts/Packages.sh`（第三方插件源）
3. 到 Actions → NN6000V2 → Run workflow 触发编译
4. 编译完成后到 Releases 下载固件

## 🙏 致谢

- [guorong697/ImmortalWrt-NN6000V2](https://github.com/guorong697/ImmortalWrt-NN6000V2) — 原始仓库
- [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt) — 高通版 ImmortalWrt
- [vernesong/OpenClash](https://github.com/vernesong/OpenClash) — OpenClash
- [destan19/OpenAppFilter](https://github.com/destan19/OpenAppFilter) — 应用过滤
