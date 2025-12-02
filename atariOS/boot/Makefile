all: run

boot.bin: boot.asm
	@nasm -f bin boot.asm -o boot.bin
	@echo "Built boot.bin"

run: boot.bin
	qemu-system-i386 -drive format=raw,file=boot.bin

clean:
	rm -f boot.bin
