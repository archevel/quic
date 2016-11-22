all: assemble quic.o
	ld -o quic quic.o

assemble: quic.asm
	nasm -f elf64 -o quic.o quic.asm
