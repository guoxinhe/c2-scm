# vivante package
CVS_SRC_VIVANTE         	:= drivers/vivante/VIVANTE_GAL2D_Unified
PKG_NAME_SRC_VIVANTE    	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-src.tar.gz
PKG_NAME_BIN_VIVANTE    	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-bin.tar.gz
PKG_NAME_TEST_SRC_VIVANTE	:= $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-gfx_2d-test-src.tar.gz

mission_vivante := src_get_vivante  \
	src_package_vivante src_install_vivante src_config_vivante src_build_vivante \
	bin_package_vivante bin_install_vivante
mission_modules += mission_vivante
mission_targets += $(mission_vivante)
.PHONY: $(mission_vivante)
src_get_vivante:  sdk_folders
	@echo start $@
	#@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_VIVANTE)
	@echo $@ done
src_package_vivante: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_SRC_VIVANTE)
	@echo "Creating package $(PKG_NAME_SRC_VIVANTE)"
	@cd $(SOURCE_DIR); \
	   tar cfz $(PKG_NAME_SRC_VIVANTE) \
		--exclude=CVS \
		--exclude=CVSROOT --exclude=.git --exclude=.gitignore\
		$(CVS_SRC_VIVANTE)
	
	@-rm -rf $(PKG_NAME_TEST_SRC_VIVANTE)
	@echo "Creating package $(PKG_NAME_TEST_SRC_VIVANTE)"
	@cd $(SOURCE_DIR); \
	   tar cfz $(PKG_NAME_TEST_SRC_VIVANTE) \
		--exclude=CVS \
		--exclude=CVSROOT \
		$(CVS_SRC_VIVANTE)/gfxtst
	@echo $@ done
src_install_vivante: sdk_folders
	@echo start $@
	@-rm -rf $(TEST_ROOT_DIR)/build_vivante
	@mkdir -p $(TEST_ROOT_DIR)/build_vivante
	@echo Extract $(PKG_NAME_SRC_VIVANTE)
	cd $(TEST_ROOT_DIR)/build_vivante; \
	    tar xzf $(PKG_NAME_SRC_VIVANTE)
	@echo $@ done
src_config_vivante: sdk_folders
	@echo start $@
	@echo $@ done
src_build_vivante: sdk_folders
	@echo start $@
	@cd $(TEST_ROOT_DIR)/build_vivante/$(CVS_SRC_VIVANTE); \
		make KERNELDIR=$(KERNEL_PATH) install
	@echo $@ done
bin_package_vivante: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_BIN_VIVANTE)
	@echo "Creating package $(PKG_NAME_BIN_VIVANTE)"
	@cd $(TEST_ROOT_DIR)/build_vivante/$(CVS_SRC_VIVANTE); \
           tar cfz $(PKG_NAME_BIN_VIVANTE) build
