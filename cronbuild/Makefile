# put all global configures here
#-------------------------------------------------------------
TODAY                   	:= $(shell date +%y%m%d)
TOP_DIR				:= $(shell /bin/pwd)
SDK_TARGET_ARCH			:= jazz2
SDK_VERSION_ALL			:= $(SDK_TARGET_ARCH)-sdk-$(TODAY)
PKG_DIR				:= $(TOP_DIR)/$(SDK_VERSION_ALL)
TEST_ROOT_DIR			:= $(TOP_DIR)/test_root
SOURCE_DIR			:= $(TOP_DIR)/source
TEMP_DIR			:= $(TOP_DIR)/temp
varlist := TODAY TOP_DIR SDK_TARGET_ARCH SDK_VERSION_ALL PKG_DIR TEST_ROOT_DIR SOURCE_DIR TEMP_DIR

mklist :=
MYINCFILE := build.config.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
     mklist += $(MYINCFILE)
endif

MYINCFILE := build.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
     mklist += $(MYINCFILE)
endif

MYINCFILE := local.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
     mklist += $(MYINCFILE)
endif

#-------------------------------------------------------------
all: test_xxx

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

define safelink
    if test -h $2 ; then rm $2;fi
    ln -s $1 $2
endef
sdkautodirs :=  $(PKG_DIR) $(TEST_ROOT_DIR)/usr/bin

.PHONY: sdk_folders lsmod lsop lstest lsall help
$(sdkautodirs):
	@mkdir -p $@
updatetoplink:
	@$(call safelink,$(PKG_DIR),p)
sdk_folders: $(sdkautodirs) updatetoplink

lsmod:
	@echo "support mission modules:" $(subst mission_,,"$(mission_modules)")
lsop:
	@echo "support mission operate:" $(shell echo $(subst _xxx,,"$(mission_xxx)") test clean help)
lstest:
	@echo "support mission test   :" $(subst mission_,test_,"$(mission_modules)")
lsall:
	@echo "support mission targets:" $(mission_targets)
lsmk:
	@echo "included files         :" $(mklist)
lsvar: lsvars $(varlist)
.PHONY: lsvars  $(varlist)
lsvars:
	@echo $(varlist)
$(varlist):
	@echo $($@)


help: lsmod lsop lstest lsall
	@echo Global defined variables: $(varlist)
