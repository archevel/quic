	STDIN equ 0
	STDOUT equ 1
	STDERR equ 2
	SYS_WRITE equ 1
	SYS_EXIT equ 60
	SYS_CLONE equ 56
	SYS_EXECVE equ 59
	SYS_WAITID equ 247

	CLONE_NEWNS equ 0x00020000
	CLONE_NEWUTS equ 0x04000000
	CLONE_NEWIPC equ 0x08000000
	CLONE_NEWPID equ 0x20000000	
	CLONE_NEWNET equ 0x40000000

	CLONE_FLAGS equ CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID 

	PPID equ 1
	OK_EXIT equ 0	
	
section .text
global _start

_start:	
    	mov rax, SYS_CLONE
    	mov rdi, CLONE_FLAGS
    	mov rsi, rsp
    	mov rdx, 0
    	mov r10, 0
    	syscall

	mov r15, rax		; save child pid
	
    	cmp rax, 0
    	je _clone	

	mov r11, 0

_wait_for_child:
	
    	mov rdi, PPID		
    	mov rsi, r15		; use saved child pid in wait
    	mov rdx, 0		; TODO: should be pointer to a siginfo_t struct
     	mov r10, 4		; wait for exited children
    	mov rax, SYS_WAITID
    	syscall

	cmp rax, 0
	je _ok_exit

	inc r11 		;call to waitid failed, try again 5 times
	cmp r11, 5
	je _bad_exit
	jmp _wait_for_child	
	
_ok_exit:	
    	mov rdi, OK_EXIT
    	jmp _exit

_bad_exit:
	mov rdi, rax
	jmp _exit
	
_clone:
     	mov rax, SYS_EXECVE
    	mov rdi, [rsp + 16]
    	lea rsi, [rsp + 16]
    	lea rdx, [rsp + 40]
    	syscall

_exit:
    	mov rax, SYS_EXIT
    	syscall
