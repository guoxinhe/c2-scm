
# hard-coded config file for Makefile
# hope variables are in 2 levels,
# level 1: has immediate value
# level 2: direct get value from level, does not get from another level 2
# make scence settings
TODAY                   	:= $(shell date +%y%m%d)
#TODAY                   	:= 110330
TOP_DIR				?= $(shell /bin/pwd)
SDK_KERNEL_VERSION		:= 2.6.23
SDK_GCC_VERSION			:= 4.0.3
SDK_QT_VERSION			:= 4.7.0
SDK_TARGET_ARCH			:= jazz2
SDK_TARGET_GCC_ARCH		:= TANGO
LINUXDIR                	:= linux-2.6
LINUX_CONFIG			:= c2_jazz2_smp_defconfig
QTINSTALL_NAME                  := QtopiaCore-4.7.0-generic
GNU_TARBALL_PATH        	:= /home/saladwang/gnu
MAJOR                   	:= 0
MINOR                   	:= 1
BRANCH				:= 1
BUILDTIMES              	:= 1
VERSION				:= $(MAJOR).$(MINOR)
CANDIDATE			:= $(BRANCH)-$(BUILDTIMES)
#CVS_TAG			:= $(SDK_TARGET_ARCH)-SDK-$(MAJOR)_$(MINOR)-$(BRANCH)-$(BUILDTIMES)
#SDK_VERSION_ALL		:= $(SDK_TARGET_ARCH)-sdk-$(MAJOR).$(MINOR)-$(BRANCH)-$(BUILDTIMES)
CVS_TAG				:=
CHECKOUT_OPTION         	:= 
PRODUCT				:= $(SDK_TARGET_ARCH)-sdk
SDK_VERSION_ALL			:= $(SDK_TARGET_ARCH)-sdk-$(TODAY)
DEVTOOLS_AUTOBUILD_CONFIG 	:= autobuild_config_$(SDK_TARGET_ARCH)
TEST_ROOT_DIR			:= $(TOP_DIR)/test_root
SOURCE_DIR			:= $(TOP_DIR)/source
SOURCE_GITDIR			:= $(TOP_DIR)/c2sdk_source
SOURCE_LOCAL			:= $(TOP_DIR)/source_local
TEMP_DIR			:= $(TOP_DIR)/temp
PKG_DIR				:= $(TOP_DIR)/$(SDK_VERSION_ALL)
TAR_EXCLUDEFLAGS		:= --exclude=CVS --exclude=CVSROOT --exclude=.git --exclude=.repo

CONFIG_BRANCH_ANDROID 		:= devel
CONFIG_BRANCH_C2SDK 		:= master

ifneq ($(CVS_TAG),)
CHECKOUT_OPTION         := -r $(CVS_TAG)
endif
#CHECKOUT                := cvs -q co -AP $(CHECKOUT_OPTION)
#UPDATE                  := cvs -q update -CAPd $(CHECKOUT_OPTION)
CHECKOUT                := echo "cvs -q co -AP $(CHECKOUT_OPTION)"
UPDATE                  := echo "cvs -q update -CAPd $(CHECKOUT_OPTION)"

# build installation configures
#TOOLCHAIN_PATH			:= $(TEST_ROOT_DIR)/c2/daily/bin
TOOLCHAIN_PATH			:= $(shell readlink -f $(TOP_DIR)/c2/daily/bin)
SW_MEDIA_PATH                   := $(TEST_ROOT_DIR)/sw_media_installed
SW_MEDIA_INSTALL_DIR		:= TARGET_LINUX_C2_TANGO_RELEASE
QT_INSTALL_DIR                  := $(TEST_ROOT_DIR)/$(QTINSTALL_NAME)
INSTALL_DIR			:= /usr/local/c2/releases/sdk/$(SDK_VERSION_ALL)
PUBLISH_DIR			:= /home/$(USER)/public_html/sdk-releases/$(SDK_VERSION_ALL)
CVS_SRC_KERNEL			:= kernel.sdk
#KERNEL_PATH			:= $(TEST_ROOT_DIR)/prebuilt/$(CVS_SRC_KERNEL)/$(LINUXDIR)
KERNEL_PATH			:= $(TEST_ROOT_DIR)/build_kernelsd/kernel.sdk/linux-2.6
#KERNEL_PATH			:= $(TEST_ROOT_DIR)/build_kernela2632/kernel

