
BRANCH_SOURCE_DIR :=$(TOP_DIR)/source-JAZZ2T
mission_kerneljazz2tnfs := src_get_kerneljazz2tnfs  \
	src_package_kerneljazz2tnfs src_install_kerneljazz2tnfs src_config_kerneljazz2tnfs src_build_kerneljazz2tnfs \
	bin_package_kerneljazz2tnfs bin_install_kerneljazz2tnfs
mission_modules += mission_kerneljazz2tnfs
mission_targets += $(mission_kerneljazz2tnfs)
.PHONY: $(mission_kerneljazz2tnfs)
src_get_kerneljazz2tnfs:  sdk_folders
	mkdir -p $(BRANCH_SOURCE_DIR); 
	#cd $(BRANCH_SOURCE_DIR); cvs co -r JAZZ2T $(CVS_SRC_KERNEL)/linux-2.6;
	cd $(SOURCE_DIR); cvs co $(CVS_SRC_KERNEL)/linux-2.6;
	@echo $@ done
src_package_kerneljazz2tnfs: sdk_folders
	@rm -rf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@echo Creating package $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@rm -rf $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL)
	@mkdir -p $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL)
	@cp -rf $(SOURCE_DIR)/$(CVS_SRC_KERNEL) $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL)/..
	@cd $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL) ; rm -rf linux-* ; cp -rf $(SOURCE_DIR)/$(CVS_SRC_KERNEL)/$(LINUXDIR) .
	@# Add -m32 switch (valid for both i386 and x86_64 builds)
	@cd $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	        sed -i '{s,= gcc,= gcc -m32,g}' Makefile;
	@# Add version
	@cd $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL)/$(LINUXDIR)/arch/c2/configs; \
	    sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="[$(SDK_VERSION_ALL)]"/' $(LINUX_CONFIG)
	@cd $(TEMP_DIR)/src_kernel/$(CVS_SRC_KERNEL)/configs/jazz2-pvr-nand; \
	    sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="[$(SDK_VERSION_ALL)]"/' defconfig
	@# package up kernel src
	@cd $(TEMP_DIR)/src_kernel; \
	    tar cfz $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz \
		--exclude=CVS \
		--exclude=CVSROOT \
		./$(CVS_SRC_KERNEL); \
	    rm -rf $(CVS_SRC_KERNEL)
	@echo $@ done

src_install_kerneljazz2tnfs: sdk_folders
	@rm -rf $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)
	@echo Extract $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@mkdir -p $(TEST_ROOT_DIR)/build_kerneljazz2tnfs
	cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/ ; \
	    tar xzf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@echo $@ done
src_config_kerneljazz2tnfs: sdk_folders
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR)/; \
	    cp arch/c2/configs/$(LINUX_CONFIG) .config; \
	    yes "" |make oldconfig;
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL); \
	    make initramfs_gen.txt;
	@echo $@ done
src_build_kerneljazz2tnfs: sdk_folders
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL)/$(LINUXDIR)/; \
	    make
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL); \
	    make nfscpio
	@echo $@ done
bin_package_kerneljazz2tnfs: sdk_folders
	rm -rf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.bin.tar.gz
	@echo "Creating package $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.bin.tar.gz"
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/; \
		tar cfz $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.bin.tar.gz \
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
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnfs/$(CVS_SRC_KERNEL); \
	    tar czf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-nfsroot-bin.tar.gz nfsroot;
	@echo $@ done
bin_install_kerneljazz2tnfs: sdk_folders
	@echo $@ done
clean_kerneljazz2tnfs: sdk_folders
	rm -rf $(TEMP_DIR)/$(CVS_SRC_KERNEL) $(TEST_ROOT_DIR)/build_kerneljazz2tnfs
	@echo $@ don
test_kerneljazz2tnfs: $(mission_kerneljazz2tnfs)
help_kerneljazz2tnfs: sdk_folders mktest
	@echo targets: $(mission_kerneljazz2tnfs)
	@echo $@ done

mission_ubootjazz2tevb := src_get_ubootjazz2tevb  \
	src_package_ubootjazz2tevb src_install_ubootjazz2tevb src_config_ubootjazz2tevb src_build_ubootjazz2tevb \
	bin_package_ubootjazz2tevb bin_install_ubootjazz2tevb
mission_modules += mission_ubootjazz2tevb
mission_targets += $(mission_ubootjazz2tevb)
.PHONY: $(mission_ubootjazz2tevb)
src_get_ubootjazz2tevb:  sdk_folders
	mkdir -p $(BRANCH_SOURCE_DIR);
	@#cd $(BRANCH_SOURCE_DIR); cvs co -r JAZZ2T $(CVS_SRC_UBOOT)
	@cd $(SOURCE_DIR); cvs co $(CVS_SRC_UBOOT)
	@echo $@ done
