	STDIN equ 0
	STDOUT equ 1
	STDERR equ 2
	SYS_WRITE equ 1
	SYS_EXIT equ 60
	SYS_CLONE equ 56
	SYS_EXECVE equ 59
	SYS_WAITID equ 247
	SYS_KILL equ 62

	CLONE_NEWNS equ 0x00020000
	CLONE_NEWUTS equ 0x04000000
	CLONE_NEWIPC equ 0x08000000
	CLONE_NEWPID equ 0x20000000	
	CLONE_NEWNET equ 0x40000000
	SIGCHLD equ 17

	CLONE_FLAGS equ CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | SIGCHLD

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
     	mov rax, SYS_EXECVE
    	mov rdi, [rsp + 16]
    	lea rsi, [rsp + 16]
	lea rdx, [rsp + 40]
    	syscall

_exit:
    	mov rax, SYS_EXIT
    	syscall

;; 	EXPECTED_ARG_COUNT equ 3
;;	BAD_ARGS_EXIT equ 1
;; 	mov rax, [rsp]
;; 	cmp rax, EXPECTED_ARG_COUNT
;; ;; jne _err_bad_args
;; _err_bad_args:
;; 	mov rax, SYS_WRITE
;; 	mov rdi, STDERR
;; 	mov rsi, bad_args
;; 	mov rdx, bad_args_len
;; 	syscall

;; 	mov rdi, rax  ;; BAD_ARGS_EXIT
;; 	jmp _exit