# DEVTOOLS package
CVS_SRC_BUILDROOT       	:= projects/sw/devtools/buildroot
CVS_SRC_3RDPARTY        	:= projects/sw/devtools/3rdParty
CVS_SRC_BINUTILS        	:= projects/sw/devtools/binutils/binutils
CVS_SRC_GCC             	:= projects/sw/devtools/gcc/gcc
CVS_SRC_GCC_4_3_5       	:= projects/sw/devtools/gcc-4.3.5
CVS_SRC_KERNEL_HEADERS  	:= projects/sw/kernel/$(LINUXDIR)
CVS_SRC_UCLIBC          	:= projects/sw/devtools/uClibc
CVS_SRC_DIRECTFB        	:= projects/sw/directfb/DirectFB-1.4.5
STANDALONE_BUILD        	:= projects/sw/sdk/sdk_tools
BUILDROOT_FILE          	:= $(TEMP_DIR)/devtools/tarballs/buildroot-c2.snapshot.tar.bz2
BUSYBOX_1_5_1_FILE      	:= $(TEMP_DIR)/devtools/tarballs/busybox-1.5.1.tar.bz2
BUSYBOX_1_13_3_FILE     	:= $(TEMP_DIR)/devtools/tarballs/busybox-1.13.3.tar.bz2
I2CTOOLS_FILE           	:= $(TEMP_DIR)/devtools/tarballs/i2c-tools-3.0.1.tar.bz2
OPROFILE_FILE           	:= $(TEMP_DIR)/devtools/tarballs/oprofile-0.9.1.tar.bz2
BINUTILS_FILE           	:= $(TEMP_DIR)/devtools/tarballs/binutils-c2.snapshot.tar.bz2
GCC_FILE                	:= $(TEMP_DIR)/devtools/tarballs/gcc-c2.snapshot.tar.bz2
KERNEL_FILE      		:= $(TEMP_DIR)/devtools/tarballs/linux-libc-headers-$(SDK_KERNEL_VERSION).0.tar.bz2
UCLIBC_FILE             	:= $(TEMP_DIR)/devtools/tarballs/uClibc-0.9.27.tar.bz2
DIRECTFB_FILE           	:= $(TEMP_DIR)/devtools/tarballs/DirectFB-1.4.5.tar.bz2
PKG_NAME_SRC_DEVTOOLS   	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-devtools-src.tar.gz
PKG_NAME_BIN_DEVTOOLS		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-devtools-bin.tar.gz

# QT 4.7 package
CVS_SRC_QT    			:= sw/Qt/qt-everywhere-opensource-src-4.7.0
PKG_NAME_SRC_QT   		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qt-4.7.0-src.tar.gz
PKG_NAME_BIN_QT   		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qt-4.7.0-bin.tar.gz
QT_EXTRA_CONFIG   		:= -plugin-gfx-directfb
CVS_SRC_QT470			:= sw/Qt/qt-everywhere-opensource-src-4.7.0
PKG_NAME_SRC_QT470		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qt-4.7.0-src.tar.gz
PKG_NAME_BIN_QT470		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qt-4.7.0-bin.tar.gz
QT_EXTRA_CONFIG470		:= -plugin-gfx-directfb

# SW_MEDIA package
CVS_SRC_SW_MEDIA		:= sw_media
SW_MEDIA_DIR			:= /usr/local/c2/sw_media/known_good/TARGET_LINUX_C2_$(SDK_TARGET_GCC_ARCH)_RELEASE
PKG_NAME_SRC_SW_MEDIA_ALL  	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-src-all.tar.gz
PKG_NAME_SRC_SW_MEDIA_2ND  	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-src-2nd.tar.gz
PKG_NAME_SRC_SW_MEDIA		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-src.tar.gz
PKG_NAME_BIN_SW_MEDIA		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-bin.tar.gz
PKG_NAME_BIN_SW_MEDIA_QA   	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-bin-QA.tar.gz
PKG_NAME_TEST_BIN_SW_MEDIA 	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-test-bin.tar.gz
PKG_NAME_DOC_SW_MEDIA		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_media-doc.tar.gz

