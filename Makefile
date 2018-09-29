
boot.iso: deploy/boot.bin
	mkisofs -b boot.bin -hide boot.bin -iso-level 3 -no-emul-boot -o boot.iso deploy/

deploy/boot.bin: build/snake.o boot.ld
	ld -Tboot.ld build/snake.o -nostartfiles -nostdlib -o deploy/boot.bin

build/snake.o: snake.s
	as snake.s -o build/snake.o