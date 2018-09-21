
boot.iso: deploy/boot.bin
	mkisofs -b boot.bin -hide boot.bin -iso-level 3 -no-emul-boot -o boot.iso deploy/

deploy/boot.bin: build/boot.o boot.ld
	ld -Tboot.ld -nostartfiles -nostdlib boot.o -o deploy/boot.bin

build/boot.o: boot.s
	as boot.s -o boot.o