#kernel package
PKG_NAME_SRC_KERNEL		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kernel-src.tar.gz
PKG_NAME_BIN_KERNEL		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kernel-bin.tar.gz
PKG_NAME_BIN_KERNEL_NAND	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kernel-nand-bin.tar.gz
PKG_NAME_SRC_KERNEL_2632	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kernel-2.6.32-src.tar.gz
PKG_NAME_BIN_KERNEL_2632	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kernel-2.6.32-bin.tar.gz
LINUXDIR_2632			:= linux-2.6.32

# vivante package
CVS_SRC_VIVANTE         	:= sw/bsp/vivante/VIVANTE_GAL2D_Unified
PKG_NAME_SRC_VIVANTE    	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-src.tar.gz
PKG_NAME_BIN_VIVANTE    	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-bin.tar.gz
PKG_NAME_TEST_SRC_VIVANTE	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-test-src.tar.gz

# hdmi package
CVS_SRC_HDMI_JAZZ2      	:= sw/bsp/hdmi/jazz2hdmi
PKG_NAME_SRC_HDMI_JAZZ2   	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-hdmi-src.tar.gz
PKG_NAME_BIN_HDMI_JAZZ2   	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-hdmi-bin.tar.gz

# c2box package
CVS_SRC_SW_C2APPS		:= sw_c2apps
PKG_NAME_SRC_SW_C2APPS  := $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-sw_c2apps-src.tar.gz
PKG_NAME_SRC_P2P        := $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-p2p-src.tar.gz
PKG_NAME_BIN_WEBKIT	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qtwebkit-bin.tar.gz
PKG_NAME_SRC_C2BOX	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-c2box-src.tar.gz
PKG_NAME_SRC_C2BOX_ALL	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-c2box-src-all.tar.gz
PKG_NAME_SRC_MINIBD	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-minibd-src.tar.gz
PKG_NAME_SRC_FLASH	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-flash-src.tar.gz
PKG_NAME_SRC_KARAOKE	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-karaoke-src.tar.gz
PKG_NAME_SRC_VIDEOCHAT	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-videochat-src.tar.gz
PKG_NAME_SRC_THUNDERKK	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-thunderkk-src.tar.gz
PKG_NAME_SRC_MVPHONE	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-mvphone-src.tar.gz
PKG_NAME_SRC_BROWSER	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-browser-src.tar.gz
PKG_NAME_SRC_IPCAM	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-ipcam-src.tar.gz
PKG_NAME_SRC_JVM	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-jvm-src.tar.gz
PKG_NAME_SRC_SOHU	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-sohu-src.tar.gz
PKG_NAME_SRC_RECOEDING	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-recording-src.tar.gz

# Demo package
PKG_NAME_BIN_DEMO	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-demo-bin.tar.gz
PKG_NAME_BIN_DEMO_P2P   := $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-demo-bin-p2p.tar.gz
PKG_NAME_C2BOX_DEMO	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-c2box-bin.tar.gz
PKG_NAME_BIN_PPS	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-pps-bin.tar.gz
PKG_NAME_BIN_BESTV	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-bestv-bin.tar.gz
PKG_NAME_BIN_THUNDERKK	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-thunderkk-bin.tar.gz
PKG_NAME_BIN_VIDEOPHONE	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-videophone-bin.tar.gz
PKG_NAME_BIN_VIDEOCHAT	:= $(PKG_DIR)/c2box/c2-$(SDK_VERSION_ALL)-videochat-bin.tar.gz
PKG_NAME_BIN_TOOLS	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-tools-bin.tar.gz

