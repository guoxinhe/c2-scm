
BRANCH_SOURCE_DIR :=$(TOP_DIR)/source-JAZZ2T
mission_kerneljazz2tnfs := help_kerneljazz2tnfs clean_kerneljazz2tnfs src_get_kerneljazz2tnfs  \
	src_package_kerneljazz2tnfs src_install_kerneljazz2tnfs src_config_kerneljazz2tnfs src_build_kerneljazz2tnfs \
	bin_package_kerneljazz2tnfs bin_install_kerneljazz2tnfs
mission_modules += mission_kerneljazz2tnfs
mission_targets += $(mission_kerneljazz2tnfs)
.PHONY: $(mission_kerneljazz2tnfs)
src_get_kerneljazz2tnfs:  sdk_folders
	mkdir -p $(BRANCH_SOURCE_DIR); 
	cd $(BRANCH_SOURCE_DIR);  \
	    cvs co -r JAZZ2T $(CVS_SRC_KERNEL)/linux-2.6;
	@echo $@ done
src_package_kerneljazz2tnfs: sdk_folders $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@echo $@ done
src_install_kerneljazz2tnfs: sdk_folders $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)
	@echo $@ done
src_config_kerneljazz2tnfs: sdk_folders
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR)/; \
	    cp arch/c2/configs/$(LINUX_CONFIG) .config; \
	    yes "" |make oldconfig;
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL); \
	    make initramfs_gen.txt;
	@echo $@ done
src_build_kerneljazz2tnfs: sdk_folders
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL); \
	    make
	@echo $@ done
bin_package_kerneljazz2tnfs: sdk_folders $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.bin.tar.gz
	@echo $@ done
bin_install_kerneljazz2tnfs: sdk_folders
	@echo $@ done
clean_kerneljazz2tnfs: sdk_folders
	rm -rf $(TEMP_DIR)/$(CVS_SRC_KERNEL) $(TEST_ROOT_DIR)/build_kerneljazz2tnfs $(TEST_USR_DIR)/kerneljazz2tnfs
	@echo $@ don
test_kerneljazz2tnfs: $(mission_kerneljazz2tnfs)
help_kerneljazz2tnfs: sdk_folders mktest
	@echo targets: $(mission_kerneljazz2tnfs)
	@echo $@ done
$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz:
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@rm -rf $(TEMP_DIR)/$(CVS_SRC_KERNEL)
	@mkdir -p $(TEMP_DIR)/$(CVS_SRC_KERNEL)
	@cp -rf $(SOURCE_DIR)/$(CVS_SRC_KERNEL) $(TEMP_DIR)/$(CVS_SRC_KERNEL)/..
	@cd $(TEMP_DIR)/$(CVS_SRC_KERNEL) ; rm -rf linux-* ; cp -rf $(BRANCH_SOURCE_DIR)/$(CVS_SRC_KERNEL)/$(LINUXDIR) .
	@# Add -m32 switch (valid for both i386 and x86_64 builds)
	@cd $(TEMP_DIR)/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	        sed -i '{s,= gcc,= gcc -m32,g}' Makefile;
	@# Add version
	@cd $(TEMP_DIR)/$(CVS_SRC_KERNEL)/$(LINUXDIR)/arch/c2/configs; \
	    sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="[$(SDK_VERSION_ALL)]"/' $(LINUX_CONFIG)
	@cd $(TEMP_DIR)/$(CVS_SRC_KERNEL)/configs/jazz2-pvr-nand; \
	    sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="[$(SDK_VERSION_ALL)]"/' defconfig
	
	@# package up kernel src
	@cd $(TEMP_DIR); \
	    tar cfz $@ \
    		--exclude=CVS \
    		--exclude=CVSROOT \
    		./$(CVS_SRC_KERNEL); \
	    rm -rf $(CVS_SRC_KERNEL)
	@touch $@
$(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL): $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/ ; \
	    tar xzf $<
	@touch $@
$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.bin.tar.gz:
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	mv -f Makefile Makefile.save;\
	echo "image:" > Makefile;
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/; \
		tar cfz $@ \
		$(CVS_SRC_KERNEL)/1gb.part \
		$(CVS_SRC_KERNEL)/initramfs_files \
		$(CVS_SRC_KERNEL)/initramfs_source.in \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.bin \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.dump \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/System.map \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/Makefile \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/MAINTAINERS \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/REPORTING-BUGS \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/CREDITS \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/COPYING \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/usr \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/.config \
		$(CVS_SRC_KERNEL)/Makefile
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	mv -f Makefile.save Makefile
	@touch $@
