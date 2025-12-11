.model small
.stack
.data
	msg_game_over db 'GAME OVER$'
	msg_score db 'Puntos: $'
	score db 0

	player_x db 37
	player_y db 22

	objective_x db 24

	car1_x db 10
	car2_x db 50
	car3_x db 30
	car4_x db 60
.code
main proc
	mov ax, @data
	mov ds, ax

	draw_car macro color, x, y
		mov ah, 6h	;desplazamiento de ventana de texto
		mov al, 0h	;se va a la fila 0
		mov bh, color	;color y atributo de texto
		mov cl, x	;esquina superior izquierda col
		mov ch, y	;esquina superior izquierda fila
		mov dl, x	;esquina inferior derecha col
		add dl, 6
		mov dh, y	;esquina inferior derecha fila
		int 10h
		mov bh, color	;color y atributo de texto
		mov cl, x	;esquina superior izquierda col
		sub cl, 1
		mov ch, y	;esquina superior izquierda fila
		add ch, 1
		mov dl, x	;esquina inferior derecha col
		add dl, 7
		mov dh, y	;esquina inferior derecha fila
		add dh, 1
		int 10h
		mov bh, 0h	;color y atributo de texto
		mov cl, x	;esquina superior izquierda col
		mov ch, y	;esquina superior izquierda fila
		add ch, 2
		mov dl, x	;esquina inferior derecha col
		add dl, 1
		mov dh, y	;esquina inferior derecha fila
		add dh, 2
		int 10h
		mov bh, 0h	;color y atributo de texto
		mov cl, x	;esquina superior izquierda col
		add cl, 5
		mov ch, y	;esquina superior izquierda fila
		add ch, 2
		mov dl, x	;esquina inferior derecha col
		add dl, 6
		mov dh, y	;esquina inferior derecha fila
		add dh, 2
		int 10h
	endm

	check_collision macro car_x, car_y, label_no_collision
		mov ah, car_x
		sub ah, 1
		mov al, car_y

		cmp player_x, ah
		jb label_no_collision
		add ah, 7
		cmp player_x, ah
		ja label_no_collision

		cmp player_y, al
		jb label_no_collision
		add al, 2
		cmp player_y, al
		ja label_no_collision

		call game_over
	label_no_collision:
	endm

	draw_rect macro color, x1, y1, x2, y2
		mov ah, 6h	;desplazamiento de ventana de texto
		mov al, 0h	;se va a la fila 0
		mov bh, color	;color y atributo de texto
		mov cl, x1	;esquina superior izquierda col
		mov ch, y1	;esquina superior izquierda fila
		mov dl, x2	;esquina inferior derecha col
		mov dh, y2	;esquina inferior derecha fila
		int 10h
	endm

	mov_cur macro x, y
		mov ah, 2h	;"funcion" coloca cursor en pantalla
		mov bh, 0h	;selecciona pagina de video 0
		mov dl, x	;columna del cursor
		mov dh, y	;fila del cursor
		int 10h
	endm

_main_loop:
	mov ax, 3	;limpiar y asi
	int 10h

	;SCORE-------------------------
	mov_cur 4, 1
	mov ah, 9h			;etiqueta
	lea dx, msg_score
	int 21h
	xor ax, ax			;numero real
	mov al, score
	call print_num
	mov ah, 2h			;ceros para enganiar al jugador xdxdx
	xor dx, dx
	mov dx, '0'
	int 21h
	int 21h

	;BACKGROUND--------------------
	;un saludito pal gad y pal barufis
	draw_rect 70h, 2, 3, 76, 22

	;OBJECTIVE---------------------
	mov ah, 6h	;desplazamiento de ventana de texto
	mov al, 0h	;se va a la fila 0
	mov bh, 60h	;color y atributo de texto
	mov cl, objective_x	;esquina superior izquierda col
	mov ch, 3			;esquina superior izquierda fila
	mov dl, objective_x	;esquina inferior derecha col
	add dl, 1
	mov dh, 3			;esquina inferior derecha fila
	int 10h

	;CARS--------------------------
	add car1_x, 4
	cmp car1_x, 80
	jbe _car1_not_finished
	mov car1_x, 1
_car1_not_finished:

	add car2_x, 3
	cmp car2_x, 80
	jbe _car2_not_finished
	mov car2_x, 1
_car2_not_finished:

	sub car3_x, 2
	cmp car3_x, 1
	jae _car3_not_finished
	mov car3_x, 80
_car3_not_finished:

	sub car4_x, 1
	cmp car4_x, 1
	jae _car4_not_finished
	mov car4_x, 80
_car4_not_finished:

	draw_car 90h, car1_x, 5
	draw_car 60h, car2_x, 9
	draw_car 40h, car3_x, 13
	draw_car 50h, car4_x, 17

	;PLAYER------------------------
	mov ah, 6h	;desplazamiento de ventana de texto
	mov al, 0h	;se va a la fila 0
	mov bh, 20h	;color y atributo de texto
	mov cl, player_x	;esquina superior izquierda col
	mov ch, player_y	;esquina superior izquierda fila
	mov dl, player_x	;esquina inferior derecha col
	add dl, 1
	mov dh, player_y	;esquina inferior derecha fila
	int 10h

	;DELAY-------------------------
	mov cx, 2
	_delay:
	hlt
	loop _delay

	;INPUT-------------------------
	mov ah, 1h
	int 16h
	jz _after_input

	mov ah, 0
	int 16h

	cmp al, 'w'
	je _input_up
	cmp al, 'a'
	je _input_left
	cmp al, 's'
	je _input_down
	cmp al, 'd'
	je _input_right
	cmp al, 27
	jne _not_game_over
	call game_over
_not_game_over:
	jmp _after_input

_input_right:
	cmp player_x, 75
	je _after_input
	add player_x, 1
	jmp _after_input
_input_left:
	cmp player_x, 2
	je _after_input
	sub player_x, 1
	jmp _after_input
_input_up:
	cmp player_y, 3
	je _after_input
	sub player_y, 1
	jmp _after_input
_input_down:
	cmp player_y, 22
	je _after_input
	add player_y, 1
	jmp _after_input
_after_input:

	;WIN CONDITION-----------------
	mov ah, player_x
	cmp ah, objective_x
	jne _no_win
	cmp player_y, 3
	jne _no_win
	add score, 1
	mov player_y, 22
	
	mov ah, 00h		;posicion random para el objetivo
	int 1ah
	mov ax, dx
	xor dx, dx
	mov cx, 70
	div cx
	add dl, 3
	mov objective_x, dl
_no_win:

	;COLLISIONS--------------------
	check_collision car1_x, 5, _not_killed1
	check_collision car2_x, 9, _not_killed2
	check_collision car3_x, 13, _not_killed3
	check_collision car4_x, 17, _not_killed4

	jmp _main_loop	;FIN del loop principal :v
	
_end:
	int 27h
main endp

print_num proc
    mov cx, 0
    mov bx, 10
next_digit:
    mov dx, 0
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz next_digit
print_digits:
    pop dx
    mov ah, 2h
    int 21h
    loop print_digits
    ret
print_num endp

game_over proc
	mov_cur 34, 12
	mov ah, 9h
	lea dx, msg_game_over
	int 21h
	mov_cur 0, 23
	int 27h
game_over endp
end