# SPI package
CVS_SRC_SPI			:= sw/prom/spirom
PKG_NAME_SRC_SPI_B1		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-spi_rom-cc1100-250-src.tar.gz
PKG_NAME_SRC_SPI_B2		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-spi_rom-cc1100-350-src.tar.gz
PKG_NAME_BIN_SPI_B1		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-spi_rom-cc1100-250-bin.tar.gz
PKG_NAME_BIN_SPI_B2		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-spi_rom-cc1100-350-bin.tar.gz
                        	
# diag package
CVS_SRC_DIAG            	:= sw/prom/diag
PKG_NAME_SRC_DIAG       	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-diag_rom-src.tar.gz
PKG_NAME_BIN_DIAG       	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-diag_rom-bin.tar.gz

CVS_SRC_JTAG            	:= sw/jtag
PKG_NAME_SRC_JTAG       	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jtag-src.tar.gz
PKG_NAME_BIN_JTAG       	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jtag-bin.tar.gz

# U-BOOT package
uboot_utilities			:= u-boot-utilities
UBOOT_BOARDTYPE         	:= jazz2evb_config
UBOOT_MAKECONFIG        	:= MPUCLK=400 MEMCLK=400 DDR_DEVICE=MT47H64M16-25E
CVS_SRC_UBOOT			:= sw/prom/u-boot-1.3.0
GIT_SRC_UBOOT			:= u-boot-1.3.0
PKG_NAME_SRC_UBOOT		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-u-boot-src.tar.gz
PKG_NAME_BIN_UBOOT		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-u-boot-bin.tar.gz

# C2 Goodies package
PKG_NAME_SRC_GOODIES	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-c2_goodies-src.tar.gz
PKG_NAME_BIN_GOODIES	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-c2_goodies-bin.tar.gz
CVS_SRC_BUSYBOX_1.5.1   := sw/cmd/busybox-1.5.1
CVS_SRC_BUSYBOX_1.13.3  := sw/cmd/busybox-1.13.3
CVS_SRC_I2CTOOLS        := sw/cmd/i2c-tools
CVS_SRC_OPROFILE        := projects/sw/oprofile
FUSEPOD_SCRIPT          := $(CVS_SRC_3RDPARTY)/scripts/build-fusepod.sh 
DJMOUNT_PKG             := $(CVS_SRC_3RDPARTY)/djmount-0.71.tar.gz
FUSEPOD_PKG             := $(CVS_SRC_3RDPARTY)/fusepod-0.5.1.tar
LIBGPOD_PKG             := $(CVS_SRC_3RDPARTY)/libgpod-0.5.2.tar.gz
FUSE_PKG                := $(CVS_SRC_3RDPARTY)/fuse-2.6.3.tar.gz 
GLIB_PKG                := $(CVS_SRC_3RDPARTY)/glib-2.12.9-c2.tar
TAGLIB_PKG              := $(CVS_SRC_3RDPARTY)/taglib-1.4.tar
PERL_SCRIPT             := $(CVS_SRC_3RDPARTY)/scripts/build-microperl.sh 
PERL_PKG                := $(CVS_SRC_3RDPARTY)/perl-5.8.8.tar.gz
CVS_SRC_SNOOPY          := projects/sw/cmd/snoopy
CVS_SRC_STRACE          := projects/sw/strace
POPT_PKG                := $(CVS_SRC_3RDPARTY)/popt-1.7.tar.gz
ETHERTOOL_PKG           := $(CVS_SRC_3RDPARTY)/ethtool-6.tar.gz
BENCHMARK_SCRIPT        := $(CVS_SRC_3RDPARTY)/scripts/build-benchmark.sh
BONNIE_PKG              := $(CVS_SRC_3RDPARTY)/bonnie++-1.03d.tgz
IOZONE_PKG              := $(CVS_SRC_3RDPARTY)/iozone3_308-c2.tgz
LMBENCH_PKG		:= $(CVS_SRC_3RDPARTY)/lmbench3-c2.tgz
UNIXBENCH_PKG           := $(CVS_SRC_3RDPARTY)/unixbench-4.1.0-c2.tgz
IPERF_PKG               := $(CVS_SRC_3RDPARTY)/iperf-2.0.2.c2.tar.gz
NETPERF_PKG             := $(CVS_SRC_3RDPARTY)/netperf-2.4.4.c2.tar.gz
CVS_SRC_APP_3RDPARTY	:= projects/sw/c2apps/3rdParty/dist
HDD_SCRIPT              := projects/sw/c2apps/3rdParty/sdk-build-hdd.sh
SAMBA_PKG               := $(CVS_SRC_APP_3RDPARTY)/samba-3.0.28a-c2.tar.bz2
NTFS_PKG                := $(CVS_SRC_APP_3RDPARTY)/ntfs-3g-1.2531-c2.tgz
NTFSPROGS_PKG           := $(CVS_SRC_APP_3RDPARTY)/ntfsprogs-2.0.0-c2.tar.gz
LIBUSB_PKG              := $(CVS_SRC_APP_3RDPARTY)/libusb-0.1.12.tar.bz2
LIBPTP_PKG              := $(CVS_SRC_APP_3RDPARTY)/libptp2-1.1.10.tar.gz

