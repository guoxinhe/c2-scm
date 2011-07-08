# example code
mission_xxx := 	src_get_xxx  \
		src_package_xxx \
		src_install_xxx \
		src_config_xxx \
		src_build_xxx \
		bin_package_xxx \
		bin_install_xxx
mission_modules += mission_xxx
mission_targets += $(mission_xxx)
.PHONY: $(mission_xxx) clean_xxx help_xxx test_xxx
src_get_xxx:     sdk_folders
	@mkdir -p $(TEST_ROOT_DIR)/src_xxx/xxx
	@echo $@ done
src_package_xxx: sdk_folders
	@touch $(PKG_DIR)/xxx.src.tar.gz
	@echo $@ done
src_install_xxx: sdk_folders
	@mkdir -p $(TEST_ROOT_DIR)/build_xxx/xxx
	@touch    $(TEST_ROOT_DIR)/build_xxx/xxx/xxx.c
	@echo $@ done
src_config_xxx:  sdk_folders
	@echo $@ done
src_build_xxx:   sdk_folders
	@touch $(TEST_ROOT_DIR)/build_xxx/xxx/xxx.bin
	@echo $@ done
bin_package_xxx: sdk_folders 
	@touch $(PKG_DIR)/xxx.bin.tar.gz
	@echo $@ done
bin_install_xxx: sdk_folders
	@mkdir -p $(TEST_ROOT_DIR)/usr/bin
	@touch $(TEST_ROOT_DIR)/usr/bin/xxx
	@echo $@ done
clean_xxx: 
	@echo $@ done
help_xxx: 
	@echo $@ done
test_xxx: $(mission_xxx)
	@echo $@ done

