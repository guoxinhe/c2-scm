
# Copyright (C) 2007 C2 Microsystems

ifneq ($(CVS_TAG),)
CHECKOUT_OPTION         := -r $(CVS_TAG)
endif
CHECKOUT                := cvs -q co -AP $(CHECKOUT_OPTION)
UPDATE                  := cvs -q update -CAPd $(CHECKOUT_OPTION)

makefile_test:=echo "nothing todo"
CONFIG_SDK_CONFIGDEF=build.config
ifneq (,$(realpath $(CONFIG_SDK_CONFIGDEF)))
    CONFIG_SDK_CONFIGFILE=$(realpath $(CONFIG_SDK_CONFIGDEF))
    include $(CONFIG_SDK_CONFIGFILE)
endif

all: 
version:
	# Print out the compiler version used
	c2-linux-gcc -v


clean:
	@echo "BUILD_TARGET: clean"
	rm -rf $(PKG_DIR)
	rm -rf $(TEST_ROOT_DIR)
	rm -rf $(TOP_DIR)/test 
	rm -rf $(TEMP_DIR) 

CONFIG_SDK_RULESDEF=build.rules
ifneq (,$(realpath $(CONFIG_SDK_RULESDEF)))
     include $(realpath $(CONFIG_SDK_RULESDEF))
endif

mktest:
	@$(makefile_test)

FACUDISK_FILES := 	updating.bmp	updatefail.bmp	updatesucc.bmp	logo.bmp	\
			kernel.img	rootfs.img	home.img			\
			u-boot.rom	u-boot-factory.rom
ifeq ($(SDK_TARGET_ARCH),jazz2)
    uboot_file=$(uboot_utilities)/u-boot-jazz2-autodetect.rom
    uboot_factory_file=$(uboot_utilities)/u-boot-jazz2-factory-autodetect.rom
endif
ifeq ($(SDK_TARGET_ARCH),jazz2l)
    uboot_file=$(uboot_utilities)/u-boot-jazz2l-spiboot.rom
    uboot_factory_file=$(uboot_utilities)/u-boot-jazz2l-factory-spiboot.rom
