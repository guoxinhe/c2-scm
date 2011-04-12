
# Copyright (C) 2007 C2 Microsystems

makefile_test:=echo "nothing todo"
CONFIG_SDK_CONFIGDEF=build.config.mk
ifneq (,$(realpath $(CONFIG_SDK_CONFIGDEF)))
    include $(realpath $(CONFIG_SDK_CONFIGDEF))
endif

all: 
version:
	# Print out the compiler version used
	c2-linux-gcc -v

clean:
	@echo "BUILD_TARGET: clean"
	rm -rf $(PKG_DIR)
	rm -rf $(TEST_ROOT_DIR)
	rm -rf $(TOP_DIR)/test 
	rm -rf $(TEMP_DIR)
	rm -rf $(TEST_USR_DIR)

CONFIG_SDK_ARCHRULESDEF=$(SDK_TARGET_ARCH).rules.mk
ifneq (,$(realpath $(CONFIG_SDK_ARCHRULESDEF)))
     include $(realpath $(CONFIG_SDK_ARCHRULESDEF))
endif

CONFIG_SDK_RULESDEF=build.rules.mk
ifneq (,$(realpath $(CONFIG_SDK_RULESDEF)))
     include $(realpath $(CONFIG_SDK_RULESDEF))
endif

ifneq (,$(realpath test.rules.mk ))
     include $(realpath test.rules.mk))
endif

ifneq (,$(realpath debug.rules.mk ))
     include $(realpath debug.rules.mk))
endif

ifneq (,$(realpath local.rules.mk ))
     include $(realpath local.rules.mk))
endif

#------------------------------------------------------------------------------
.NOTPARALLEL:
