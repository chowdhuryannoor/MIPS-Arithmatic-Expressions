.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
TestNum: .asciiz "4234"

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:

  # add code to call and is_digit function
  #initializing the stacks
  la		$s0, val_stack		#
  li		$s1, 0		
  la		$s2, op_stack		# 
  addi	$s2, $s2, 2000			# $s2 = $ts2+ 2000
  li		$s3, 0		# $t3 = 0

  la		$s4, TestNum		# 
  la		$a0, TestNum		# 
  jal		get_number				# jump to get_number and save position to $ra
  move 	$a0, $v0		# $a0 = $v0
  li 	$v0, 1		# $v0 = 1
  syscall
  sub		$a0, $v1, $s4		# $a0 = $s0 - $v1
  li 	$v0, 1		# $v0 = 1
  syscall
  
  j end
  

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
