# put all global configures here
#-------------------------------------------------------------
TODAY    := $(shell date +%y%m%d)
TOP      := $(shell /bin/pwd)
TOPPKG   := $(TOP)/package-$(TODAY)
TOPTEST  := $(TOP)/test_root
TOPUSR   := $(TOP)/test_usr
TOPSRC   := $(TOP)/source

MYINCFILE=generic.config.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=build.config.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=build.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=local.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
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
	mkdir -p $(TOPTEST)/src_xxx/xxx
	@echo $@ done
src_package_xxx: sdk_folders
	touch $(TOPPKG)/xxx.src.tar.gz
	@echo $@ done
src_install_xxx: sdk_folders
	mkdir -p $(TOPTEST)/build_xxx/xxx
	touch $(TOPTEST)/build_xxx/xxx/xxx.c
	@echo $@ done
src_config_xxx:  sdk_folders
	@echo $@ done
src_build_xxx:   sdk_folders
	touch $(TOPTEST)/build_xxx/xxx/xxx.bin
	@echo $@ done
bin_package_xxx: sdk_folders 
	touch $(TOPPKG)/xxx.bin.tar.gz
	@echo $@ done
bin_install_xxx: sdk_folders
	mkdir -p $(TOPUSR)/xxx/bin
	touch $(TOPUSR)/xxx/bin/xxx
	@echo $@ done
clean_xxx: 
	@echo $@ done
help_xxx: 
	@echo $@ done
test_xxx: $(mission_xxx)
	@echo $@ done

define safelink
    if test -h $2 ; then rm $2;echo old $2 removed;fi
    ln -s $1 $2
endef
sdkautodirs :=  $(TOPPKG) $(TOPTEST) $(TOPUSR) \

.PHONY: sdk_folders lsmod lsop lstest lsall help
$(sdkautodirs):
	@mkdir -p $@
updatetoplink:
	@$(call safelink,$(TOPPKG),p)
sdk_folders: $(sdkautodirs) updatetoplink

lsmod:
	@echo "support mission modules:" $(subst mission_,,"$(mission_modules)")
lsop:
	@echo "support mission operate:" $(shell echo $(subst _xxx,,"$(mission_xxx)") test clean help)
lstest:
	@echo "support mission test   :" $(subst mission_,test_,"$(mission_modules)")
lsall:
	@echo "support mission targets:" $(mission_targets)
help: lsmod lsop lstest lsall
	@echo