src_package_ubootjazz2tevb: sdk_folders
	if [ -f $(PKG_NAME_SRC_UBOOT) ]; then rm $(PKG_NAME_SRC_UBOOT);fi
	@echo "Creating package $(PKG_NAME_SRC_UBOOT)"
	@cd $(SOURCE_DIR); \
	    tar cfz $(PKG_NAME_SRC_UBOOT) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        $(CVS_SRC_UBOOT)
	@echo $@ done
src_install_ubootjazz2tevb: sdk_folders
	@rm -rf $(TEST_ROOT_DIR)/build_uboot/$(CVS_SRC_UBOOT)
	@echo Extract $(PKG_NAME_SRC_UBOOT)
	@mkdir -p $(TEST_ROOT_DIR)/build_uboot;
	cd $(TEST_ROOT_DIR)/build_uboot; \
	    tar xzf $(PKG_NAME_SRC_UBOOT)
	@echo $@ done
src_config_ubootjazz2tevb: sdk_folders
	@echo $@ done
src_build_ubootjazz2tevb: sdk_folders
	@echo "BUILD TARGET: u-boot-bin"
	@cd $(TEST_ROOT_DIR)/build_uboot/$(CVS_SRC_UBOOT); \
		./build.sh jazz2t;
	@echo $@ done
bin_package_ubootjazz2tevb: sdk_folders
	if [ -f $(PKG_NAME_BIN_UBOOT) ]; then rm $(PKG_NAME_BIN_UBOOT);fi
	@echo "Creating package $(PKG_NAME_BIN_UBOOT)"
	@cd $(TEST_ROOT_DIR)/build_uboot/$(CVS_SRC_UBOOT); \
		tar cfz $(PKG_NAME_BIN_UBOOT) $(uboot_utilities)
	@echo $@ done
bin_install_ubootjazz2tevb: sdk_folders
	@echo $@ done
clean_ubootjazz2tevb: sdk_folders
	@echo $@ done
test_ubootjazz2tevb: $(mission_ubootjazz2tevb)
help_ubootjazz2tevb: sdk_folders mktest
	@echo targets: $(mission_ubootjazz2tevb)
	@echo $@ done

mission_diagjazz2t := src_get_diagjazz2t  \
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
	@cd $(TEST_ROOT_DIR)/build_diag/$(CVS_SRC_DIAG); \
	    make BOARD=cc3300 MEMCLK=400 MPUCLK=400 clean; \
	    make BOARD=cc3300 MEMCLK=400 MPUCLK=400
	@echo $@ done
bin_package_diagjazz2t:bin_package_diag
bin_install_diagjazz2t:bin_install_diag
clean_diagjazz2t:clean_diag
test_diagjazz2t: $(mission_diagjazz2t)
help_diagjazz2t: sdk_folders mktest
	@echo targets: $(mission_diagjazz2t)
	@echo $@ done


mission_kerneljazz2tnand := src_get_kerneljazz2tnand  \
	src_package_kerneljazz2tnand src_install_kerneljazz2tnand src_config_kerneljazz2tnand src_build_kerneljazz2tnand \
	bin_package_kerneljazz2tnand bin_install_kerneljazz2tnand
mission_modules += mission_kerneljazz2tnand
mission_targets += $(mission_kerneljazz2tnand)
.PHONY: $(mission_kerneljazz2tnand)
src_get_kerneljazz2tnand:  sdk_folders
	@echo start $@
	@echo $@ done
src_package_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo $@ done
src_install_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo Create: $(TEST_ROOT_DIR)/build_kerneljazz2tnand
	@-rm -rf $(TEST_ROOT_DIR)/build_kerneljazz2tnand
	@mkdir -p $(TEST_ROOT_DIR)/build_kerneljazz2tnand
	cd $(TEST_ROOT_DIR)/build_kerneljazz2tnand ; \
	    tar xzf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnfs.src.tar.gz
	@echo $@ done
src_config_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo Config $(TEST_ROOT_DIR)/build_kerneljazz2tnand
	@echo $@ done
src_build_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo build $(TEST_ROOT_DIR)/build_kerneljazz2tnand
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnand/$(CVS_SRC_KERNEL); \
		make -j5 -f configs/jazz2-pvr-nand/jazz2t-nand.mk;
	@echo $@ done
