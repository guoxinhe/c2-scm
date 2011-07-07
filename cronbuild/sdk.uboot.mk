
# U-BOOT package
uboot_utilities			:= u-boot-utilities
GIT_SRC_UBOOT			:= u-boot-1.3.0
PKG_NAME_SRC_UBOOT		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-u-boot-src.tar.gz
PKG_NAME_BIN_UBOOT		:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-u-boot-bin.tar.gz

mission_uboot := src_get_uboot  \
	src_package_uboot src_install_uboot src_config_uboot src_build_uboot \
	bin_package_uboot bin_install_uboot
mission_modules += mission_uboot
mission_targets += $(mission_uboot)
.PHONY: $(mission_uboot) clean_uboot help_uboot test_uboot

src_get_uboot:  sdk_folders
	@echo start $@
	#@cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_UBOOT)
	@echo $@ done
src_package_uboot: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_SRC_UBOOT)
	@echo "Creating package $(PKG_NAME_SRC_UBOOT)"
	@cd $(SOURCE_DIR); \
	    tar cfz $(PKG_NAME_SRC_UBOOT) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        --exclude=.git \
	        $(GIT_SRC_UBOOT)
	@echo $@ done
src_install_uboot: sdk_folders
	@echo start $@
	@-rm -rf $(TEST_ROOT_DIR)/build_uboot
	@mkdir -p $(TEST_ROOT_DIR)/build_uboot
	@echo Extract  $(PKG_NAME_SRC_UBOOT)
	cd $(TEST_ROOT_DIR)/build_uboot; \
	    tar xzf  $(PKG_NAME_SRC_UBOOT)
	@echo $@ done
src_config_uboot: sdk_folders
	@echo start $@
	@echo $@ done
src_build_uboot: sdk_folders
	@echo start $@
	@cd $(TEST_ROOT_DIR)/build_uboot/$(GIT_SRC_UBOOT); \
		./build.sh $(SDK_TARGET_ARCH); \
		cp $(uboot_utilities)/mkimage  $(TEST_ROOT_DIR)/usr/bin/;
	@echo $@ done
bin_package_uboot: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_BIN_UBOOT)
	@echo "Creating package $(PKG_NAME_BIN_UBOOT)"
	@cd $(TEST_ROOT_DIR)/build_uboot/$(GIT_SRC_UBOOT); \
		tar cfz $(PKG_NAME_BIN_UBOOT) $(uboot_utilities)
	@echo $@ done
bin_install_uboot: sdk_folders
	@echo start $@
	@echo $@ done
clean_uboot: sdk_folders
	@echo start $@
	rm -rf $(TEST_ROOT_DIR)/build_uboot
	@echo $@ done
test_uboot: $(mission_uboot)
help_uboot: sdk_folders mktest
	@echo targets: $(mission_uboot) clean_uboot test_uboot help_uboot
	@echo $@ done