$(TEST_USR_DIR)/kerneljazz2tnfs:$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.bin.tar.gz
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(@D) ; \
	    tar xzf $<
	@touch $@



mission_ubootjazz2tevb := help_ubootjazz2tevb clean_ubootjazz2tevb       src_get_ubootjazz2tevb  \
	src_package_ubootjazz2tevb src_install_ubootjazz2tevb src_config_ubootjazz2tevb src_build_ubootjazz2tevb \
	bin_package_ubootjazz2tevb bin_install_ubootjazz2tevb
mission_modules += mission_ubootjazz2tevb
mission_targets += $(mission_ubootjazz2tevb)
.PHONY: $(mission_ubootjazz2tevb)
src_get_ubootjazz2tevb:  sdk_folders
	mkdir -p $(BRANCH_SOURCE_DIR);
	@cd $(BRANCH_SOURCE_DIR); cvs co -r JAZZ2T $(CVS_SRC_UBOOT)
	@echo $@ done
src_package_ubootjazz2tevb: sdk_folders $(PKG_NAME_SRC_UBOOT)
	if [ -f $(PKG_NAME_SRC_UBOOT) ]; then rm $(PKG_NAME_SRC_UBOOT);fi
	@echo "Creating package $(PKG_NAME_SRC_UBOOT)"
	@cd $(BRANCH_SOURCE_DIR); \
	    tar cfz $(PKG_NAME_SRC_UBOOT) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        $(CVS_SRC_UBOOT)
	@echo $@ done
src_install_ubootjazz2tevb: sdk_folders
	@rm -rf $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)
	@echo Extract $(PKG_NAME_SRC_UBOOT) to Target folder $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $(PKG_NAME_SRC_UBOOT)
	@echo $@ done
src_config_ubootjazz2tevb: sdk_folders
	@echo $@ done
src_build_ubootjazz2tevb: sdk_folders
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT); \
		./build.sh jazz2t;
	@touch $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)/$(uboot_utilities)
	@echo $@ done
bin_package_ubootjazz2tevb: sdk_folders
	if [ -f $(PKG_NAME_BIN_UBOOT) ]; then rm $(PKG_NAME_BIN_UBOOT);fi
	@echo "Creating package $(PKG_NAME_BIN_UBOOT)"
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT); \
		tar cfz $(PKG_NAME_BIN_UBOOT) $(uboot_utilities)
	@touch $(PKG_NAME_BIN_UBOOT)
	@echo $@ done
bin_install_ubootjazz2tevb: sdk_folders
	@echo $@ done
clean_ubootjazz2tevb: sdk_folders
	@echo $@ done
test_ubootjazz2tevb: $(mission_ubootjazz2tevb)
help_ubootjazz2tevb: sdk_folders mktest
	@echo targets: $(mission_ubootjazz2tevb)
	@echo $@ done

mission_diagjazz2t := help_diagjazz2t clean_diagjazz2t src_get_diagjazz2t  \
	src_package_diagjazz2t src_install_diagjazz2t src_config_diagjazz2t src_build_diagjazz2t \
	bin_package_diagjazz2t bin_install_diagjazz2t
mission_modules += mission_diagjazz2t
mission_targets += $(mission_diagjazz2t)
.PHONY: $(mission_diagjazz2t)
src_get_diagjazz2t:src_get_diag
src_package_diagjazz2t:src_package_diag
src_install_diagjazz2t:src_install_diag
src_config_diagjazz2t:src_config_diag
src_build_diagjazz2t: sdk_folders
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG); \
	    make BOARD=cc3300 MEMCLK=400 MPUCLK=400 clean; \
	    make BOARD=cc3300 MEMCLK=400 MPUCLK=400
	touch $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG)/loader
	@echo $@ done
bin_package_diagjazz2t:bin_package_diag
bin_install_diagjazz2t:bin_install_diag
clean_diagjazz2t:clean_diag
test_diagjazz2t: $(mission_diagjazz2t)
help_diagjazz2t: sdk_folders mktest
	@echo targets: $(mission_diagjazz2t)
	@echo $@ done
