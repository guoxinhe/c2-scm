mission_sw_mediaandroid := src_get_sw_mediaandroid  \
	src_package_sw_mediaandroid src_install_sw_mediaandroid src_config_sw_mediaandroid src_build_sw_mediaandroid \
	bin_package_sw_mediaandroid bin_install_sw_mediaandroid 
mission_modules += mission_sw_mediaandroid
mission_targets += $(mission_sw_mediaandroid)
.PHONY: $(mission_sw_mediaandroid)
src_get_sw_mediaandroid:  sdk_folders
	@echo start $@
	@if test -d "$(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA)"; then \
	     cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA); echo $(UPDATE); \
	 else \
	     cd $(SOURCE_DIR); echo $(CHECKOUT) $(CVS_SRC_SW_MEDIA); \
	 fi
	@echo $@ done
src_package_sw_mediaandroid: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_SRC_SW_MEDIA_ALL)
	@echo "Creating package $(PKG_NAME_SRC_SW_MEDIA_ALL)"
	@cd $(SOURCE_DIR); tar cfz $(PKG_NAME_SRC_SW_MEDIA_ALL) --exclude=CVS --exclude=CVSROOT --exclude=.git \
		$(CVS_SRC_SW_MEDIA)
	@echo $@ done
src_install_sw_mediaandroid: sdk_folders
	@echo start $@
	@echo Extract $(PKG_NAME_SRC_SW_MEDIA_2ND)
	@-rm -rf $(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA)/*
	@-rm -rf $(TEST_ROOT_DIR)/build_sw_media
	@mkdir -p $(TEST_ROOT_DIR)/build_sw_media
	@cd $(TEST_ROOT_DIR)/build_sw_media; \
	    tar xfz $(PKG_NAME_SRC_SW_MEDIA_ALL);
	@cd $(TEST_ROOT_DIR)/build_sw_media/$(CVS_SRC_SW_MEDIA)/build/build/customer/build; \
	    if [ ! -f globalconfig-C2-PVR-REAL-jazz2t ]; then  \
	        ln -s globalconfig-C2-PVR-REAL-jazz2 globalconfig-C2-PVR-REAL-jazz2t ; fi; \
	    if [ ! -f globalconfig-C2-PVR-jazz2t ]; then  \
	        ln -s globalconfig-C2-PVR-jazz2 globalconfig-C2-PVR-jazz2t ; fi;
	@echo $@ done
src_config_sw_mediaandroid: sdk_folders
	@echo start $@
	@echo $@ done

BUILD_TARGET=TARGET_LINUX_C2
BOARD_TARGET=C2_CC289
src_build_sw_mediaandroid: sdk_folders
	@echo start $@
	@cd $(TEST_ROOT_DIR)/build_sw_media/$(CVS_SRC_SW_MEDIA); \
		TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2  BOARD_TARGET=C2_CC289 BUILD=RELEASE make -j 5
		#time TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) DISP_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2 BOARD_TARGET=C2_CC289 BUILD=RELEASE make -j 5
	@echo $@ done
bin_package_sw_mediaandroid: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_BIN_SW_MEDIA)
	@echo "Creating package $(PKG_NAME_BIN_SW_MEDIA):"
	@cd $(TEST_ROOT_DIR)/build_sw_media/$(CVS_SRC_SW_MEDIA); \
	    tar zcf $(PKG_NAME_BIN_SW_MEDIA) \
		TARGET_LINUX_C2_$(SDK_TARGET_GCC_ARCH)_RELEASE
	@echo $@ done
bin_install_sw_mediaandroid: sdk_folders
	@echo start $@
	@echo Prepare for SW_MEDIA_PATH=$(SW_MEDIA_PATH)
	@-rm -rf $(SW_MEDIA_PATH)
	@echo Extract $(PKG_NAME_BIN_SW_MEDIA)
	@mkdir -p $(SW_MEDIA_PATH)
	cd $(SW_MEDIA_PATH); \
	    tar xzf $(PKG_NAME_BIN_SW_MEDIA)
	@echo $@ done
clean_sw_mediaandroid: sdk_folders
	@echo $@ remove binary install,build,configure,source install
	@-rm -rf  $(TEMP_DIR)/$(CVS_SRC_SW_MEDIA)  \
		$(TEST_ROOT_DIR)/build_sw_media \
		$(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_MEDIA) \
		;
	@echo $@ done
test_sw_mediaandroid: $(mission_sw_mediaandroid)
help_sw_mediaandroid: sdk_folders mktest
	@echo 
	@echo targets: $(mission_sw_mediaandroid) clean_sw_mediaandroid test_sw_mediaandroid help_sw_mediaandroid
	@echo $@ done


