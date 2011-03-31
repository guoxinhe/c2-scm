
# Copyright (C) 2007 C2 Microsystems

makefile_test:=echo "nothing todo"
CONFIG_SDK_CONFIGDEF=build.config
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

CONFIG_SDK_RULESDEF=build.rules
ifneq (,$(realpath $(CONFIG_SDK_RULESDEF)))
     include $(realpath $(CONFIG_SDK_RULESDEF))
endif

mktest:
	@$(makefile_test)

#------------------------------------------------------------------------------
.NOTPARALLEL:
