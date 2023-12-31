#####################################################################################################
#
# ARCHIVO	:	booth-algorithm-mips.asm
# AUTOR		:	Joan Jaramillo
# FECHA		:	29-10-2023
# CODIGO	:	2159930
# DESCRIPCION	:	Algoritmo Booth para la multiplicacion de numeros con signo de 16 bits
#
# -----------
# ARGUMENTOS
# ----------- 
# $s0: A
# $s1: M (multiplicando)
# $s2: Q (multiplicador)
# $s3: Q-1
# $s4: Q0
# $s5: Contador de ciclos
#
#####################################################################################################

# ------ VARIABLES ------ #

	.data
	
# Definicion de variables
whitespace:				.asciiz " "
tab:					.asciiz "\t"
newline:				.asciiz "\n"
equal:					.asciiz " = "
msg_multiplicand:			.asciiz "Ingrese multiplicando (M): "
msg_multiplier:				.asciiz "Ingrese multiplicador (Q): "
msg_a:					.asciiz "A "
msg_q:					.asciiz "Q "
msg_q_1:				.asciiz "Q-1 "
msg_top:				.asciiz "Ciclo\t\tA\t\t\tQ\t\tQ-1\t\tM\t\t    Procesos\n"
msg_val:				.asciiz "\tValores iniciales\n"
msg_shift:				.asciiz "\t[--] >>>\n"
msg_01:					.asciiz "\t[01] A = A + M\n"
msg_10:					.asciiz "\t[10] A = A - M\n"
msg_output:				.asciiz "Salida: "

# ------  MAIN ------ #

	.text
	.globl main
	
main:
	j init_state
	
# ------ FUNCIONES ------ #

# Cargar valores iniciales
init_state:
	# Incializar variables en 0
	li $s0, 0			# A
	li $s3, 0 			# Q-1
	li $s4, 0 			# Q0
	li $s5, 0 			# Ciclos
	
	# Imprimir msg_multiplicando
	li $v0, 4
	la $a0, msg_multiplicand
	syscall
	
	# Leer M (multiplicando)
	li $v0, 5
	syscall
	move $s1, $v0			# Almacenar M en $s1
	
	# Imprimir msg_multiplicador
	li $v0, 4
	la $a0, msg_multiplier
	syscall
	
	# Leer Q (multiplicando)
	li $v0, 5
	syscall
	move $s2, $v0			# Almacenar Q en $s2
	
	jal print_newline		# Imprimir un newline

# Imprimir formato de la tabla
print_top:
	# Imprimir titulos de la tabla
	li $v0, 4
	la $a0, msg_top
	syscall
	
	jal print_cycle			# Imprime ciclo 0
		
	jal print_msg_val		# Imprimir un msg_val
	
	jal print_newline		# Imprimir un newline
	
# Bucle para ejecutar los ciclos, while (Ciclos =! 16)
main_loop:
	beq $s5, 16, print_output	# Saltar a 'exit' si $s5 es igual a 16
	addi $s5, $s5, 1		# Incrementa el contador de ciclos $s5
	
	andi $s4, $s2, 1		# Guardar el LSB de Q en $s4
	
# Condicional de Q0 y Q-1
switch:
	li $t8, 0
	andi $s4, $s4, 1		# Guardar el LSB de Q en $s4
	
	beq $s4, $s3, case_shift	# if (Q0 == Q-1) case_shift 
	beqz $s4, case_01		# if (Q0 == 0 & Q-1 == 1) case_01
	j case_10			# if (Q0 == 1 & Q-1 == 0) case_10
	
	# Caso 00 y 11
	case_shift:
		jal a_r_shift		# Shift aritmetico hacia la derecha de A, Q, Q-1
		jal print_cycle		# Imprime el ciclo
		jal print_msg_shift	# Imprimir un msg_shift
		
		jal print_newline	# Imprimir un newline
		
		j main_loop		# Regresa al loop principal
		
	# Caso 01
	case_01:
		add $s0, $s0, $s1	# A = A + M
		jal print_cycle		# Imprime el ciclo
		jal print_msg_01	# Imprime el msg_01
		
		jal a_r_shift		# Shift aritmetico hacia la derecha de A, Q, Q-1
		jal print_cycle		# Imprime el ciclo
		jal print_msg_shift	# Imprime el msg_01
		
		jal print_newline	# Imprimir un newline
		
		j main_loop		# Regresa al loop principal
		
	# Caso 10
	case_10:
		sub $s0, $s0, $s1	# A = A - M
		jal print_cycle		# Imprime el ciclo
		jal print_msg_10	# Imprime el msg_10
		
		jal a_r_shift		# Shift aritmetico hacia la derecha de A, Q, Q-1
		jal print_cycle		# Imprime el ciclo
		jal print_msg_shift	# Imprime el msg_10
		
		jal print_newline	# Imprimir un newline
		
		j main_loop		# Regresa al loop principal
	
