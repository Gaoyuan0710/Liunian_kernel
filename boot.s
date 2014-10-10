;
;
;            The beginning of the Liunian_kernel
;
;

; Multiboot 魔术,由规范决定
MBOOT_HEADER_MAGIC equ 0x1BADB002

; 0 号位表示所有的引导模块将按页（4KB）边界对齐
MBOOT_PAGE_ALIGN   equ 1 << 0

;1 号位表示Multiboot信息结构的 mem_*域包括可用内存的信息
;（告诉GRUB把内存空间的信息包含在Multiboot信息结果中）
MBOOT_MEM_INFO     equ 1 << 1

;定义我们使用的Multiboot 的标记
MBOOT_HEADER_FLAGS equ MBOOT_APGE_ALIGN | MBOOT_MEM_INFO

;域checksum是一个32位的无符号值，当与其它的magic域（也就是magic 和 flags）相加时，要求其结果必须是32位的无符号值0
;(即magic + flag + checksum = 0)
MBOOT_CHECKSUM     equ -(MBOOT_HEADER_MAGIC+MBOOT_HEADER_FLAGS)

;符合Multiboot规范的 os 映像需要这样一个magic Multiboot 头
; 省略

[BITS 32] ;所有代码以32-bit的方式编译
section .text ;代码段

;在代码段的起始位置设置符合Multiboot 规范的标记

dd MBOOT_HEADER_MAGIC ;GRUB会通过这个魔术判断该映像是否支持
dd MBOOT_HEADER_FLAGS ;GRUB的一些加载时选项
dd MBOOT_CHECKSUM     ;检测数值

[GLOBAL start] ;向外部声明内核代码入口，此处提供该声明给链接器
[GLOBAL glb_mboot_ptr] ;向外部声明 struct miltiboot *变量
[EXTERN kern_entry]    ;声明内核C代码的入口函数


start:
	cli         ;关闭中断

	mov esp, STACK_TOP  ;设置内核栈地址
	mov ebp, 0          ;帧指针修改为0
	mov esp, 0FFFFFFF0H ;栈地址按照16字节对齐
	mov [glb_mboot_ptr], ebx ;将ebx中存储的指针存入全局变量
	call kern_entry          ;调用内核入口函数

stop:
	hlt ;停机指令.可以降低CPU功耗
	jmp stop ;

section .bss
stack:
	resb 32768 ;内核栈
glb_mboot_ptr:
	resb 4

STARCK_TOP equ $-stack-1
		
	