bin_package_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo Create: $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnand.bin.tar.gz
	@-rm -rf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnand.bin.tar.gz
	@cd $(TEST_ROOT_DIR)/build_kerneljazz2tnand; \
	    tar czf $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-kerneljazz2tnand.bin.tar.gz \
		--exclude=CVS --exclude=CVSROOT \
		$(CVS_SRC_KERNEL)/initramfs_files \
		$(CVS_SRC_KERNEL)/initramfs_source.in \
		$(CVS_SRC_KERNEL)/rootfs.image \
		$(CVS_SRC_KERNEL)/configs/jazz2-pvr-nand \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.bin \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.dump \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/zvmlinux.bin \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/System.map \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/Makefile \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/MAINTAINERS \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/REPORTING-BUGS \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/CREDITS \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/COPYING \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/usr \
		$(CVS_SRC_KERNEL)/$(LINUXDIR)/.config \
		$(CVS_SRC_KERNEL)/Makefile
	@echo $@ done
bin_install_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo Install software
	@echo $@ done
clean_kerneljazz2tnand: sdk_folders
	@echo start $@
	@echo clean kerneljazz2tnand
	@-rm -rf $(TEST_ROOT_DIR)/build_kerneljazz2tnand
	@echo $@ done
test_kerneljazz2tnand: $(mission_kerneljazz2tnand)
help_kerneljazz2tnand: sdk_folders mktest
	@echo targets: $(mission_kerneljazz2tnand)
	@echo $@ done




mission_vivante20100203 := src_get_vivante20100203  \
	src_package_vivante20100203 src_install_vivante20100203 src_config_vivante20100203 src_build_vivante20100203 \
	bin_package_vivante20100203 bin_install_vivante20100203
mission_modules += mission_vivante20100203
mission_targets += $(mission_vivante20100203)
.PHONY: $(mission_vivante20100203)
src_get_vivante20100203:  sdk_folders
	@echo start $@
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_VIVANTE)
	@echo $@ done
src_package_vivante20100203: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_SRC_VIVANTE)
	@echo "Creating package $(PKG_NAME_SRC_VIVANTE)"
	@cd $(SOURCE_DIR); \
	   tar cfz $(PKG_NAME_SRC_VIVANTE) \
		--exclude=CVS \
		--exclude=CVSROOT \
		$(CVS_SRC_VIVANTE)
	@echo "Creating package $(PKG_NAME_TEST_SRC_VIVANTE)"
	@-rm -rf $(PKG_NAME_TEST_SRC_VIVANTE)
	@cd $(SOURCE_DIR); \
	   tar cfz $(PKG_NAME_TEST_SRC_VIVANTE) \
		--exclude=CVS \
		--exclude=CVSROOT \
		$(CVS_SRC_VIVANTE)/unified_gfx_hal_test
	@echo $@ done
src_install_vivante20100203: sdk_folders
	@echo start $@
	@-rm -rf $(TEST_ROOT_DIR)/build_vivante20100203
	@mkdir -p $(TEST_ROOT_DIR)/build_vivante20100203
	@echo Extract $(PKG_NAME_SRC_VIVANTE)
	cd $(TEST_ROOT_DIR)/build_vivante20100203; \
	    tar xzf $(PKG_NAME_SRC_VIVANTE)
	@echo $@ done
src_config_vivante20100203: sdk_folders
	@echo start $@
	@echo $@ done
src_build_vivante20100203: sdk_folders
	@echo start $@
	@cd $(TEST_ROOT_DIR)/build_vivante20100203/$(CVS_SRC_VIVANTE); \
		make -f makefile.linux clean; \
		make -f makefile.linux install KERNEL_DIR=$(KERNEL_PATH) NO_DMA_COHERENT=1 EGL_API_FB=1 USE_PLATFORM_DRIVER=0
	@cd $(TEST_ROOT_DIR)/build_vivante20100203/$(CVS_SRC_VIVANTE); \
		cd unified_gfx_hal_test;		\
		make -f makefile.linux clean;		\
		make -f makefile.linux install EGL_API_FB=1; \
		cp -rf build/* ../build/ ;
	@echo $@ done
bin_package_vivante20100203: sdk_folders
	@echo start $@
	@-rm -rf $(PKG_NAME_BIN_VIVANTE)
	@echo "Creating package $(PKG_NAME_BIN_VIVANTE)"
	@cd $(TEST_ROOT_DIR)/build_vivante20100203/$(CVS_SRC_VIVANTE); \
           tar cfz $(PKG_NAME_BIN_VIVANTE) build
	@echo $@ done
bin_install_vivante20100203: sdk_folders
	@echo start $@
	@echo $@ done
clean_vivante20100203: sdk_folders
	@echo start $@
	rm -rf $(TEST_ROOT_DIR)/build_vivante20100203
	@echo $@ done
test_vivante20100203: $(mission_vivante20100203)
help_vivante20100203: sdk_folders mktest
	@echo targets: $(mission_vivante20100203) clean_vivante20100203 test_vivante20100203 help_vivante20100203
	@echo $@ done
