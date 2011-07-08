
# QT 4.7 package
CVS_SRC_QT470			:= sw/Qt/qt-everywhere-opensource-src-4.7.0
PKG_NAME_SRC_QT470		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qt-4.7.0-src.tar.gz
PKG_NAME_BIN_QT470		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-qt-4.7.0-bin.tar.gz
QT_EXTRA_CONFIG470		:= -plugin-gfx-directfb

mission_qt470 := src_get_qt470  \
	src_package_qt470 src_install_qt470 src_config_qt470 src_build_qt470 \
	bin_package_qt470 bin_install_qt470 
mission_modules += mission_qt470
mission_targets += $(mission_qt470)
.PHONY: $(mission_qt470)
src_get_qt470:  sdk_folders
	@echo start $@
	#@cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_QT470)
	@echo $@ done
src_package_qt470: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_SRC_QT470)
	@echo "Creating package $(PKG_NAME_SRC_QT470)"
	@cd $(SOURCE_DIR); tar cfz $(PKG_NAME_SRC_QT470) --exclude=CVS --exclude=CVSROOT --exclude=.git --exclude=.gitignore\
		$(CVS_SRC_QT470)
	@echo $@ done
src_install_qt470: sdk_folders
	@echo start $@
	@-rm -rf $(TEST_ROOT_DIR)/build_qt
	@mkdir -p $(TEST_ROOT_DIR)/build_qt
	@echo Extract $(PKG_NAME_SRC_QT470)
	cd $(TEST_ROOT_DIR)/build_qt ; \
	    tar xzf $(PKG_NAME_SRC_QT470)
	@echo $@ done
src_config_qt470: sdk_folders
	@echo start $@
	cd $(TEST_ROOT_DIR)/build_qt/$(CVS_SRC_QT470) ; \
	QT_CFLAGS_DIRECTFB="-I$(TOOLCHAIN_PATH)/../include/directfb -DQT_CFLAGS_DIRECTFB" \
	QT_LIBS_DIRECTFB="-L$(TOOLCHAIN_PATH)/../lib -ldirectfb -ldirect -lfusion" \
	TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) DISP_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2 BOARD_TARGET=C2_CC289 BUILD=RELEASE \
	C2_DEVTOOLS_PATH=$(TOOLCHAIN_PATH)/..  \
	./configure -embedded c2 \
	-little-endian -qt-kbd-linuxinput -system-libpng -qt-gif -release \
	-prefix $(TEST_ROOT_DIR)/QtopiaCore-4.7.0-generic -confirm-license -opensource -qt-libjpeg \
	-qt-libmng -qvfb -depths 8,16,32 \
	-confirm-license -largefile -webkit -svg -dbus -I $(TEST_ROOT_DIR)/c2/daily/include/dbus-1.0 \
	-L $(TEST_ROOT_DIR)/c2/daily/lib/  -ldbus-1 -xmlpatterns -exceptions \
	-openssl-linked
	@echo $@ done
src_build_qt470: sdk_folders
	@echo start $@
	@cd $(TEST_ROOT_DIR)/build_qt/$(CVS_SRC_QT470) ; \
	TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) DISP_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2 BOARD_TARGET=C2_CC289 BUILD=RELEASE \
	make C2_DEVTOOLS_PATH=$(TOOLCHAIN_PATH)/..
	@cd $(TEST_ROOT_DIR)/build_qt/$(CVS_SRC_QT470) ; \
	TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) DISP_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2 BOARD_TARGET=C2_CC289 BUILD=RELEASE \
	make C2_DEVTOOLS_PATH=$(TOOLCHAIN_PATH)/.. install
	@echo $@ done
bin_package_qt470: sdk_folders
