############################################################################################
#
# ARCHIVO: 	booth-algorithm-mips.asm
# AUTOR:	Joan Jaramillo, 2023
# DESCRIPCION:	Algoritmo Booth para la multiplicaci�n de numeros con signo de 16 bits
# ARGUMENTOS:	$s0: A (inicia en 0)
#		$s1: M (multiplicando)
#		$s2: Q (multiplicador)
#		$s3: Q-1
#		$s4: Contador de ciclos
#
############################################################################################

	.data
	
# Definir las variables
tab:				.asciiz "\t"
newline:			.asciiz "\n"
msg_multiplicand:		.asciiz "Ingrese multiplicando: "
msg_multiplier:			.asciiz "Ingrese multiplicador: "
msg_a:				.asciiz "A "
msg_q:				.asciiz "Q "
msg_q_1:			.asciiz "Q-1 "
msg_top:			.asciiz "Ciclo\t\tA\t\t\tQ\t\tQ-1\t\tM\t\t    Procesos\n"
msg_00:				.asciiz "\t[00] >>>\n"
msg_11:				.asciiz "\t[11] >>>\n"
msg_01:				.asciiz "\t[01] A = A + M"
msg_10:				.asciiz "\t[10] A = A - M"
msg_test:			.asciiz " 10\t1111111101101010\t1111111101101010\t 1\t1111111101101010"

# Datos de prueba
multiplicand:			.half 12	# N�mero a multiplicar
multiplier:			.half -7	# N�mero por el cual se multiplica (en complemento a dos)
product:			.half 0		# Variable para almacenar el producto
ciclos:				.half 16	# Contador para recorrer los bits del multiplicador
	.text
	.globl main
	
# Inicio del programa
main:
	# Incializar variables en 0
	addi $s0, $0, 0	# A
	addi $s4, $0, 0 # Ciclos
	
	# Imprimir msg_multiplicando
	li $v0, 4
	la $a0, msg_multiplicand
	syscall
	
	# Leer M (multiplicando)
	li $v0, 5
	syscall
	move $t0, $v0	# Almacenar M en $s1
	
	# Imprimir msg_multiplicador
	li $v0, 4
	la $a0, msg_multiplier
	syscall
	
	# Leer Q (multiplicando)
	li $v0, 5
	syscall
	move $s2, $v0	# Almacenar Q en $s2

print_top:
	# Imprimir titulos de la tabla
	li $v0, 4
	la $a0, msg_top
	syscall
	
	#li $v0, 35
	#move $a0, $s1
	#syscall
	
	#li $v0, 4
	#la $a0, msg_test
	#syscall
	
	#li $v0, 4
	#la $a0, msg_10
	#syscall
	
print_bin:
	# Imprime un entero en binario de 16 bits
	li $t1, 15			# set 15 for the loops to print 16 bits
	li $v0, 1			# print integer

	bgtz $t0, positive_loop		# for positive values

positive_loop:
	srlv $t3, $t0, $t1
	andi $t4, $t3, 1		# mask the rightmost bit
	move $a0, $t4
	syscall
	addi $t1, $t1, -1		# decrement the loop counter
	bne $t1, -1, positive_loop	# repeat until the loop counter is -1

exit:
	# Terminar programa
	li $v0, 10
	syscall