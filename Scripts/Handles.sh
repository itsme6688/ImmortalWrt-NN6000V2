#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	echo " "

	HP_RULE="surge"
	HP_PATH="homeproxy/root/etc/homeproxy"

	rm -rf ./$HP_PATH/resources/*

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULE/
	cd ./$HP_RULE/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATH/resources/

	cd .. && rm -rf ./$HP_RULE/

	cd $PKG_PATH && echo "homeproxy date has been updated!"
fi

#修改argon主题字体和颜色
if [ -d *"luci-theme-argon"* ]; then
	echo " "

	cd ./luci-theme-argon/

	sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" ./luci-app-argon-config/root/etc/config/argon

	cd $PKG_PATH && echo "theme-argon has been fixed!"
fi

#修改aurora菜单式样
if [ -d *"luci-app-aurora-config"* ]; then
	echo " "

	cd ./luci-app-aurora-config/

	sed -i "s/nav_submenu_type '.*'/nav_submenu_type 'boxed-dropdown'/g" $(find ./root/ -type f -name "*aurora")

	cd $PKG_PATH && echo "theme-aurora has been fixed!"
fi

#修改qca-nss-drv启动顺序
NSS_DRV="../feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
if [ -f "$NSS_DRV" ]; then
	echo " "

	sed -i 's/START=.*/START=85/g' $NSS_DRV

	cd $PKG_PATH && echo "qca-nss-drv has been fixed!"
fi

#修改qca-nss-pbuf启动顺序
NSS_PBUF="./kernel/mac80211/files/qca-nss-pbuf.init"
if [ -f "$NSS_PBUF" ]; then
	echo " "

	sed -i 's/START=.*/START=86/g' $NSS_PBUF

	cd $PKG_PATH && echo "qca-nss-pbuf has been fixed!"
fi

#修复TailScale配置文件冲突
TS_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/tailscale/Makefile")
if [ -f "$TS_FILE" ]; then
	echo " "

	sed -i '/\/files/d' $TS_FILE

	cd $PKG_PATH && echo "tailscale has been fixed!"
fi

#修复Rust编译失败
RUST_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' $RUST_FILE

	cd $PKG_PATH && echo "rust has been fixed!"
fi

#修复DiskMan编译失败
DM_FILE="./luci-app-diskman/applications/luci-app-diskman/Makefile"
if [ -f "$DM_FILE" ]; then
	echo " "

	sed -i '/ntfs-3g-utils /d' $DM_FILE

	cd $PKG_PATH && echo "diskman has been fixed!"
fi

#修复luci-app-netspeedtest相关问题
if [ -d *"luci-app-netspeedtest"* ]; then
	echo " "

	cd ./luci-app-netspeedtest/

	sed -i '$a\exit 0' ./netspeedtest/files/99_netspeedtest.defaults
	sed -i 's/ca-certificates/ca-bundle/g' ./speedtest-cli/Makefile

	cd $PKG_PATH && echo "netspeedtest has been fixed!"
fi

#优化LuCI页面加载速度 + 修复Netdata HTTPS显示
DEFAULTS_DIR="$GITHUB_WORKSPACE/wrt/package/base-files/files/etc/uci-defaults"
mkdir -p "$DEFAULTS_DIR"
cat > "$DEFAULTS_DIR/99-luci-performance" << 'PERFEOF'
#!/bin/sh

# === uwsgi 优化：解决 LuCI 页面加载慢（TTFB 10s+）的问题 ===
UWSGI_EMPEROR="/etc/uwsgi/emperor.ini"
UWSGI_VASSAL="/etc/uwsgi/vassals/luci-webui.ini"

if [ -f "$UWSGI_EMPEROR" ]; then
	sed -i 's/^vassal-set = die-on-idle=true/; vassal-set = die-on-idle=true/' "$UWSGI_EMPEROR"
fi

if [ -f "$UWSGI_VASSAL" ]; then
	sed -i 's/^cheap = true/; cheap = true/' "$UWSGI_VASSAL"
	sed -i 's/^processes = 3/processes = 4/' "$UWSGI_VASSAL"
	sed -i 's/^cheaper = 1/cheaper = 2/' "$UWSGI_VASSAL"
	sed -i 's/^cheaper-initial = 1/cheaper-initial = 2/' "$UWSGI_VASSAL"
	sed -i 's/^idle = 360/idle = 7200/' "$UWSGI_VASSAL"
	grep -q 'ignore-sigpipe' "$UWSGI_VASSAL" || \
		sed -i '/^thunder-lock/a ignore-sigpipe = true\nignore-write-errors = true' "$UWSGI_VASSAL"
fi

# === Nginx 优化：静态资源缓存 + Netdata 反代 + ubus 并发 ===
LUCI_LOC="/etc/nginx/conf.d/luci.locations"
if [ -f "$LUCI_LOC" ]; then
	# 静态资源缓存 7 天
	if ! grep -q 'expires 7d' "$LUCI_LOC"; then
		sed -i '/location \/luci-static/,/}/ {
			/error_log/a\		expires 7d;\n\t\tadd_header Cache-Control "public, immutable";
		}' "$LUCI_LOC"
	fi
	# ubus 并发 2 -> 6
	sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/' "$LUCI_LOC"
	# Netdata 反向代理（解决 HTTPS 页面嵌入 HTTP iframe 被拦截的问题）
	if ! grep -q '/netdata/' "$LUCI_LOC"; then
		cat >> "$LUCI_LOC" << 'NDEOF'

location /netdata/ {
        proxy_pass http://127.0.0.1:19999/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_buffering off;
}
NDEOF
	fi
fi

# === 修复 Netdata LuCI 视图：iframe 改用反代相对路径 ===
ND_JS="/www/luci-static/resources/view/netdata.js"
if [ -f "$ND_JS" ]; then
	sed -i "s|'http://'+window.location.hostname+':19999'|'/netdata/'|" "$ND_JS"
fi

exit 0
PERFEOF
chmod +x "$DEFAULTS_DIR/99-luci-performance"

cd $PKG_PATH && echo "luci-performance optimization has been added!"