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

  # add code to test call and test apply_bop function
  li		$a0, 2		# $a0 = 1
  li		$a1, '-'		# $a1 = '+'
  li		$a2, 3		# $a2 = 2
  jal		apply_bop				# jump to apply_bop and save position to $ra
  move 	$a0, $v0		# $a0 = $v0
  li		$v0, 1		# $v0 = 1
  syscall
  j end

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
