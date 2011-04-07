
BRANCH_SOURCE_DIR :=$(TOP_DIR)/source-JAZZ2T
mission_jazz2tkernelnfs := help_jazz2tkernelnfs clean_jazz2tkernelnfs src_get_jazz2tkernelnfs  \
	src_package_jazz2tkernelnfs src_install_jazz2tkernelnfs src_config_jazz2tkernelnfs src_build_jazz2tkernelnfs \
	bin_package_jazz2tkernelnfs bin_install_jazz2tkernelnfs
mission_modules += mission_jazz2tkernelnfs
mission_targets += $(mission_jazz2tkernelnfs)
.PHONY: $(mission_jazz2tkernelnfs)
src_get_jazz2tkernelnfs:  sdk_folders
	mkdir -p $(BRANCH_SOURCE_DIR); 
	cd $(BRANCH_SOURCE_DIR);  \
	    cvs co -r JAZZ2T $(CVS_SRC_KERNEL)/linux-2.6;
	@echo $@ done
src_package_jazz2tkernelnfs: sdk_folders $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jazz2tkernelnfs.src.tar.gz
	@echo $@ done
src_install_jazz2tkernelnfs: sdk_folders $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL)
	@echo $@ done
src_config_jazz2tkernelnfs: sdk_folders
	@cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR)/; \
	    cp arch/c2/configs/$(LINUX_CONFIG) .config; \
	    yes "" |make oldconfig;
	@cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL); \
	    make initramfs_gen.txt;
	@echo $@ done
src_build_jazz2tkernelnfs: sdk_folders
	@cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL); \
	    make
	@echo $@ done
bin_package_jazz2tkernelnfs: sdk_folders $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jazz2tkernelnfs.bin.tar.gz
	@echo $@ done
bin_install_jazz2tkernelnfs: sdk_folders
	@echo $@ done
clean_jazz2tkernelnfs: sdk_folders
	rm -rf $(TEMP_DIR)/$(CVS_SRC_KERNEL) $(TEST_ROOT_DIR)/build_jazz2tkernelnfs $(TEST_USR_DIR)/jazz2tkernelnfs
	@echo $@ don
test_jazz2tkernelnfs: $(mission_jazz2tkernelnfs)
help_jazz2tkernelnfs: sdk_folders mktest
	@echo targets: $(mission_jazz2tkernelnfs)
	@echo $@ done
$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jazz2tkernelnfs.src.tar.gz:
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
$(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL): $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jazz2tkernelnfs.src.tar.gz
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/ ; \
	    tar xzf $<
	@touch $@
$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jazz2tkernelnfs.bin.tar.gz:
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	mv -f Makefile Makefile.save;\
	echo "image:" > Makefile;
	@cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/; \
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
	@cd $(TEST_ROOT_DIR)/build_jazz2tkernelnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	mv -f Makefile.save Makefile
	@touch $@
$(TEST_USR_DIR)/jazz2tkernelnfs:$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-jazz2tkernelnfs.bin.tar.gz
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(@D) ; \
	    tar xzf $<
	@touch $@

