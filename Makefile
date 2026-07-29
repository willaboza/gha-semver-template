# ====================================================
# Low Power Location Data Logger - Root Makefile
# ====================================================

# Toolchain definitions
CC_ARM      := arm-none-eabi-gcc
CC_HOST     := gcc
CLANG_FMT   := clang-format
CPPCHECK    := cppcheck

# Dynamic Semantic Versioning (defaults to 'dev' if no git tag found)
VERSION     := $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0-dev")

# Compiler flags
CFLAGS_ARM  := -c -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -DFIRMWARE_VERSION=\"$(VERSION)\" -I src/
CFLAGS_HOST := -I src/
LINT_FLAGS  := --enable=all --suppress=missingIncludeSystem --error-exitcode=1 --inline-suppr -I src/

# Directories
SRC_DIR     := src
TEST_DIR    := tests
BUILD_DIR   := build

# Default target: build target firmware
all: target

# 1. ARM Cortex-M4F Target Firmware Build
target: $(BUILD_DIR)
	@echo "--- Building ARM Target Firmware (SemVer: $(VERSION)) ---"
	$(CC_ARM) $(CFLAGS_ARM) $(SRC_DIR)/main.c -o $(BUILD_DIR)/location_logger.o

# 2. Host-Based Unit Tests
test-host: $(BUILD_DIR)
	@echo "--- Compiling and Running Off-Target Unit Tests ---"
	$(CC_HOST) $(CFLAGS_HOST) $(SRC_DIR)/token.c $(TEST_DIR)/test_token.c -o $(BUILD_DIR)/test_token_runner
	$(BUILD_DIR)/test_token_runner

# 3. Static Analysis & Code Formatting
lint:
	@echo "--- Running Static Analysis (Cppcheck) ---"
	$(CPPCHECK) $(LINT_FLAGS) $(SRC_DIR)/
	@echo "--- Checking Code Formatting (Clang-Format) ---"
	find $(SRC_DIR)/ -name "*.c" -o -name "*.h" | xargs $(CLANG_FMT) --dry-run --Werror

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*_runner $(BUILD_DIR)

.PHONY: all target test-host lint clean