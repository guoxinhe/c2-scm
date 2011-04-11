
mission_devtools := help_devtools clean_devtools       src_get_devtools  \
	src_package_devtools src_install_devtools src_config_devtools src_build_devtools \
	bin_package_devtools bin_install_devtools 
mission_modules += mission_devtools
mission_targets += $(mission_devtools)
.PHONY: $(mission_devtools)


devtools_list += thirdparty
src_get_thirdparty:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_3RDPARTY)
thirdparty:
	@echo $@ Create  $(TEMP_DIR)/devtools/tarballs
	@mkdir -p $(TEMP_DIR)/devtools
	@cp -rf $(SOURCE_DIR)/projects/sw/devtools/3rdParty $(TEMP_DIR)/devtools
	@cd $(TEMP_DIR)/devtools ; \
	    mv 3rdParty tarballs
devtools_list += buildroot
src_get_buildroot:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_BUILDROOT)
buildroot:
	@echo $@
	@cp -rf $(SOURCE_DIR)/projects/sw/devtools/buildroot $(TEMP_DIR)/
	cd $(TEMP_DIR)/buildroot; \
	cp $(DEVTOOLS_AUTOBUILD_CONFIG) autobuild_config; \
		rm autobuild_config_*
	cd $(TEMP_DIR)/; \
	    tar jcf $(BUILDROOT_FILE) \
		--exclude=CVS     \
		--exclude=CVSROOT \
		buildroot; \
	    rm -rf buildroot;
devtools_list += busybox151
src_get_busybox151:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_BUSYBOX_1.5.1)
busybox151:
	@echo $@
	@cd $(SOURCE_DIR)/sw/cmd; \
	    tar jcf $(BUSYBOX_1_5_1_FILE) \
		--exclude=CVS     \
		--exclude=CVSROOT \
		busybox-1.5.1
devtools_list += busybox1131
src_get_busybox1131:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_BUSYBOX_1.13.3)
busybox1131:
	@echo $@
	@cd $(SOURCE_DIR)/sw/cmd; \
	    tar jcf $(BUSYBOX_1_13_3_FILE) \
		--exclude=CVS     \
		--exclude=CVSROOT \
		busybox-1.13.3
devtools_list += i2ctools301
src_get_i2ctools301:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_I2CTOOLS) 
i2ctools301:
	@echo $@
	@cp -rf $(SOURCE_DIR)/$(CVS_SRC_I2CTOOLS) $(TEMP_DIR)/i2c-tools-3.0.1; \
	    cd $(TEMP_DIR) && tar jcf $(I2CTOOLS_FILE) \
	        --exclude=CVS     \
	        --exclude=CVSROOT \
	        i2c-tools-3.0.1; \
	    rm -rf i2c-tools-3.0.1
devtools_list += oprofile
src_get_oprofile:
	@cd $(SOURCE_DIR) && $(CHECKOUT)  $(CVS_SRC_OPROFILE)
oprofile:
	@echo $@
	@cp -arf $(SOURCE_DIR)/$(CVS_SRC_OPROFILE) $(TEMP_DIR)/oprofile-0.9.1; \
	    cd $(TEMP_DIR) && tar jcf $(OPROFILE_FILE) \
	        --exclude=CVS     \
	        --exclude=CVSROOT \
	        oprofile-0.9.1; \
	    rm -rf oprofile-0.9.1
devtools_list += directfb
src_get_directfb:
	@cd $(SOURCE_DIR) && $(CHECKOUT)  $(CVS_SRC_DIRECTFB)
directfb:
	@echo $@
	@cd $(SOURCE_DIR)/projects/sw/directfb; \
	    tar jcf $(DIRECTFB_FILE) \
	        --exclude=CVS      \
	        --exclude=CVSROOT  \
	        DirectFB-1.4.5
devtools_list += binutils
src_get_binutils:	
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_BINUTILS)	
binutils:	
	@echo $@
	@cd $(SOURCE_DIR)/projects/sw/devtools/binutils; \
	    cp -rf binutils $(TEMP_DIR)/binutils-c2.snapshot
	@cd $(TEMP_DIR); \
	    tar jcf $(BINUTILS_FILE) \
		--exclude=CVS \
		--exclude=CVSROOT \
		binutils-c2.snapshot; \
	    rm -rf binutils-c2.snapshot
devtools_list += gccsrc
src_get_gccsrc:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_GCC)
gccsrc:
	@echo $@
	@cd $(SOURCE_DIR)/projects/sw/devtools/gcc; \
	    cp -rf gcc $(TEMP_DIR)/gcc-c2.snapshot
	@cd $(TEMP_DIR); \
	    tar jcf $(GCC_FILE) \
		--exclude=CVS     \
		--exclude=CVSROOT \
		gcc-c2.snapshot ; \
	    rm -rf gcc-c2.snapshot
devtools_list += standalone_build_script
src_get_standalone_build_script:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(STANDALONE_BUILD)
standalone_build_script:
	@echo $@
	cd $(SOURCE_DIR)/$(STANDALONE_BUILD); \
	    cp -f buildtools.sh $(TEMP_DIR)/devtools; \
	    cp -f autobuild $(TEMP_DIR)/devtools; \
	    cp -f uclibc.mk $(TEMP_DIR)/devtools; \
	    cp -f e2fsprogs.mk $(TEMP_DIR)/devtools; \
	    cp -f binutils.mk $(TEMP_DIR)/devtools; \
	    cp -f libpng.mk $(TEMP_DIR)/devtools; \
	    cp -f Config.in $(TEMP_DIR)/devtools; \
	    cp -f gcc-uclibc-3.x.mk.64 $(TEMP_DIR)/devtools; \
	    cp -f gcc-uclibc-3.x.mk $(TEMP_DIR)/devtools; \
	    cp -f binutils.mk.64 $(TEMP_DIR)/devtools
devtools_list += kernel_include
src_get_kernel_include:
	@-cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_KERNEL)
kernel_include:
	@echo $@
	@-rm -rf $(TEMP_DIR)/kernel
	@-cp -rf $(SOURCE_DIR)/$(CVS_SRC_KERNEL) $(TEMP_DIR)/
	@-cd $(TEMP_DIR)/kernel; \
		rm -rf linux-libc-headers-$(SDK_KERNEL_VERSION).0 ; \
		echo FIXME: remove this line: cp -rf $(LINUXDIR) linux-libc-headers-$(SDK_KERNEL_VERSION).0; \
		mkdir -p linux-libc-headers-$(SDK_KERNEL_VERSION).0 ; \
		cp -rf $(LINUXDIR)/include linux-libc-headers-$(SDK_KERNEL_VERSION).0/; \
		cp -f $(SOURCE_DIR)/$(STANDALONE_BUILD)/version.h  \
			linux-libc-headers-$(SDK_KERNEL_VERSION).0/include/linux ; \
		tar jcf $(KERNEL_FILE) \
			--exclude=CVS     \
			--exclude=CVSROOT \
			linux-libc-headers-$(SDK_KERNEL_VERSION).0 ; \
		rm -rf linux-libc-headers-$(SDK_KERNEL_VERSION).0
devtools_list += uclibc
src_get_uclibc:
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_UCLIBC)
uclibc:
	@echo $@
	@cd $(SOURCE_DIR)/projects/sw/devtools/; \
	    cp -rf uClibc $(TEMP_DIR)/uClibc-0.9.27
	@cd $(TEMP_DIR); \
	    tar jcf $(UCLIBC_FILE) \
		--exclude=CVS     \
		--exclude=CVSROOT \
		uClibc-0.9.27 ; \
	    rm -rf uClibc-0.9.27
