# Makefile for Xray-core v1.8.23
#
# 这个文件将被用来覆盖 Padavan 源码中的原始 xray Makefile，
# 以便编译指定的新版本。

# 定义 Xray 的版本和下载地址
XRAY_VERSION := 1.8.23
XRAY_URL := https://codeload.github.com/XTLS/Xray-core/tar.gz/v$(XRAY_VERSION)

# 定义源码解压后的目录结构
XRAY_EXTRACT_DIR = Xray-core-$(XRAY_VERSION)
XRAY_BUILD_DIR = xray-core/$(XRAY_EXTRACT_DIR)/main

# 获取当前 Makefile 所在的绝对路径
THISDIR = $(shell pwd)

# 默认目标，执行所有步骤
all: download build_extract build

# 下载源码包
download:
	( if [ ! -f $(THISDIR)/Xray-core-$(XRAY_VERSION).tar.gz ]; then \
	curl --create-dirs -L $(XRAY_URL) -o $(THISDIR)/Xray-core-$(XRAY_VERSION).tar.gz ; \
	fi )

# 创建目录并解压源码
build_extract:
	mkdir -p $(THISDIR)/xray-core
	mkdir -p $(THISDIR)/bin
	( if [ ! -d $(THISDIR)/xray-core/$(XRAY_EXTRACT_DIR) ]; then \
	rm -rf $(THISDIR)/xray-core/* ; \
	tar zxf $(THISDIR)/Xray-core-$(XRAY_VERSION).tar.gz -C $(THISDIR)/xray-core ; \
	fi )

# 编译 Xray
build:
	( \
	echo "Patching go.mod to use go 1.23..."; \
	sed -i "s/go 1.22/go 1.23.0/g" $(THISDIR)/xray-core/$(XRAY_EXTRACT_DIR)/go.mod; \
	echo "Starting build process..."; \
	cd $(THISDIR)/$(XRAY_BUILD_DIR); \
	GOOS=linux GOARCH=mipsle GOMIPS=softfloat go build -gcflags=all="-l" -ldflags "-w -s -buildid=" -trimpath -o $(THISDIR)/bin/xray; \
	)

# 清理生成的文件
clean:
	rm -rf $(THISDIR)/xray-core
	rm -rf $(THISDIR)/bin

# 将编译好的文件安装到固件的 romfs 中
romfs:
	$(ROMFSINST) -p +x $(THISDIR)/bin/xray /usr/bin/xray