# Shift aritmetico hacia la derecha de A, Q, Q-1
a_r_shift:
	andi $t1, $s0, 1		# Guardar el LSB de A en $t1
	sll $t1, $t1, 15		# Desplazar 15 posiciones a la izquierda el LSB de A
	sra $s0, $s0, 1			# Desplazar arit. a la derecha A
	
	andi $s3, $s2, 1		# Guardar el LSB de Q en Q-1
	
	andi $s2, $s2, 0xFFFF		# Guardar solo los primeros 16 bits de Q (LSB to MSB)
	srl $s2, $s2, 1			# Desplazar logic. a la derecha Q
	
	or $s2, $s2, $t1		# Insertar LSB de A en Q desplazado
	
	jr $ra				# Salta a direcci�n de retorno
	
# ------ FORMATO STRINGS ------ #

# Imprimir cada ciclo 
print_cycle:
	move $t4, $ra			# Guardar direccion de retorno para evitar bucle
	
	jal print_whitespace		# Imprimir un whitespace
	
	# Imprimir contador de ciclos
	li $v0, 1
	move $a0, $s5
	syscall
	
	jal print_tab			# Imprimir un tab
	
	# Imprimir A
	move $t0, $s0			# Almacena A en $t0
	jal print_bin			# Imprime en binario
	
	jal print_tab			# Imprimir un tab
	
	# Imprimir Q
	move $t0, $s2			# Almacena Q en $t0
	jal print_bin			# Imprime en binario
	
	jal print_tab			# Imprimir un tab
	
	jal print_whitespace		# Imprimir un whitespace
	
	# Imprimir Q-1
	li $v0, 1
	move $a0, $s3
	syscall
	
	jal print_tab			# Imprimir un tab
	
	# Imprimir M
	move $t0, $s1			# Almacena M en $t0
	jal print_bin			# Imprime en binario
	
	jr $t4				# Salta a direcci�n de retorno guardada al inicio

# Imprimir un entero almacenado en $t0 en binario de 16 bits
print_bin:
	li $t1, 15			# Cargar el valor 15 en $t1 (para imprimir 16 bits)
	li $v0, 1
	bin_loop:
		srlv $t2, $t0, $t1	# Desplazar el MSB a la posicion 0
		andi $t3, $t2, 1	# Guardar el LSB (posicion 0)
		
		# Imprimir el bit actual (0 o 1)
		move $a0, $t3
		syscall
		
		sub $t1, $t1, 1		# Decrementar el contador
		
		bne $t1, -1, bin_loop	# Saltar a 'bin_loop' si $t1 no es igual a -1
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un msg_val
print_msg_val:
	li $v0, 4
	la $a0, msg_val
	syscall
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un msg_shift
print_msg_shift:
	li $v0, 4
	la $a0, msg_shift
	syscall
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un msg_01
print_msg_01:
	li $v0, 4
	la $a0, msg_01
	syscall
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un msg_10
print_msg_10:
	li $v0, 4
	la $a0, msg_10
	syscall
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un tab
print_tab:
	li $v0, 4
	la $a0, tab
	syscall
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un espacio
print_whitespace:
	li $v0, 4
	la $a0, whitespace
	syscall
	jr $ra				# Salta a direcci�n de retorno
	
# Imprimir un salto de linea
print_newline:
	li $v0, 4
	la $a0, newline
	syscall
	jr $ra				# Salta a direcci�n de retorno

# Imprimir salida
print_output:
	li $v0, 4
	la $a0, msg_output
	syscall
	
	sll $t0, $s0, 16		# Dezplaza 16 posiciones a la izquierda A
	or $t0, $t0, $s2		# Concatena A con Q en $t0
	
	# Imprime la salida en binario
	li $v0, 35
	move $a0, $t0
	syscall

	# Imprime un igual
	li $v0, 4
	la $a0, equal
	syscall
	
	# Imprime la salida en decimal
	li $v0, 1
	move $a0, $t0
	syscall

# ------ TERMINAR PROGRAMA ------ #

exit:
	li $v0, 10
	syscall
