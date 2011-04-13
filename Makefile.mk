
# Copyright (C) 2007 C2 Microsystems

makefile_test:=echo "nothing todo"
MYINCFILE=build.config.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

all:

version:
	# Print out the compiler version used
	c2-linux-gcc -v

clean:
	@echo "BUILD_TARGET: clean"
	rm -rf $(TEST_ROOT_DIR)
	rm -rf $(TOP_DIR)/test 
	rm -rf $(TEMP_DIR)

cleanall: clean
	rm -rf $(PKG_DIR) log

MYINCFILE=test.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=debug.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=local.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=$(SDK_TARGET_ARCH).rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

MYINCFILE=build.rules.mk
ifneq (,$(realpath $(MYINCFILE)))
     include $(realpath $(MYINCFILE))
endif

#------------------------------------------------------------------------------
.NOTPARALLEL:
