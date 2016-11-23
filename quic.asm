	STDIN equ 0
	STDOUT equ 1
	STDERR equ 2
	SYS_WRITE equ 1
	SYS_EXIT equ 60
	SYS_CLONE equ 56
	SYS_EXECVE equ 59
	SYS_WAITID equ 247
	SYS_KILL equ 62
	SYS_CHROOT equ 161
	SYS_CHDIR equ 80

	CLONE_NEWNS equ 0x00020000
	CLONE_NEWUTS equ 0x04000000
	CLONE_NEWIPC equ 0x08000000
	CLONE_NEWPID equ 0x20000000	
	CLONE_NEWNET equ 0x40000000
	SIGCHLD equ 17

	CLONE_FLAGS equ CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | SIGCHLD

	PPID equ 1
	OK_EXIT equ 0
	EXPECTED_MIN_ARG_COUNT equ 3
	BAD_ARGS_EXIT equ 1

section .data
	bad_args db "Bad arguments.", 10, "Usage: quic <container-rootfs> <executable-in-container> [args...]", 10, 0
	bad_args_len equ $ - bad_args
	root db "/", 0
	
section .text
global _start

_start:
	mov rax, [rsp]
	cmp rax, EXPECTED_MIN_ARG_COUNT
	jl _err_bad_args

    	mov rax, SYS_CLONE
    	mov rdi, CLONE_FLAGS
    	mov rsi, rsp
    	mov rdx, 0
    	mov r10, 0
    	syscall
	
    	cmp rax, 0
	je _clone

	mov r15, rax		; save cloned pid

_wait_for_child:
	mov rdi, PPID
    	mov rsi, r15		; use saved child pid in wait
    	mov rdx, 0		; TODO: should be pointer to a siginfo_t struct
     	mov r10, 4		; wait for exited children
    	mov rax, SYS_WAITID
    	syscall

	cmp rax, 0
	jne _bad_exit

_ok_exit:	
    	mov rdi, OK_EXIT
    	jmp _exit

_bad_exit:
	mov r14, rax		; Save bad exit code

	mov rax, SYS_KILL	; Attempt to kill clone
	mov rdi, r15		; clone pid
	mov rsi, 9 		; not sure if value matters...
	syscall
	
	mov rdi, r14
	jmp _exit

_clone:
	mov rax, SYS_CHROOT
	mov rdi, [rsp + 16]
	syscall

	mov rdi, rax
	cmp rax, 0
	jne _exit

	mov rax, SYS_CHDIR
	mov rdi, root
	syscall

	mov rdi, rax
	cmp rax, 0
	jne _exit


	
	mov rax, SYS_EXECVE
	mov rdi, [rsp + 24]
	lea rsi, [rsp + 24]

	mov rdx, [rsp] 		; calculate address to environment array
	imul rdx, 8
	add rdx, rsp
	add rdx, 16
	lea rdx, [rdx]		; load environment array address
	
	syscall

_exit:
    	mov rax, SYS_EXIT
    	syscall

_err_bad_args:
	mov rax, SYS_WRITE
	mov rdi, STDERR
	mov rsi, bad_args
	mov rdx, bad_args_len
	syscall

	mov rdi, BAD_ARGS_EXIT
	jmp _exit
