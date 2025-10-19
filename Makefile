# Compiler and tools
ASM = nasm
DD = dd
TRUNCATE = truncate
QEMU = qemu-system-i386

# Directories
SRC_DIR = src
BUILD_DIR = build

# Files
BOOT_SRC = $(SRC_DIR)/main.asm
BOOT_BIN = $(BUILD_DIR)/main.bin
FLOPPY_IMG = $(BUILD_DIR)/main_floppy.img

# Default target
all: $(FLOPPY_IMG)

# Create floppy image from bootloader
$(FLOPPY_IMG): $(BOOT_BIN)
	@echo "Creating floppy image..."
	cp $(BOOT_BIN) $(FLOPPY_IMG)
	$(TRUNCATE) -s 1474560 $(FLOPPY_IMG)  # 1440k in bytes
	@echo "Floppy image created: $(FLOPPY_IMG)"

# Assemble bootloader
$(BOOT_BIN): $(BOOT_SRC)
	@echo "Assembling bootloader..."
	$(ASM) $(BOOT_SRC) -f bin -o $(BOOT_BIN) -l $(BUILD_DIR)/main.lst
	@echo "Bootloader assembled: $(BOOT_BIN)"

# Run in QEMU
run: $(FLOPPY_IMG)
	@echo "Starting QEMU..."
	$(QEMU) -drive file=$(FLOPPY_IMG),format=raw,if=floppy

# Run with debug output
debug: $(FLOPPY_IMG)
	@echo "Starting QEMU with debug output..."
	$(QEMU) -drive file=$(FLOPPY_IMG),format=raw,if=floppy -d cpu_reset -D $(BUILD_DIR)/qemu.log

# Run with serial console
serial: $(FLOPPY_IMG)
	@echo "Starting QEMU with serial console..."
	$(QEMU) -drive file=$(FLOPPY_IMG),format=raw,if=floppy -serial stdio

# Run with curses (text-only)
curses: $(FLOPPY_IMG)
	@echo "Starting QEMU with curses display..."
	$(QEMU) -drive file=$(FLOPPY_IMG),format=raw,if=floppy -curses

# Run with GDB debugging
gdb: $(FLOPPY_IMG)
	@echo "Starting QEMU with GDB support..."
	$(QEMU) -drive file=$(FLOPPY_IMG),format=raw,if=floppy -s -S

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -f $(BUILD_DIR)/*

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Ensure build directory exists before compiling
$(BOOT_BIN): | $(BUILD_DIR)
$(FLOPPY_IMG): | $(BUILD_DIR)

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build everything (default)"
	@echo "  run     - Run in QEMU"
	@echo "  debug   - Run with CPU debug logging"
	@echo "  serial  - Run with serial console"
	@echo "  curses  - Run with curses display"
	@echo "  gdb     - Run with GDB debugging support"
	@echo "  clean   - Clean all build files"
	@echo "  help    - Show this help"

.PHONY: all run debug serial curses gdb clean help