devtools_list += mxtool
src_get_mxtool:	
	@# mxtool needs to be built and installed in tarballs/bin
	#cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_SW_MEDIA); 
	cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA)/build      ; $(UPDATE);
	cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA)/arch       ; $(UPDATE);
	cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA)/csim       ; $(UPDATE);
	cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA)/intrinsics ; $(UPDATE);
mxtool:	
	@echo $@
	@rm -rf $(TEMP_DIR)/mxtool_tmp/
	@mkdir -p $(TEMP_DIR)/mxtool_tmp
	@cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA); \
	    cp -r build arch csim intrinsics $(TEMP_DIR)/mxtool_tmp
	@# test subdir needs ene tools, so skip building it 
	@cd $(TEMP_DIR)/mxtool_tmp/csim/device/test; mv Makefile Makefile.real
	@cd $(TEMP_DIR)/mxtool_tmp/csim/device/test; echo "all:" > Makefile
	
	@cd $(TEMP_DIR)/mxtool_tmp/build/build; \
	    make BUILD_TARGET=TARGET_LINUX_X86 BOARD_TARGET=C2_CC289 \
		TARGET_ARCH=$(SDK_TARGET_GCC_ARCH)
	@cd $(TEMP_DIR)/mxtool_tmp/arch; \
            make BUILD_TARGET=TARGET_LINUX_X86 BOARD_TARGET=C2_CC289 \
            TARGET_ARCH=$(SDK_TARGET_GCC_ARCH)
	@cd $(TEMP_DIR)/mxtool_tmp/csim; \
            make BUILD_TARGET=TARGET_LINUX_X86 BOARD_TARGET=C2_CC289 \
            TARGET_ARCH=$(SDK_TARGET_GCC_ARCH)
	@cd $(TEMP_DIR)/mxtool_tmp/intrinsics/mpu; \
            make BUILD_TARGET=TARGET_LINUX_X86 BOARD_TARGET=C2_CC289 \
            TARGET_ARCH=$(SDK_TARGET_GCC_ARCH)
	@mkdir -p $(TEMP_DIR)/devtools/tarballs/bin
	@cd $(TEMP_DIR)/mxtool_tmp/intrinsics/mpu/mxtool; \
            make BUILD_TARGET=TARGET_LINUX_X86 BOARD_TARGET=C2_CC289 \
            TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) \
            MXTOOL_INSTALL_DIR=$(TEMP_DIR)/devtools/tarballs \
            install
devtools_list += clean_oldfiles
src_get_clean_oldfiles:
clean_oldfiles:
	@echo $@
	@# Also remove tar files that are part of c2_goodies-src package
	@cd $(TEMP_DIR)/devtools/tarballs; rm -rf $(devtools-tarballs-remove)

$(PKG_NAME_SRC_DEVTOOLS): $(devtools_list)
	@echo Creating $(PKG_NAME_SRC_DEVTOOLS)
	@cd $(TOP_DIR)
	@mkdir -p $(PKG_DIR)
	@cd $(TEMP_DIR) ; tar cvfz $(PKG_NAME_SRC_DEVTOOLS) \
		--exclude=CVS     \
		--exclude=CVSROOT \
		./devtools/tarballs ./devtools/buildtools.sh ./devtools/autobuild \
		./devtools/uclibc.mk ./devtools/e2fsprogs.mk ./devtools/binutils.mk \
		./devtools/libpng.mk ./devtools/Config.in ./devtools/binutils.mk.64 \
		./devtools/gcc-uclibc-3.x.mk ./devtools/gcc-uclibc-3.x.mk.64

src_get_devtools:  sdk_folders $(addprefix src_get_,$(devtools_list))
	@echo $@ done
src_package_devtools: sdk_folders $(PKG_NAME_SRC_DEVTOOLS)
	@echo $@ done
src_install_devtools: sdk_folders 
	@rm -rf $(DEVTOOLS_BUILD_PATH)
	@echo Extract $(PKG_NAME_SRC_DEVTOOLS) to Target folder $(DEVTOOLS_BUILD_PATH)
	@mkdir -p $(DEVTOOLS_BUILD_PATH)
	cd $(DEVTOOLS_BUILD_PATH)/..; \
	    tar xzf $(PKG_NAME_SRC_DEVTOOLS)
	@touch $@
	@echo $@ done
src_config_devtools: sdk_folders
	@echo $@ done
src_build_devtools: sdk_folders 
	cd  $(DEVTOOLS_BUILD_PATH); ./buildtools.sh
	# if the devtools is compiled successfully, will return 0, else error no.
	@cd $(DEVTOOLS_BUILD_PATH)/c2; \
	    ln -s $(TODAY) daily; \
	    ln -s daily sw;
	@echo $@ done
bin_package_devtools: sdk_folders  $(PKG_NAME_BIN_DEVTOOLS)
	@echo $@ done
bin_install_devtools: sdk_folders $(TEST_ROOT_DIR)/c2
	@echo $@ done
clean_devtools: sdk_folders
	@echo $@ remove binary install,build,configure,source install
	rm -rf  $(TEMP_DIR)/devtools $(DEVTOOLS_BUILD_PATH) $(TEST_ROOT_DIR)/c2
	@echo $@ done
test_devtools: $(mission_devtools)
help_devtools: sdk_folders mktest
	@echo 
	@echo targets: $(mission_devtools)
	@echo $@ done
devtools_build_check_bugversion:
	# judge if the devtools is compiled successfully
	@cd  $(DEVTOOLS_BUILD_PATH); \
	if [ $(shell grep 'Moving build files...' $(DEVTOOLS_BUILD_PATH)/tools-build/buildroot/makelog.* |wc -l) -gt 0 ]; then \
	   echo "Devtools compile successfully"; \
	else \
	   echo "Devtools compile failed"; \
	   echo "force does not " exit 1; \
	fi 
	@-cd  $(DEVTOOLS_BUILD_PATH)/c2; \
	    for i in  `ls 1* -d`;do echo $$i;done; ln -s $$i daily;\
	    ln -s daily sw; 
	@touch $@
$(TEST_ROOT_DIR)/c2:
	@echo extract $(PKG_NAME_BIN_DEVTOOLS) to $@ 
	@rm -rf $@
	@cd $(@D); \
	    tar xzf $(PKG_NAME_BIN_DEVTOOLS)
	@touch $@
