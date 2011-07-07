TODAY                   	:= $(shell date +%y%m%d)
TOP_DIR				:= $(shell /bin/pwd)
SDK_TARGET_ARCH			:= jazz2
SDK_VERSION_ALL			:= $(SDK_TARGET_ARCH)-sdk-$(TODAY)
PKG_DIR				:= $(TOP_DIR)/$(SDK_VERSION_ALL)
TEST_ROOT_DIR			:= $(TOP_DIR)/test_root
SOURCE_DIR			:= $(TOP_DIR)/source
TEMP_DIR			:= $(TOP_DIR)/temp