devtools-tarballs-remove +=    \
	cups-1.1.23-source.tar.bz2 	\
	djmount-0.71.tar.gz        	\
	fusepod-0.5.1.tar          	\
	fuse-2.6.3.tar.gz          	\
	fuse-2.7.1-c2.tar.gz       	\
	glib-2.12.9-c2.tar         	\
	libgpod-0.4.2-c2.tar       	\
	libgpod-0.5.2.tar.gz       	\
	libptp2-1.1.0-c2.tar.bz2   	\
	libptp2-1.1.10.tar.gz      	\
	libusb-0.1.12.tar.bz2      	\
	ntfs-3g-1.1120-c2.tgz      	\
	ntfs-3g-1.710-c2.tgz       	\
	oprofile-0.9.2.tar.gz      	\
	perl-5.8.8.tar.gz          	\
	samba-3.0.28a-c2.tar.bz2   	\
	samba-2.2.12-c2.tar.bz2    	\
	taglib-1.4.tar             	\
	gcc-core-4.3.5.tar.bz2  	\
	gcc-g++-4.3.5.tar.bz2  		\
	gcc-testsuite-4.3.5.tar.bz2 	\
	gmp-4.3.2.tar.bz2  mpc-0.8.1.tar.gz  mpfr-2.4.2.tar.bz2   \
	linux-2.6.32.tar.bz2		\

PKG_NAME_BIN_FACEN_UDISK:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-factory-udisk-en.tar.gz
PKG_NAME_BIN_FACCN_UDISK:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-factory-udisk-cn.tar.gz
PKG_NAME_BIN_USER_UDISK := $(PKG_DIR)/c2_update.tar

FACUDISK_FILES := 	updating.bmp	updatefail.bmp	updatesucc.bmp	logo.bmp	\
			kernel.img	rootfs.img	home.img			\
			u-boot.rom	u-boot-factory.rom
uboot_file		:= $(uboot_utilities)/u-boot-jazz2-autodetect.rom
uboot_factory_file	:= $(uboot_utilities)/u-boot-jazz2-factory-autodetect.rom
BIN_MKIMAGE  		:= $(uboot_utilities)/mkimage
BIN_MKYAFFS2 		:= $(CVS_SRC_KERNEL)/configs/jazz2-pvr-nand/mkyaffs/mkyaffs2
BIN_MKJFFS2  		:= $(TOOLCHAIN_PATH)/mkfs.jffs2
BCHTOOLS     		:= $(TEST_ROOT_DIR)/sw/kernel/configs/jazz2-pvr-nand/bch_generate

SYSPATH			:=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$(HOME)/bin
override PATH := $(QT_INSTALL_DIR)/bin:$(TOOLCHAIN_PATH):$(TEST_ROOT_DIR)/usr/bin:$(TEST_ROOT_DIR)/bin:$(SYSPATH)