$(PKG_NAME_BIN_DEVTOOLS): $(DEVTOOLS_BUILD_PATH)/c2
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(<D); \
	    rm $(PKG_NAME_BIN_DEVTOOLS); \
	    tar cfz $(PKG_NAME_BIN_DEVTOOLS) \
		--exclude=c2/$(TODAY)/tmp/*     \
		c2
	@touch $@

mission_sw_media := help_sw_media clean_sw_media       src_get_sw_media  \
	src_package_sw_media src_install_sw_media src_config_sw_media src_build_sw_media \
	bin_package_sw_media bin_install_sw_media 
mission_modules += mission_sw_media
mission_targets += $(mission_sw_media)
.PHONY: $(mission_sw_media)
src_get_sw_media:  sdk_folders
	@if test -d "$(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA)"; then \
	     cd $(SOURCE_DIR)/$(CVS_SRC_SW_MEDIA); $(UPDATE); \
	 else \
	     cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_SW_MEDIA); \
	 fi
	@echo $@ done
src_package_sw_media: sdk_folders $(PKG_NAME_SRC_SW_MEDIA_ALL)
	@echo $@ done
src_install_sw_media: sdk_folders  $(TEMP_DIR)/$(CVS_SRC_SW_MEDIA)
	@echo $@ done
src_config_sw_media: sdk_folders $(PKG_NAME_SRC_SW_MEDIA_2ND) $(PKG_NAME_SRC_SW_MEDIA) 
	@echo $@ done
src_build_sw_media: sdk_folders  $(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA)/$(SW_MEDIA_INSTALL_DIR)
	@echo $@ done
bin_package_sw_media: sdk_folders $(PKG_NAME_BIN_SW_MEDIA) $(PKG_NAME_BIN_SW_MEDIA_QA)
	@echo $@ done
bin_install_sw_media: sdk_folders  $(TEST_ROOT_DIR)/$(SDK_TARGET_ARCH)-sdk/$(CVS_SRC_SW_MEDIA)/$(SW_MEDIA_INSTALL_DIR)
	@echo $@ done
clean_sw_media: sdk_folders
	@echo $@ remove binary install,build,configure,source install
	rm -rf  $(TEMP_DIR)/$(CVS_SRC_SW_MEDIA)  \
		$(TEMP_DIR)/mk_sw_media_3rdsrc \
		$(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA) \
		$(TEST_ROOT_DIR)/$(SDK_TARGET_ARCH)-sdk/$(CVS_SRC_SW_MEDIA) \
		;
	@echo $@ done
test_sw_media: $(mission_sw_media)
help_sw_media: sdk_folders mktest
	@echo 
	@echo targets: $(mission_sw_media)
	@echo $@ done
$(PKG_NAME_SRC_SW_MEDIA_ALL):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(SOURCE_DIR); tar cfz $@ --exclude=CVS --exclude=CVSROOT \
		$(CVS_SRC_SW_MEDIA)
	@touch $@
$(TEMP_DIR)/$(CVS_SRC_SW_MEDIA): $(PKG_NAME_SRC_SW_MEDIA_ALL)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEMP_DIR) ; \
	    tar xzf $<
	@touch $@
$(PKG_NAME_SRC_SW_MEDIA_2ND) : $(TEMP_DIR)/$(CVS_SRC_SW_MEDIA)
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	# Write version information
	@cd $(TEMP_DIR)/$(CVS_SRC_SW_MEDIA)/media/daemon/msp/mspdaemon/; \
	    sed -i '{s, "*".*,"$(SDK_VERSION_ALL)";,g}' mspVersion.h
	@ cd $(TEMP_DIR)/$(CVS_SRC_SW_MEDIA)/build/build/customer/build; \
	    cp globalconfig-C2-PVR-REAL-$(SDK_TARGET_ARCH) globalconfig-C2-PVR
	
	@cd $(TEMP_DIR); \
	    time $(CVS_SRC_SW_MEDIA)/scripts/customizesdk_$(SDK_TARGET_ARCH) $(CVS_SRC_SW_MEDIA) temp_sw_media.tar; \
	    gzip temp_sw_media.tar; \
	    mv temp_sw_media.tar.gz $(PKG_NAME_SRC_SW_MEDIA_2ND); \
	    mv temp_sw_media-bin-test.tar.gz $(PKG_NAME_TEST_BIN_SW_MEDIA)
	@cd $(TEMP_DIR); \
	    if [ -d $(PKG_DIR)/plugins ];then mv $(PKG_DIR)/plugins $(PKG_DIR)/plugins-`date +%Y%m%d%H%M%S` ;fi; \
	    mkdir $(PKG_DIR)/plugins; \
	    for d in *.tar.gz; do \
		mv -f $$d $(PKG_DIR)/plugins/`echo $$d | sed 's/temp_/c2-$(SDK_VERSION_ALL)-/'`; \
	    done
	@touch $@

$(PKG_NAME_SRC_SW_MEDIA): $(PKG_NAME_SRC_SW_MEDIA_2ND)
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@mkdir -p $(TEMP_DIR)/mk_sw_media_3rdsrc; 
	@cd $(TEMP_DIR)/mk_sw_media_3rdsrc; \
	    rm -rf $(CVS_SRC_SW_MEDIA); \
	    tar xfz $(PKG_NAME_SRC_SW_MEDIA_2ND)
	@cd $(TEMP_DIR)/mk_sw_media_3rdsrc/$(CVS_SRC_SW_MEDIA); \
	    rm -rf media/plugins/real; \
	    cp build/build/customer/build/globalconfig-C2-PVR-$(SDK_TARGET_ARCH) \
		build/build/customer/build/globalconfig-C2-PVR
	@cd $(TEMP_DIR)/mk_sw_media_3rdsrc; \
	    tar zcf $(PKG_NAME_SRC_SW_MEDIA) $(CVS_SRC_SW_MEDIA)
	@touch $@
$(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA)/$(SW_MEDIA_INSTALL_DIR): $(PKG_NAME_SRC_SW_MEDIA_2ND)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	@rm -rf  $(@D)/*
	@cd $(TEST_ROOT_DIR); \
	    tar xfz $(PKG_NAME_SRC_SW_MEDIA_2ND); \
	    cd ./$(CVS_SRC_SW_MEDIA); \
	    time make -j5
	@touch $@
$(PKG_NAME_BIN_SW_MEDIA): $(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA)/$(SW_MEDIA_INSTALL_DIR)
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA); \
	    tar zcf $(PKG_NAME_BIN_SW_MEDIA) \
		--exclude=RealPluginModule.plugin.so \
		TARGET_LINUX_C2_$(SDK_TARGET_GCC_ARCH)_RELEASE
	@touch $@
$(PKG_NAME_BIN_SW_MEDIA_QA): $(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA)/$(SW_MEDIA_INSTALL_DIR)
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_SW_MEDIA); \
            tar zcf $(PKG_NAME_BIN_SW_MEDIA_QA) \
                TARGET_LINUX_C2_$(SDK_TARGET_GCC_ARCH)_RELEASE
	@touch $@
$(TEST_ROOT_DIR)/$(SDK_TARGET_ARCH)-sdk/$(CVS_SRC_SW_MEDIA)/$(SW_MEDIA_INSTALL_DIR):$(PKG_NAME_BIN_SW_MEDIA_QA)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(@D); \
	    tar xzf $<
	@touch $@

mission_qt470 := help_qt470 clean_qt470       src_get_qt470  \
	src_package_qt470 src_install_qt470 src_config_qt470 src_build_qt470 \
	bin_package_qt470 bin_install_qt470 
mission_modules += mission_qt470
mission_targets += $(mission_qt470)
.PHONY: $(mission_qt470)
src_get_qt470:  sdk_folders
	@cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_QT470)
	@echo $@ done
src_package_qt470: sdk_folders $(PKG_NAME_SRC_QT470)
	@echo $@ done
src_install_qt470: sdk_folders $(TEST_ROOT_DIR)/$(CVS_SRC_QT470)
	@echo $@ done
src_config_qt470: sdk_folders  $(TEST_ROOT_DIR)/$(CVS_SRC_QT470)
	cd $(TEST_ROOT_DIR)/$(CVS_SRC_QT470) ; \
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
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_QT470) ; \
	TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) DISP_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2 BOARD_TARGET=C2_CC289 BUILD=RELEASE \
	make C2_DEVTOOLS_PATH=$(TOOLCHAIN_PATH)/..
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_QT470) ; \
	TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) DISP_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD_TARGET=TARGET_LINUX_C2 BOARD_TARGET=C2_CC289 BUILD=RELEASE \
	make C2_DEVTOOLS_PATH=$(TOOLCHAIN_PATH)/.. install
	@echo $@ done
bin_package_qt470: sdk_folders $(PKG_NAME_BIN_QT470)
	@echo $@ done
bin_install_qt470: sdk_folders
	@echo $@ done
clean_qt470: sdk_folders
	@echo $@ remove binary install,build,configure,source install
	rm -rf $(TEST_ROOT_DIR)/$(CVS_SRC_QT470) $(TEST_ROOT_DIR)/QtopiaCore-4.7.0-generic
	@echo $@ done
test_qt470: $(mission_qt470)
help_qt470: sdk_folders mktest
	@echo 
	@echo targets: $(mission_qt470)
	@echo $@ done
$(PKG_NAME_SRC_QT470):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(SOURCE_DIR); tar cfz $@ --exclude=CVS --exclude=CVSROOT \
		$(CVS_SRC_QT470)
	@touch $@
$(TEST_ROOT_DIR)/$(CVS_SRC_QT470):$(PKG_NAME_SRC_QT470)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR) ; \
	    tar xzf $<
	@touch $@
$(PKG_NAME_BIN_QT470): $(TEST_ROOT_DIR)/QtopiaCore-4.7.0-generic
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR) ; \
	    tar czf  $(PKG_NAME_BIN_QT470) QtopiaCore-4.7.0-generic
	@touch $@

mission_kernel := help_kernel clean_kernel       src_get_kernel  \
	src_package_kernel src_install_kernel src_config_kernel src_build_kernel \
	bin_package_kernel bin_install_kernel 
mission_modules += mission_kernel
mission_targets += $(mission_kernel)
.PHONY: $(mission_kernel)
src_get_kernel:  sdk_folders
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_KERNEL)
	@echo $@ done
src_package_kernel: sdk_folders $(PKG_NAME_SRC_KERNEL)
	@echo $@ done
src_install_kernel: sdk_folders $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)
	@echo $@ done
src_config_kernel: sdk_folders $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR)/.config
	@echo $@ done
src_build_kernel: sdk_folders $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.bin
	@echo $@ done
bin_package_kernel: sdk_folders $(PKG_NAME_BIN_KERNEL)
	@echo $@ done
bin_install_kernel: sdk_folders
	@echo $@ done
clean_kernel: sdk_folders
	@echo $@ done
test_kernel: $(mission_kernel)
help_kernel: sdk_folders mktest
	@echo targets: $(mission_kernel)
	@echo $@ done
$(PKG_NAME_SRC_KERNEL):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@mkdir -p $(TEMP_DIR)/$(CVS_SRC_KERNEL)
	@cp -rf $(SOURCE_DIR)/$(CVS_SRC_KERNEL) $(TEMP_DIR)/$(CVS_SRC_KERNEL)/..
	@cd $(TEMP_DIR)/$(CVS_SRC_KERNEL) && rm -rf linux-* && cp -rf $(SOURCE_DIR)/$(CVS_SRC_KERNEL)/$(LINUXDIR) .
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
	    tar cfz $(PKG_NAME_SRC_KERNEL) \
    		--exclude=CVS \
    		--exclude=CVSROOT \
    		./$(CVS_SRC_KERNEL); \
	    rm -rf $(CVS_SRC_KERNEL)
	@touch $@
$(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL): $(PKG_NAME_SRC_KERNEL)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR)/kernel_build_sd ; \
	    tar xzf $<
	@touch $@
$(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR)/.config:$(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR)/arch/c2/configs/$(LINUX_CONFIG)
	@cd $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	cp arch/c2/configs/$(LINUX_CONFIG) .config; \
	yes "" |make oldconfig;
	@cd $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL); \
	make initramfs_gen.txt;
$(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.bin:
	@cd $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	time make -j5 ARCH=c2 image ;
$(PKG_NAME_BIN_KERNEL): $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR)/vmlinux.bin
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	mv -f Makefile Makefile.save;\
	echo "image:" > Makefile;
	@cd $(TEST_ROOT_DIR)/kernel_build_sd/; \
		tar cfz $(PKG_NAME_BIN_KERNEL) \
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
	@cd $(TEST_ROOT_DIR)/kernel_build_sd/$(CVS_SRC_KERNEL)/$(LINUXDIR); \
	mv -f Makefile.save Makefile
	@touch $@


mission_kernelnand := help_kernelnand clean_kernelnand       src_get_kernelnand  \
	src_package_kernelnand src_install_kernelnand src_config_kernelnand src_build_kernelnand \
	bin_package_kernelnand bin_install_kernelnand 
mission_modules += mission_kernelnand
mission_targets += $(mission_kernelnand)
.PHONY: $(mission_kernelnand)
src_get_kernelnand:  sdk_folders
	@echo $@ done
src_package_kernelnand: sdk_folders
	@echo $@ done
src_install_kernelnand: sdk_folders $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR)
	@echo $@ done
src_config_kernelnand: sdk_folders
	@echo $@ done
src_build_kernelnand: sdk_folders $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR)/zvmlinux.bin
	@if [ ! -d $(TEST_ROOT_DIR)/prebuilt ];then ln -s $(TEMP_DIR)/kernel_build_nand $(TEST_ROOT_DIR)/prebuilt; fi
	@echo $@ done
bin_package_kernelnand: sdk_folders $(PKG_NAME_BIN_KERNEL_NAND)
	@echo $@ done
bin_install_kernelnand: sdk_folders
	@echo $@ done
clean_kernelnand: sdk_folders
	@echo $@ done
test_kernelnand: $(mission_kernelnand)
help_kernelnand: sdk_folders mktest
	@echo targets: $(mission_kernelnand)
	@echo $@ done
$(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR): $(PKG_NAME_SRC_KERNEL)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEMP_DIR)/kernel_build_nand ; \
	    tar xzf $<
	@touch $@
$(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR)/zvmlinux.bin: $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR)/.config
$(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR)/.config:
	cd $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL); \
	make -j5 -f configs/jazz2-pvr-nand/pvr-nand.mk
$(PKG_NAME_BIN_KERNEL_NAND): $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR)/zvmlinux.bin
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	cd $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR);\
	mv -f Makefile Makefile.save;\
	echo "image:" > Makefile
	cd $(TEMP_DIR)/kernel_build_nand;\
	    tar cfz $(PKG_NAME_BIN_KERNEL_NAND) \
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
	cd $(TEMP_DIR)/kernel_build_nand/$(CVS_SRC_KERNEL)/$(LINUXDIR);\
	mv -f Makefile.save Makefile
	@touch $@

mission_uboot := help_uboot clean_uboot       src_get_uboot  \
	src_package_uboot src_install_uboot src_config_uboot src_build_uboot \
	bin_package_uboot bin_install_uboot
mission_modules += mission_uboot
mission_targets += $(mission_uboot)
.PHONY: $(mission_uboot)
src_get_uboot:  sdk_folders
	@cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_UBOOT)
	@echo $@ done
src_package_uboot: sdk_folders $(PKG_NAME_SRC_UBOOT) 
	@echo $@ done
src_install_uboot: sdk_folders $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)
	@echo $@ done
src_config_uboot: sdk_folders
	@echo $@ done
src_build_uboot: sdk_folders  $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)/$(uboot_utilities)
	@echo $@ done
bin_package_uboot: sdk_folders $(PKG_NAME_BIN_UBOOT)
	@echo $@ done
bin_install_uboot: sdk_folders
	@echo $@ done
clean_uboot: sdk_folders
	@echo $@ done
test_uboot: $(mission_uboot)
help_uboot: sdk_folders mktest
	@echo targets: $(mission_uboot)
	@echo $@ done
$(PKG_NAME_SRC_UBOOT):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(SOURCE_DIR); \
	    tar cfz $(PKG_NAME_SRC_UBOOT) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        $(CVS_SRC_UBOOT)
	@touch $@
$(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT): $(PKG_NAME_SRC_UBOOT)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $<
	@touch $@
$(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)/$(uboot_utilities):
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT); \
		./build.sh jazz2;
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT); \
	    touch $(uboot_utilities)
$(PKG_NAME_BIN_UBOOT): $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT)/$(uboot_utilities)
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_UBOOT); \
		tar cfz $(PKG_NAME_BIN_UBOOT) $(uboot_utilities)
	@touch $@


mission_vivante := help_vivante clean_vivante       src_get_vivante  \
	src_package_vivante src_install_vivante src_config_vivante src_build_vivante \
	bin_package_vivante bin_install_vivante
mission_modules += mission_vivante
mission_targets += $(mission_vivante)
.PHONY: $(mission_vivante)
src_get_vivante:  sdk_folders
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_VIVANTE)
	@echo $@ done
src_package_vivante: sdk_folders $(PKG_NAME_SRC_VIVANTE)  $(PKG_NAME_TEST_SRC_VIVANTE)
	@echo $@ done
src_install_vivante: sdk_folders  $(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE)
	@echo $@ done
src_config_vivante: sdk_folders
	@echo $@ done
src_build_vivante: sdk_folders $(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE)/build/sdk/drivers/galcore.ko
	@echo $@ done
bin_package_vivante: sdk_folders $(PKG_NAME_BIN_VIVANTE)
	@echo $@ done
bin_install_vivante: sdk_folders
	@echo $@ done
clean_vivante: sdk_folders
	@echo $@ done
test_vivante: $(mission_vivante)
help_vivante: sdk_folders mktest
	@echo targets: $(mission_vivante)
	@echo $@ done
$(PKG_NAME_SRC_VIVANTE):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(SOURCE_DIR); \
	   tar cfz $(PKG_NAME_SRC_VIVANTE) \
		--exclude=CVS \
		--exclude=CVSROOT \
		$(CVS_SRC_VIVANTE)
	@touch $@
$(PKG_NAME_TEST_SRC_VIVANTE):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(SOURCE_DIR); \
	   tar cfz $(PKG_NAME_TEST_SRC_VIVANTE) \
		--exclude=CVS \
		--exclude=CVSROOT \
		$(CVS_SRC_VIVANTE)/gfxtst
	@touch $@
$(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE):$(PKG_NAME_SRC_VIVANTE)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $<
	@touch $@
$(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE)/build/sdk/drivers/galcore.ko: 
$(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE)/build:
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE); \
		make KERNELDIR=$(KERNEL_PATH) install
	@touch $@
$(PKG_NAME_BIN_VIVANTE):$(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE)/build
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_VIVANTE); \
           tar cfz $(PKG_NAME_BIN_VIVANTE) build
	@touch $@

mission_hdmi := help_hdmi clean_hdmi       src_get_hdmi  \
	src_package_hdmi src_install_hdmi src_config_hdmi src_build_hdmi \
	bin_package_hdmi bin_install_hdmi
mission_modules += mission_hdmi
mission_targets += $(mission_hdmi)
.PHONY: $(mission_hdmi)
src_get_hdmi:  sdk_folders
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_HDMI_JAZZ2)
	@echo $@ done
src_package_hdmi: sdk_folders $(PKG_NAME_SRC_HDMI_JAZZ2)
	@echo $@ done
src_install_hdmi: sdk_folders $(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv
	@echo $@ done
src_config_hdmi: sdk_folders
	@echo $@ done
src_build_hdmi: sdk_folders  $(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko
	@echo $@ done
bin_package_hdmi: sdk_folders $(PKG_NAME_BIN_HDMI_JAZZ2)
	@echo $@ done
bin_install_hdmi: sdk_folders
	@echo $@ done
clean_hdmi: sdk_folders
	@echo $@ done
test_hdmi: $(mission_hdmi)
help_hdmi: sdk_folders mktest
	@echo targets: $(mission_hdmi)
	@echo $@ done
$(PKG_NAME_SRC_HDMI_JAZZ2):
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@rm -rf $(TEMP_DIR)/PROPRIETARY; \
	mkdir -p $(TEMP_DIR)/PROPRIETARY; \
	cp -arf $(SOURCE_DIR)/$(CVS_SRC_HDMI_JAZZ2) $(TEMP_DIR)/PROPRIETARY;
	@cd $(TEMP_DIR); \
	   tar cfz $(PKG_NAME_SRC_HDMI_JAZZ2) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        ./PROPRIETARY/jazz2hdmi
	@touch $@
$(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv: $(PKG_NAME_SRC_HDMI_JAZZ2)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $<
	@touch $@
$(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko:
	@cd $(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv; \
		make KERNELDIR=$(KERNEL_PATH)
$(PKG_NAME_BIN_HDMI_JAZZ2):$(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/PROPRIETARY; \
	    tar cfz $(PKG_NAME_BIN_HDMI_JAZZ2) \
		jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko
	@touch $@

mission_c2box := help_c2box clean_c2box       src_get_c2box  \
	src_package_c2box src_install_c2box src_config_c2box src_build_c2box \
	bin_package_c2box bin_install_c2box
mission_modules += mission_c2box
mission_targets += $(mission_c2box)
.PHONY: $(mission_c2box)
src_get_c2box:  sdk_folders
	@if test -d "$(SOURCE_DIR)/$(CVS_SRC_SW_C2APPS)" ; then \
	     cd $(SOURCE_DIR)/$(CVS_SRC_SW_C2APPS); $(UPDATE); \
         else \
             cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_SW_C2APPS); \
         fi
	@echo $@ done
src_package_c2box: sdk_folders
	@mkdir -p $(PKG_DIR)/c2box
	@cd $(TEMP_DIR); rm -rf $(CVS_SRC_SW_C2APPS); \
	    cp -rf $(SOURCE_DIR)/$(CVS_SRC_SW_C2APPS) .
	@cd $(TEMP_DIR)/$(CVS_SRC_SW_C2APPS)/pvr/filemanager/include; \
            sed -i '{s, ".*","$(SDK_VERSION_ALL)-$(BUILDTIMES)",g}' version.h
	
	@rm -f $(PKG_NAME_SRC_SW_C2APPS)
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_SW_C2APPS) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        --exclude=ipcam \
		--exclude=dtv \
		--exclude=p2p/PiPlugin \
		--exclude=p2p/httpPlugin \
		--exclude=p2p/tplugin \
		--exclude=p2p/yt \
		--exclude=p2p/libThunderPlugin \
		--exclude=filemanager \
	        $(CVS_SRC_SW_C2APPS)
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_C2BOX_ALL) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        --exclude=ipcam \
		--exclude=dtv \
		--exclude=p2p/PiPlugin \
		--exclude=p2p/httpPlugin \
		--exclude=p2p/tplugin \
		--exclude=p2p/yt \
		--exclude=p2p/libThunderPlugin \
		--exclude=filemanager2 \
	        $(CVS_SRC_SW_C2APPS)
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_C2BOX) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        --exclude=ipcam \
		--exclude=dtv \
		--exclude=p2p/PiPlugin \
		--exclude=p2p/httpPlugin \
		--exclude=p2p/tplugin \
		--exclude=p2p/yt \
		--exclude=p2p/libThunderPlugin \
		--exclude=filemanager2 \
		--exclude=apps/discs \
		--exclude=apps/flash \
		--exclude=apps/karaoke \
		--exclude=apps/videochat \
		--exclude=apps/thunderkk \
		--exclude=apps/videophone \
		--exclude=apps/dtv \
		--exclude=apps/pps \
		--exclude=apps/browser \
		--exclude=apps/camera \
		--exclude=apps/jvm \
		--exclude=apps/sohu \
		--exclude=apps/capture \
	        $(CVS_SRC_SW_C2APPS)
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_MINIBD) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/discs
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_FLASH) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/flash
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_KARAOKE) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/karaoke
	@if [ "$(SDK_TARGET_ARCH)" != "jazz2l" ]; then \
	cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_VIDEOCHAT) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/videochat; \
	fi
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_THUNDERKK) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/thunderkk
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_MVPHONE) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/videophone
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_BROWSER) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/browser
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_IPCAM) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/camera
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_JVM) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/jvm
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_RECOEDING) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/capture
	@cd $(TEMP_DIR); \
	    tar zcf $(PKG_NAME_SRC_SOHU) \
		--exclude=CVS \
		$(CVS_SRC_SW_C2APPS)/pvr/filemanager/apps/sohu
	@rm -rf $(TEMP_DIR)/$(CVS_SRC_SW_C2APPS)
	
	@echo $@ done
src_install_c2box: sdk_folders $(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_C2APPS)
	@echo $@ done
src_config_c2box: sdk_folders
	@echo $@ done
src_build_c2box: sdk_folders  $(TEST_ROOT_DIR)/$(PRODUCT)/work \
	$(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko \
	$(PKG_NAME_BIN_VIVANTE)
	cd $(TEST_ROOT_DIR)/$(PRODUCT);cp -f $(TEST_ROOT_DIR)/PROPRIETARY/jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko work/lib
	cd $(TEST_ROOT_DIR)/$(PRODUCT);tar xfz $(PKG_NAME_BIN_VIVANTE) ;\
		cp -f build/sdk/drivers/libGAL.so           work/lib/ ;\
		cp -f build/sdk/drivers/galcore.ko          work/lib/ ;\
		cp -f build/sdk/drivers/libdirectfb_gal.so  work/lib/ ;\
	
	@echo $@ done
	@touch $(TEST_ROOT_DIR)/$(PRODUCT)/work
bin_package_c2box: sdk_folders $(PKG_NAME_C2BOX_DEMO) $(PKG_NAME_BIN_TOOLS)
	@echo $@ done
bin_install_c2box: sdk_folders
	@echo $@ done
clean_c2box: sdk_folders
	@echo $@ done
test_c2box: $(mission_c2box)
help_c2box: sdk_folders mktest
	@echo targets: $(mission_c2box)
	@echo $@ done
$(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_C2APPS): $(PKG_NAME_SRC_C2BOX_ALL)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR)/$(PRODUCT); \
	    tar xzf $<
	@touch $@
$(TEST_ROOT_DIR)/$(PRODUCT)/work: \
	override PATH := $(TOOLCHAIN_PATH):/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$(HOME)/bin:$(QT_INSTALL_DIR)/bin
$(TEST_ROOT_DIR)/$(PRODUCT)/work: $(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_C2APPS)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_C2APPS); \
		BUILD_TARGET=TARGET_LINUX_C2 TARGET_ARCH=$(SDK_TARGET_GCC_ARCH) BUILD=RELEASE \
		SW_MEDIA_PATH=$(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_MEDIA) \
		ENABLE_NEW_APP=TRUE make install; \
		rm -rf ../work; \
		cp -a work ../
	@touch $@
$(PKG_NAME_C2BOX_DEMO):$(TEST_ROOT_DIR)/$(PRODUCT)/work
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(PRODUCT); \
		tar cfz $(PKG_NAME_C2BOX_DEMO) work	
	@touch $@
$(PKG_NAME_BIN_TOOLS): $(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_C2APPS)
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(PRODUCT)/$(CVS_SRC_SW_C2APPS); \
		tar cfz $@ tools
	@touch $@

mission_jtag := help_jtag clean_jtag src_get_jtag  \
	src_package_jtag src_install_jtag src_config_jtag src_build_jtag \
	bin_package_jtag bin_install_jtag
mission_modules += mission_jtag
mission_targets += $(mission_jtag)
.PHONY: $(mission_jtag)
src_get_jtag:  sdk_folders
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_JTAG)
	@echo $@ done
src_package_jtag: sdk_folders
	@cd $(TEMP_DIR); \
	    mkdir -p $(CVS_SRC_JTAG); \
	    cd $(TEMP_DIR)/$(CVS_SRC_JTAG); \
	    cp -rf $(SOURCE_DIR)/$(CVS_SRC_JTAG) ../
	
	@echo "Creating package $(PKG_NAME_SRC_JTAG)"
	@cd $(TEMP_DIR); \
	    tar cfz $(PKG_NAME_SRC_JTAG) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
	        $(CVS_SRC_JTAG)
	@echo $@ done
src_install_jtag: sdk_folders $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)
	@echo $@ done
src_config_jtag: sdk_folders
	cd $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/jtag-client; \
	./configure --prefix=/usr/local --enable-bus=C2 openwince_includes_path="$(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/include"; 
	@echo $@ done
src_build_jtag: sdk_folders
	cd $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/jtag-client; \
	make; \
	make install prefix=$(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/usr/local;
	@touch $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/usr/local
	@echo $@ done
bin_package_jtag: sdk_folders $(PKG_NAME_BIN_JTAG)
	@echo $@ done
bin_install_jtag: sdk_folders
	@echo $@ done
clean_jtag: sdk_folders
	@echo $@ done
test_jtag: $(mission_jtag)
help_jtag: sdk_folders mktest
	@echo targets: $(mission_jtag)
	@echo $@ done
$(TEST_ROOT_DIR)/$(CVS_SRC_JTAG): $(PKG_NAME_SRC_JTAG)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $<
	@touch $@
$(PKG_NAME_BIN_JTAG): $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/usr/local
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cp -Rd $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/jtag_loader \
		$(TEST_ROOT_DIR)/$(CVS_SRC_JTAG)/usr/local/share
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_JTAG); \
		tar cvzf $(PKG_NAME_BIN_JTAG) usr
	@touch $@

mission_diag := help_diag clean_diag src_get_diag  \
	src_package_diag src_install_diag src_config_diag src_build_diag \
	bin_package_diag bin_install_diag
mission_modules += mission_diag
mission_targets += $(mission_diag)
.PHONY: $(mission_diag)
src_get_diag:  sdk_folders
	@cd $(SOURCE_DIR); $(CHECKOUT) $(CVS_SRC_DIAG)
	@cd $(SOURCE_DIR) && $(CHECKOUT) $(CVS_SRC_JTAG)
	@echo $@ done
src_package_diag: sdk_folders
	@echo "BUILD TARGET: diag-src"
	@rm -f $(PKG_NAME_SRC_DIAG)
	@cd $(TEMP_DIR); \
	    mkdir -p $(CVS_SRC_DIAG); \
	    mkdir -p $(CVS_SRC_JTAG); \
	    cd $(CVS_SRC_DIAG); \
	    cp -rf $(SOURCE_DIR)/$(CVS_SRC_DIAG) ../; \
	    cd $(TEMP_DIR)/$(CVS_SRC_JTAG); \
	    cp -rf $(SOURCE_DIR)/$(CVS_SRC_JTAG) ../
	
	@echo "Creating package $(PKG_NAME_SRC_DIAG)"
	@cd $(TEMP_DIR); \
	    tar cfz $(PKG_NAME_SRC_DIAG) \
	        --exclude=CVS \
	        --exclude=CVSROOT \
		$(CVS_SRC_DIAG)/example \
		$(CVS_SRC_DIAG)/include \
		$(CVS_SRC_DIAG)/jtag_scripts \
		$(CVS_SRC_DIAG)/lib \
		$(CVS_SRC_DIAG)/loader \
		$(CVS_SRC_DIAG)/Makefile \
		$(CVS_SRC_DIAG)/moduledefs \
		$(CVS_SRC_DIAG)/modulerules \
		$(CVS_SRC_DIAG)/test \
	
	@echo $@ done
src_install_diag: sdk_folders $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG)
	@echo $@ done
src_config_diag: sdk_folders
	@echo $@ done
src_build_diag: sdk_folders 
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG); \
	    make BOARD=cc427 MPUCLK=400 MEMCLK=400 clean; \
	    make BOARD=cc427 MPUCLK=400 MEMCLK=400
	touch $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG)/loader
	@echo $@ done
bin_package_diag: sdk_folders $(PKG_NAME_BIN_DIAG)
	@echo $@ done
bin_install_diag: sdk_folders
	@echo $@ done
clean_diag: sdk_folders
	@echo $@ done
test_diag: $(mission_diag)
help_diag: sdk_folders mktest
	@echo targets: $(mission_diag)
	@echo $@ done
$(TEST_ROOT_DIR)/$(CVS_SRC_DIAG): $(PKG_NAME_SRC_DIAG)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $<
	@touch $@
$(PKG_NAME_BIN_DIAG):  $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG)/loader
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/$(CVS_SRC_DIAG)/loader; \
	    tar cvzf $(PKG_NAME_BIN_DIAG) \
	        spiromjazz2.rom \
	        README*         \
	        evectors.bin loader.bin *.scr
	@touch $@

mission_c2_goodies := help_c2_goodies clean_c2_goodies src_get_c2_goodies  \
	src_package_c2_goodies src_install_c2_goodies src_config_c2_goodies src_build_c2_goodies \
	bin_package_c2_goodies bin_install_c2_goodies
mission_modules += mission_c2_goodies
mission_targets += $(mission_c2_goodies)
.PHONY: $(mission_c2_goodies)
src_get_c2_goodies:  sdk_folders
	@echo "Checkout fusepod sources"
	@cd $(SOURCE_DIR)/c2_goodies && $(CHECKOUT) -d fusepod $(FUSEPOD_SCRIPT); 
	@cd $(SOURCE_DIR)/c2_goodies/fusepod && $(CHECKOUT) -d dist $(DJMOUNT_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/fusepod && $(CHECKOUT) -d dist $(FUSEPOD_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/fusepod && $(CHECKOUT) -d dist $(LIBGPOD_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/fusepod && $(CHECKOUT) -d dist $(FUSE_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/fusepod && $(CHECKOUT) -d dist $(GLIB_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/fusepod && $(CHECKOUT) -d dist $(TAGLIB_PKG);
	
	@echo "Checkout perl sources"
	@cd $(SOURCE_DIR)/c2_goodies && $(CHECKOUT) -d perl $(PERL_SCRIPT); 
	@cd $(SOURCE_DIR)/c2_goodies/perl && $(CHECKOUT) -d dist $(PERL_PKG); 
	
	@echo "Checkout snoopy sources"
	@cd $(SOURCE_DIR)/c2_goodies && $(CHECKOUT) -d snoopy $(CVS_SRC_SNOOPY); 
	
	@echo "Checkout hdd library sources"
	@cd $(SOURCE_DIR)/c2_goodies && $(CHECKOUT) -d hdd $(HDD_SCRIPT); 
	@cd $(SOURCE_DIR)/c2_goodies/hdd && $(CHECKOUT) -d dist $(SAMBA_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/hdd && $(CHECKOUT) -d dist $(LIBUSB_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/hdd && $(CHECKOUT) -d dist $(LIBPTP_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/hdd && $(CHECKOUT) -d dist $(NTFS_PKG); 
	@cd $(SOURCE_DIR)/c2_goodies/hdd && $(CHECKOUT) -d dist $(NTFSPROGS_PKG); 
	
	@echo "Checkout benchmark sources"
	@cd $(SOURCE_DIR)/c2_goodies && $(CHECKOUT) -d benchmark $(BENCHMARK_SCRIPT);
	@cd $(SOURCE_DIR)/c2_goodies/benchmark && $(CHECKOUT) -d dist $(BONNIE_PKG);
	@cd $(SOURCE_DIR)/c2_goodies/benchmark && $(CHECKOUT) -d dist $(IOZONE_PKG);
	@cd $(SOURCE_DIR)/c2_goodies/benchmark && $(CHECKOUT) -d dist $(LMBENCH_PKG);
	@cd $(SOURCE_DIR)/c2_goodies/benchmark && $(CHECKOUT) -d dist $(UNIXBENCH_PKG);
	@cd $(SOURCE_DIR)/c2_goodies/benchmark && $(CHECKOUT) -d dist $(IPERF_PKG);
	@cd $(SOURCE_DIR)/c2_goodies/benchmark && $(CHECKOUT) -d dist $(NETPERF_PKG);
	
	@echo "Checkout ethertools source"
	@cd $(SOURCE_DIR)/c2_goodies && $(CHECKOUT) -d ethertool $(ETHERTOOL_PKG);
	@echo $@ done
src_package_c2_goodies: sdk_folders
	@rm -f $(PKG_NAME_SRC_GOODIES)
	@echo "Creating package $(PKG_NAME_SRC_GOODIES)"
	@cd $(SOURCE_DIR); \
	tar cfz $(PKG_NAME_SRC_GOODIES) \
    		--exclude=CVS \
    		--exclude=CVSROOT \
    		./c2_goodies
	@echo $@ done
src_install_c2_goodies: sdk_folders $(TEST_ROOT_DIR)/c2_goodies
	@echo $@ done
src_config_c2_goodies: sdk_folders
	@echo $@ done
src_build_c2_goodies: sdk_folders
	@# fusepod
	@cd $(TEST_ROOT_DIR)/c2_goodies/fusepod; \
             ./build-fusepod.sh
	
	@# perl
	@cd $(TEST_ROOT_DIR)/c2_goodies/perl; \
             ./build-microperl.sh
	
	@# snoopy
	@cd $(TEST_ROOT_DIR)/c2_goodies/snoopy; \
             make TARGET_ARCH=$(SDK_TARGET_GCC_ARCH)
	
	@# hdd
	@cd $(TEST_ROOT_DIR)/c2_goodies/hdd; \
	     ./sdk-build-hdd.sh
	
	@cd $(TEST_ROOT_DIR)/c2_goodies/benchmark; \
	     ./build-benchmark.sh
	
	@cd $(TEST_ROOT_DIR)/c2_goodies/ethertool; \
	     mkdir install; tar -xzf ethtool-6.tar.gz; cd ethtool-6; \
	     ./configure --host=c2-linux \
	       --prefix=$(TEST_ROOT_DIR)/c2_goodies/ethertool/install; \
	     make; make install
	@echo $@ done
bin_package_c2_goodies: sdk_folders $(PKG_NAME_BIN_GOODIES)
	@echo $@ done
bin_install_c2_goodies: sdk_folders
	@echo $@ done
clean_c2_goodies: sdk_folders
	@echo $@ done
test_c2_goodies: $(mission_c2_goodies)
help_c2_goodies: sdk_folders mktest
	@echo targets: $(mission_c2_goodies)
	@echo $@ done
$(TEST_ROOT_DIR)/c2_goodies: $(PKG_NAME_SRC_GOODIES)
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(TEST_ROOT_DIR); \
	    tar xzf $<
	@touch $@
$(PKG_NAME_BIN_GOODIES):  $(TEST_ROOT_DIR)/c2_goodies
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR)/; \
	   tar cfz $(PKG_NAME_BIN_GOODIES) \
    		./c2_goodies/fusepod/install \
		./c2_goodies/perl/perl-5.8.8 \
		./c2_goodies/snoopy/snoopy \
		./c2_goodies/hdd/install \
	        ./c2_goodies/benchmark/install \
		./c2_goodies/ethertool/install
	@touch $@

factory_udisk:sdk_folders
	rm -rf $(TEST_ROOT_DIR)/home $(TEST_ROOT_DIR)/work
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_UBOOT) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_KERNEL_NAND)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_C2BOX_DEMO) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_HDMI_JAZZ2)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_VIVANTE)
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

user_udisk:sdk_folders
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_TOOLS)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_KERNEL_NAND)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_C2BOX_DEMO) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_UBOOT) 
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_HDMI_JAZZ2)
	cd $(TEST_ROOT_DIR) ; tar xzf $(PKG_NAME_BIN_VIVANTE)
	cd $(TEST_ROOT_DIR) ; cp -f jazz2hdmi/jazz2hdmi_drv/hdmi_jazz2.ko work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/libGAL.so           work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/galcore.ko          work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f build/sdk/drivers/libdirectfb_gal.so  work/lib/
	cd $(TEST_ROOT_DIR) ; cp -f sw/kernel/linux-2.6/zvmlinux.bin .
	cd $(TEST_ROOT_DIR) ; cp -f sw/kernel/rootfs.image .
	cd $(TEST_ROOT_DIR) ; $(BIN_MKIMAGE) -A c2 -O linux -T kernel -C none -a a0000000 -e 80000800 -n kernel -d zvmlinux.bin uImage.bin
	cd $(TEST_ROOT_DIR) ; ./tools/updateFileGenerate/createArchive uImage.bin rootfs.image work -v "the version no."
	cd $(TEST_ROOT_DIR) ; cp -f c2_update.tar $(PKG_NAME_BIN_USER_UDISK)

mission_facudisk := help_facudisk clean_facudisk src_get_facudisk  \
	src_package_facudisk src_install_facudisk src_config_facudisk src_build_facudisk \
	bin_package_facudisk bin_install_facudisk
mission_modules += mission_facudisk
mission_targets += $(mission_facudisk)
.PHONY: $(mission_facudisk)
src_get_facudisk:  sdk_folders
	@echo $@ done
src_package_facudisk: sdk_folders
	@echo $@ done
src_install_facudisk: sdk_folders
	@echo $@ done
src_config_facudisk: sdk_folders
	@echo $@ done
src_build_facudisk: sdk_folders
	@echo $@ done
bin_package_facudisk: sdk_folders factory_udisk
	@echo $@ done
bin_install_facudisk: sdk_folders
	@echo $@ done
clean_facudisk: sdk_folders
	@echo $@ done
test_facudisk: $(mission_facudisk)
help_facudisk: sdk_folders mktest
	@echo targets: $(mission_facudisk)

mission_usrudisk := help_usrudisk clean_usrudisk src_get_usrudisk  \
	src_package_usrudisk src_install_usrudisk src_config_usrudisk src_build_usrudisk \
	bin_package_usrudisk bin_install_usrudisk
mission_modules += mission_usrudisk
mission_targets += $(mission_usrudisk)
.PHONY: $(mission_usrudisk)
src_get_usrudisk:  sdk_folders
	@echo $@ done
src_package_usrudisk: sdk_folders
	@echo $@ done
src_install_usrudisk: sdk_folders
	@echo $@ done
src_config_usrudisk: sdk_folders
	@echo $@ done
src_build_usrudisk: sdk_folders
	@echo $@ done
bin_package_usrudisk: sdk_folders user_udisk
	@echo $@ done
bin_install_usrudisk: sdk_folders
	@echo $@ done
clean_usrudisk: sdk_folders
	@echo $@ done
test_usrudisk: $(mission_usrudisk)
help_usrudisk: sdk_folders mktest
	@echo targets: $(mission_usrudisk)


# example code
# the src_get_xxx never depend on anything
# the src_install_xxx never depend on anything
mission_xxx := help_xxx clean_xxx src_get_xxx  \
	src_package_xxx src_install_xxx src_config_xxx src_build_xxx \
	bin_package_xxx bin_install_xxx
mission_modules += mission_xxx
mission_targets += $(mission_xxx)
.PHONY: $(mission_xxx)
src_get_xxx:  sdk_folders
	@mkdir -p $(TEMP_DIR)/xxx
	@echo "int main(int argc, char **argv){return argv[argc-1][0];}" >$(TEMP_DIR)/xxx/xxx.c
	@echo "all:xxx"    		 >$(TEMP_DIR)/xxx/Makefile
	@echo "xxx:xxx.c" 		>>$(TEMP_DIR)/xxx/Makefile
	@echo "	gcc xxx.c -o xxx" 	>>$(TEMP_DIR)/xxx/Makefile
	@echo $@ done
src_package_xxx: sdk_folders $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-xxx.src.tar.gz
	@echo $@ done
src_install_xxx: sdk_folders $(TEST_ROOT_DIR)/xxx
	@echo $@ done
src_config_xxx: sdk_folders
	@echo $@ done
src_build_xxx: sdk_folders
	@cd $(TEST_ROOT_DIR)/xxx; \
		make
	@echo $@ done
bin_package_xxx: sdk_folders $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-xxx.bin.tar.gz
	@echo $@ done
bin_install_xxx: sdk_folders $(TEST_USR_DIR)/xxx
	@echo $@ done
clean_xxx: sdk_folders
	rm -rf $(TEMP_DIR)/xxx $(TEST_ROOT_DIR)/xxx $(TEST_USR_DIR)/xxx
	@echo $@ don
test_xxx: $(mission_xxx)
help_xxx: sdk_folders mktest
	@echo targets: $(mission_xxx)
	@echo $@ done
$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-xxx.src.tar.gz:
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEMP_DIR); tar cfz $@ --exclude=CVS --exclude=CVSROOT \
		xxx
	@touch $@
$(TEST_ROOT_DIR)/xxx: $(PKG_DIR)/c2-$(SDK_VERSION_ALL)-xxx.src.tar.gz
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(@D) ; \
	    tar xzf $<
	@touch $@
$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-xxx.bin.tar.gz:
	if [ -f $@ ]; then rm $@;fi
	@echo "Creating package $@" depend on $<
	@mkdir -p $(@D)
	@cd $(TEST_ROOT_DIR); tar cfz $@ --exclude=CVS --exclude=CVSROOT \
		xxx
	@touch $@
$(TEST_USR_DIR)/xxx:$(PKG_DIR)/c2-$(SDK_VERSION_ALL)-xxx.bin.tar.gz
	@rm -rf $@
	@echo Extract $< to Target folder $@
	@mkdir -p $(@D)
	cd $(@D) ; \
	    tar xzf $<
	@touch $@
	

sdkautodirs :=  $(TEST_ROOT_DIR) $(TEMP_DIR) $(PKG_DIR) $(TEST_USR_DIR)
.PHONY: sdk_folders ls mktest mc help
sdk_folders: $(sdkautodirs)
$(sdkautodirs):
	@mkdir -p $@
ls:
	@echo support mission targets: $(mission_targets) 
mktest:
	@$(call makefile_test)
mc help: mktest
	@echo
	@echo "support mission        :" $(shell echo $(subst _xxx,,"$(mission_xxx)") test)
	@echo "support mission modules:" $(subst mission_,,"$(mission_modules)")
	@echo "support mission test   :" $(subst mission_,test_,"$(mission_modules)")
	@echo

$(definedenvlist):
	@echo ${$@}
