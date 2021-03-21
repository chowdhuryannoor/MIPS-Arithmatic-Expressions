.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:

  # add code to call and test stack_push function
  li		$a0, 3		# $a0 = 3
  li		$a1, 0		# $a1 = 0
  la		$s0, val_stack		# 
  move 	$a2, $s0		# $a2 = $s0
  jal		stack_push				# jump to stack_push and save position to $ra
  li		$a0, 4		# $a0 = 4
  move 	$a1, $v0		# $a1 = $v0
  move 	$a2, $s0		# $a2 = $s0
  jal		stack_push				# jump to stack_push and save position to $ra
  li		$a0, 5		# $a0 = 4
  move 	$a1, $v0		# $a1 = $v0
  move 	$a2, $s0		# $a2 = $s0
  jal		stack_push				# jump to stack_push and save position to $ra
  
  move 	$a0, $v0		# $a0 = $v0
  li		$v0, 1		# $v0 = 1
  syscall
  lw		$a0, 0($s0)		# 
  syscall
  lw		$a0, 4($s0)		# 
  syscall
  lw		$a0, 8($s0)		# 
  syscall
  j		end				# jump to end
  

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