endif
PKG_NAME_C2BOX_DEMO	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-c2box-bin.tar.gz
PKG_NAME_BIN_KERNEL_NAND:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kernel-nand-bin.tar.gz
PKG_NAME_BIN_HDMIKO     := $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-hdmi-bin.tar.gz
PKG_NAME_BIN_GFX_2D     := $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-bin.tar.gz
PKG_NAME_BIN_FACEN_UDISK:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-factory-udisk-en.tar.gz
PKG_NAME_BIN_FACCN_UDISK:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-factory-udisk-cn.tar.gz
PKG_NAME_BIN_USER_UDISK := $(PKG_DIR)/c2_update.tar
BIN_MKIMAGE  :=$(TEST_ROOT_DIR)/$(uboot_utilities)/mkimage
BIN_MKYAFFS2 :=$(TEST_ROOT_DIR)/sw/kernel/configs/jazz2-pvr-nand/mkyaffs/mkyaffs2
BIN_MKJFFS2  :=$(TOOLCHAIN_PATH)/mkfs.jffs2
BCHTOOLS     :=$(TEST_ROOT_DIR)/sw/kernel/configs/jazz2-pvr-nand/bch_generate
factory-udisk:
	#rm -rf $(TEST_ROOT_DIR)
	mkdir -p $(PKG_DIR)
	mkdir -p $(TEST_ROOT_DIR)
	rm -rf $(TEST_ROOT_DIR)/home $(TEST_ROOT_DIR)/work
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_UBOOT) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_KERNEL_NAND)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_C2BOX_DEMO) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_HDMIKO) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_GFX_2D) 
	cd $(TEST_ROOT_DIR) ; mkdir -p home; mv work home/
	cd $(TEST_ROOT_DIR) ; cp -f jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko home/work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/libGAL.so           home/work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/galcore.ko          home/work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/libdirectfb_gal.so  home/work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f home/work/updat*.bmp . ; cp -f home/work/logo.bmp .
	cd $(TEST_ROOT_DIR) ; cp -f sw/kernel/linux-2.6/zvmlinux.bin .
	cd $(TEST_ROOT_DIR) ; cp -f sw/kernel/rootfs.image .
	cd $(TEST_ROOT_DIR) ; $(BIN_MKIMAGE) -A c2 -O linux -T kernel -C none -a a0000000 -e 80000800 -n kernel -d zvmlinux.bin kernel.img
	cd $(TEST_ROOT_DIR) ; $(BIN_MKIMAGE) -A c2 -O linux -n rootfs -d rootfs.image rootfs.img
	cd $(TEST_ROOT_DIR) ; $(BIN_MKYAFFS2) home home.image ;
	cd $(TEST_ROOT_DIR) ; $(BIN_MKIMAGE) -A c2 -O linux -n home   -d home.image   home.img
	cd $(TEST_ROOT_DIR) ; cp -f $(uboot_file) u-boot.rom; cp -f $(uboot_factory_file) u-boot-factory.rom
	cd $(TEST_ROOT_DIR) ; cp -f updatingEN.bmp updating.bmp
	cd $(TEST_ROOT_DIR) ; cp -f updateFailEN.bmp updatefail.bmp
	cd $(TEST_ROOT_DIR) ; cp -f updateSuccEN.bmp updatesucc.bmp
	cd $(TEST_ROOT_DIR) ; rm  -rf $(PKG_NAME_BIN_FACEN_UDISK)
	cd $(TEST_ROOT_DIR) ; tar cfz $(PKG_NAME_BIN_FACEN_UDISK) $(FACUDISK_FILES)
	cd $(TEST_ROOT_DIR) ; cp -f updatingCH.bmp updating.bmp
	cd $(TEST_ROOT_DIR) ; cp -f updateFailCH.bmp updatefail.bmp
	cd $(TEST_ROOT_DIR) ; cp -f updateSuccCH.bmp updatesucc.bmp
	cd $(TEST_ROOT_DIR) ; rm  -rf $(PKG_NAME_BIN_FACCN_UDISK)
	cd $(TEST_ROOT_DIR) ; tar cfz $(PKG_NAME_BIN_FACCN_UDISK) $(FACUDISK_FILES)

CVS_SRC_SW_C2APPS       := sw_c2apps
user-udisk:
	#rm -rf $(TEST_ROOT_DIR)
	mkdir -p $(PKG_DIR)
	mkdir -p $(TEST_ROOT_DIR)
	cd $(TEST_ROOT_DIR) ; cp -rf $(SOURCE_DIR)/$(CVS_SRC_SW_C2APPS)/tools/updateFileGenerate/* .
	cd $(TEST_ROOT_DIR) ; make 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_KERNEL_NAND)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_C2BOX_DEMO) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_UBOOT) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_HDMIKO) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_GFX_2D) 
	cd $(TEST_ROOT_DIR) ; cp -f jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/libGAL.so           work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/galcore.ko          work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/libdirectfb_gal.so  work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f sw/kernel/linux-2.6/zvmlinux.bin .
	cd $(TEST_ROOT_DIR) ; cp -f sw/kernel/rootfs.image .
	cd $(TEST_ROOT_DIR) ; $(BIN_MKIMAGE) -A c2 -O linux -T kernel -C none -a a0000000 -e 80000800 -n kernel -d zvmlinux.bin uImage.bin
	cd $(TEST_ROOT_DIR) ; ./createArchive uImage.bin rootfs.image work -v "the version no."
	cd $(TEST_ROOT_DIR) ; cp -f c2_update.tar $(PKG_NAME_BIN_USER_UDISK)
#------------------------------------------------------------------------------
.NOTPARALLEL:
