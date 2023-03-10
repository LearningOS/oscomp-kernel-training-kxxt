.PHONY: all run clean

TARGET      := riscv64imac-unknown-none-elf
KERNEL_FILE := target/$(TARGET)/release/os
DEBUG_FILE  ?= $(KERNEL_FILE)

OBJDUMP     := rust-objdump --arch-name=riscv64
OBJCOPY     := rust-objcopy --binary-architecture=riscv64
IMG_URL     := https://github.com/os-autograding/testsuits-in-one/raw/gh-pages/fat32.img

all: fat32.img
	cargo build --release
	cp $(KERNEL_FILE) kernel-qemu

fat32.img:
	@echo "Downloading fat32.img"
	wget $(IMG_URL) -O fat32.img
	touch $@

run: all
	qemu-system-riscv64 \
    -machine virt \
    -bios default \
    -device loader,file=kernel-qemu,addr=0x80200000 \
    -drive file=fat32.img,if=none,format=raw,id=x0 \
    -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 \
    -kernel kernel-qemu \
    -nographic \
    -smp 4 -m 2G

clean:
	rm kernel-qemu
	rm $(KERNEL_FILE)