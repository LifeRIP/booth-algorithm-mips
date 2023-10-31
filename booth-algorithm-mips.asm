#####################################################################################################
#
# ARCHIVO	:	booth-algorithm-mips.asm
# AUTOR		:	Joan Jaramillo, 2023
# CODIGO	:	2159930
# DESCRIPCION	:	Algoritmo Booth para la multiplicaciï¿½n de numeros con signo de 16 bits
#
# -----------
# ARGUMENTOS
# ----------- 
# $s0: A (inicia en 0)
# $s1: M (multiplicando)
# $s2: Q (multiplicador)
# $s3: Q-1
# $s4: Contador de ciclos
#
#####################################################################################################

# ------ VARIABLES ------ #

	.data
	
# Definición de variables
whitespace:			.asciiz " "
tab:				.asciiz "\t"
newline:			.asciiz "\n"
msg_multiplicand:		.asciiz "Ingrese multiplicando (M): "
msg_multiplier:			.asciiz "Ingrese multiplicador (Q): "
msg_a:				.asciiz "A "
msg_q:				.asciiz "Q "
msg_q_1:			.asciiz "Q-1 "
msg_top:			.asciiz "Ciclo\t\tA\t\t\tQ\t\tQ-1\t\tM\t\t    Procesos\n"
msg_shift:			.asciiz "\t[--] >>>\n"
msg_01:				.asciiz "\t[01] A = A + M"
msg_10:				.asciiz "\t[10] A = A - M"

# ------  MAIN ------ #

	.text
	.globl main
	
main:
	j init_state
	

# ------ FUNCIONES ------ #

# Cargar valores iniciales
init_state:
	# Incializar variables en 0
	li $s0, 0	# A
	li $s3, 0 	# Q-1
	li $s4, 1 	# Ciclos
	li $s7, 16 	# Ciclos
	
	# Imprimir msg_multiplicando
	li $v0, 4
	la $a0, msg_multiplicand
	syscall
	
	# Leer M (multiplicando)
	li $v0, 5
	syscall
	move $s1, $v0	# Almacenar M en $s1
	
	# Imprimir msg_multiplicador
	li $v0, 4
	la $a0, msg_multiplier
	syscall
	
	# Leer Q (multiplicando)
	li $v0, 5
	syscall
	move $s2, $v0	# Almacenar Q en $s2

# Imprimir titulos de la tabla
print_top:
	li $v0, 4
	la $a0, msg_top
	syscall


# Bucle para ejecutar los ciclos
main_loop:
	#TODO: loop principal 16 ciclos
	
switch:
	#TODO: switch para case_shift, case 01, case 10
	
# Imprimir cada ciclo 
print_cycle:
	# Imprimir un espacio
	jal print_whitespace
	
	# Imprimir contador de ciclos
	li $v0, 1
	move $a0, $s4
	syscall
	
	# Imprimir un tab
	jal print_tab
	
	# Imprimir A
	move $t0, $s0
	jal print_bin
	
	# Imprimir un tab
	jal print_tab
	
	# Imprimir Q
	move $t0, $s2
	jal print_bin
	
	# Imprimir un tab
	jal print_tab
	
	# Imprimir un space
	jal print_whitespace
	
	# Imprimir Q-1
	li $v0, 1
	move $a0, $s3
	syscall
	
	# Imprimir un tab
	jal print_tab
	
	# Imprimir M
	move $t0, $s1
	jal print_bin
	
	# Imprimir un newline
	jal print_newline
	
	# PRUEBAS DE FUNCIONAMIENTO DEL SHIFT #
	jal a_r_shift
	
	add $s4, $s4, 1
	bne $s4, 16 print_cycle
	
	jal exit

# ------ OPERACIONES ------ #

# A = A + M
add: 
	add $s0, $s0, $s1 
	
# A = A - M
sub:
	sub $s0, $s0, $s1

# Shift aritmetico hacia la derecha de A, Q, Q-1
a_r_shift:
	andi $t1, $s0, 1		# Guardar el LSB de A en $t1
	sll $t1, $t1, 15		# Desplazar 15 posiciones a la izquierda el LSB de A
	sra $s0, $s0, 1			# Desplazar arit. a la derecha A
	
	andi $s3, $s2, 1		# Guardar el LSB de Q en Q-1
	
	andi $s2, $s2, 0xFFFF		# Guardar solo los primeros 16 bits de Q (LSB to MSB)
	srl $s2, $s2, 1			# Desplazar logic. a la derecha Q
	
	or $t0, $t0, $t2		# Insertar LSB de A en Q desplazado
	
	jr $ra
	

# Imprimir un entero en binario de 16 bits
print_bin:
	li $t1, 15			# Cargar el valor 15 en $t1 (para imprimir 16 bits)
	li $v0, 1
	bin_loop:
		srlv $t2, $t0, $t1	# Desplazar el MSB a la posición 0
		andi $t3, $t2, 1	# Guardar el LSB (posicion 0)
		
		# Imprimir el bit actual (0 o 1)
		move $a0, $t3
		syscall
		
		sub $t1, $t1, 1		# Decrementar el contador
		
		bne $t1, -1, bin_loop	# Saltar a 'bin_loop' si $t1 no es igual a -1
	jr $ra


# ------ FORMATO STRINGS ------ #

# Imprimir un tab
print_tab:
	li $v0, 4
	la $a0, tab
	syscall
	jr $ra
	
# Imprimir un espacio
print_whitespace:
	li $v0, 4
	la $a0, whitespace
	syscall
	jr $ra
	
# Imprimir un salto de linea
print_newline:
	li $v0, 4
	la $a0, newline
	syscall
	jr $ra
	
# ------ TERMINAR PROGRAMA ------ #

exit:
	li $v0, 10
	syscall