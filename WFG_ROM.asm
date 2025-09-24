;
;  _____ _____  _____    __  __ ______ __  __   _______ ______  _____ _______ 
; |_   _|  __ \|  __ \  |  \/  |  ____|  \/  | |__   __|  ____|/ ____|__   __|
;   | | | |  | | |__) | | \  / | |__  | \  / |    | |  | |__  | (___    | |   
;   | | | |  | |  ___/  | |\/| |  __| | |\/| |    | |  |  __|  \___ \   | |   
;  _| |_| |__| | |      | |  | | |____| |  | |    | |  | |____ ____) |  | |   
; |_____|_____/|_|      |_|  |_|______|_|  |_|    |_|  |______|_____/   |_|   
;
; This is an IDP-G ROM for memory testing. It does not use the stack or RAM.
; It does not boot IDP. It halts after the test.                           
;                                             
; Created by Oddbit Retro, September 2025 
;

	DI

; PIO initialization.
	LD	A, $07
	OUT	($31), A
	OUT	($33), A
	LD	A, $0F
	OUT	($31), A
	OUT	($33), A

	LD	A, $18
	OUT	($30), A
	LD	A, $6D
	OUT	($32), A
	XOR	A
	OUT	($39), A
	OUT	($36), A
	LD	E, A

; GDP initialization.
	XOR	A
	OUT	($21), A

; Select and lower the GDP pen.
	LD	A, $03
	OUT	($21), A

	LD	A, $04  ; Clear the GDP image.
	LD	HL, gdp_cmd_ret
	JP	gdp_cmd
gdp_cmd_ret:
	LD	A, $05  ; Place the pen at the left edge.
	LD	HL, gdp_cmd_ret_2
	JP	gdp_cmd
gdp_cmd_ret_2:
	XOR	A
	OUT	($39), A
	OUT	($30), A

; AVDC initialization.
	LD	A, $00
	OUT	($39), A
	LD	HL, delay_ret
	JP	delay
delay_ret:
	LD	HL, data_avdc_init
	XOR	A

; Set SS1 to 0.
	OUT	($3E), A
	OUT	($3F), A

; Set SS2 to 0.
	OUT	($3A), A
	OUT	($3B), A

	LD	A, $10
	OUT	($39), A
	LD	B, $0A
	LD	C, $38
	OTIR

	LD	A, $3D
	OUT	($39), A

; Set AVDC cursor address to 0.
	XOR	A
	OUT	($3D), A
	OUT	($3C), A

	LD	HL, $1FFF
	LD	A, $1A
	OUT	($39), A
	LD	A, L
	OUT	($38), A
	LD	A, H
	OUT	($38), A

; Fill the AVDC framebuffer with spaces.
	LD	A, $20
	OUT	($34), A
	XOR	A
	OUT	($35), A
	LD	A, $BB  ; Write from cursor to pointer.
	OUT	($39), A

; Set GDP pen Y coordinate to 100.
	LD	A, $64
	OUT	($2B), A

	LD	HL, line_break_ret
	JP	line_break
line_break_ret:
	LD	HL, write_string_ret
	LD	BC, string_startup
	JP	write_string
write_string_ret:
; Place the pen at the left edge again.
	LD	A, $05
	LD	HL, gdp_cmd_ret_3
	JP	gdp_cmd
gdp_cmd_ret_3:
	LD	HL, line_break_2
	JP	line_break
line_break_2:
	LD	HL, write_string_ret_2
	LD	BC, string_testing_memory
	JP	write_string
write_string_ret_2:
	LD	A, $00
	LD	HL, fill_ram_ret
	JP	fill_ram
fill_ram_ret:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $00
	LD	HL, fill_ram_ret_2
	JP	fill_ram
fill_ram_ret_2:
	OUT	($88), A  ; Switch back to bank 1.
	LD	B, $00

repeat_with_cpl:
	LD	A, $00
	EXX
	LD	HL, $2000
	EXX
	LD	HL, fill_ram_addr_ret
	JP	fill_ram_addr
fill_ram_addr_ret:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $01
	EXX
	LD	HL, $2000
	EXX
	LD	HL, fill_ram_addr_ret_2
	JP	fill_ram_addr
fill_ram_addr_ret_2:
	OUT	($88), A  ; Switch back to bank 1.
	LD	A, $00
	EXX
	LD	HL, $2000
	EXX
	LD	HL, check_ram_addr_ret
	JP	check_ram_addr
check_ram_addr_ret:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $01
	EXX
	LD	HL, $2000
	EXX
	LD	HL, check_ram_addr_ret_2
	JP	check_ram_addr
check_ram_addr_ret_2:
	OUT	($88), A  ; Switch back to bank 1.

; Test shared memory.
	LD	A, $00
	EXX
	LD	HL, $C000
	EXX
	LD	HL, fill_ram_addr_ret_3
	JP	fill_ram_addr
fill_ram_addr_ret_3:
	LD	A, $00
	EXX
	LD	HL, $C000
	EXX
	LD	HL, check_ram_addr_ret_3
	JP	check_ram_addr
check_ram_addr_ret_3:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $00
	EXX
	LD	HL, $C000
	EXX
	LD	HL, check_ram_addr_ret_4
	JP	check_ram_addr
check_ram_addr_ret_4:
	OUT	($88), A

	LD	A, B
	OR	A
	JR	NZ, done

	LD	A, $FF
	LD	HL, fill_ram_ret_3
	JP	fill_ram
fill_ram_ret_3:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $FF
	LD	HL, fill_ram_ret_4
	JP	fill_ram
fill_ram_ret_4:
	OUT	($88), A  ; Switch back to bank 1.
	LD	B, $01
	JP	repeat_with_cpl

done:
	LD	HL, line_break_ret_2
	JP	line_break
line_break_ret_2:
	LD	HL, write_string_ret_3
	LD	BC, string_passed
	JP	write_string
write_string_ret_3:
	HALT

; AVDC initialization string.
data_avdc_init:
	DB	$D0, $2F, $0D, $05, $99, $4F, $0A, $EA
	DB	$00, $30

; GDP command string that moves the pen to the bottom-left corner and clears the line.
data_move_pen_bottom_left:
	DB	$03, $00, $05, $01, $0B, $0B, $0B, $0B
	DB	$0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	DB	$0B, $0B, $0B, $0B, $00

; GDP command string that moves the pen to the far left.
data_move_pen_left:
	DB	$21, $00, $0D, $00

gdp_cmd:
	EX	AF, AF'
gdp_cmd_1:
	IN	A, ($20)
	AND	$04
	JR	Z, gdp_cmd_1
	EX	AF, AF'
	OUT	($20), A
	JP	(HL)

delay:
	LD	B, $FF
delay_1:
	NOP
	DJNZ	delay_1
	LD	B, $FF
delay_2:
	NOP
	DJNZ	delay_2
	LD	B, $FF
delay_3:
	NOP
	DJNZ	delay_3
	LD	B, $FF
delay_4:
	NOP
	DJNZ	delay_4
	JP	(HL)

line_break:
	IN	A, ($20)
	AND	$04
	JR	Z, line_break
	LD	A, E
	SUB	$0C
	LD	E, A
	OUT	($36), A
	EXX
	LD	BC, data_move_pen_bottom_left
	LD	HL, write_string_ret_4
	JP	write_string
write_string_ret_4:
	LD	BC, data_move_pen_left
	LD	HL, write_string_ret_5
	JP	write_string
write_string_ret_5:
	EXX
; Select drawing mode.
	XOR	A
	JP	gdp_cmd

write_string:
	IN	A, ($20)
	AND	$04
	JR	Z, write_string
	LD	A, (BC)
	OUT	($23), A
	INC	BC
	LD	A, (BC)
	OUT	($22), A
	INC	BC
write_string_1:
	LD	A, (BC)
	OR	A
	JR	NZ, write_string_2
	JP	(HL)
write_string_2:
	IN	A, ($20)
	AND	$04
	JR	Z, write_string_2
	LD	A, (BC)
	OUT	($20), A
	INC	BC
	JR	write_string_1

write_hex_16:
	LD	A, B
	EXX
	LD	HL, write_hex_8_ret
	JP	write_hex_8
write_hex_8_ret:
	EXX
	LD	A, C
	EXX
	LD	HL, write_hex_8_ret_2
	JP	write_hex_8
write_hex_8_ret_2:
	EXX
	JP	(HL)

write_hex_8:
	LD	B, A
	SRA	A
	SRA	A
	SRA	A
	SRA	A
	AND	$0F

	CP	$0A
	JP	M, write_hex_8_1
	ADD	A, $37
	JR	write_hex_8_2
write_hex_8_1:
	ADD	A, $30
write_hex_8_2:
	EX	AF, AF'
write_hex_8_3:
	IN	A, ($20)
	AND	$04
	JR	Z, write_hex_8_3
	EX	AF, AF'
	OUT	($20), A

	LD	A, B
	AND	$0F

	CP	$0A
	JP	M, write_hex_8_4
	ADD	A, $37
	JR	write_hex_8_5
write_hex_8_4:
	ADD	A, $30
write_hex_8_5:
	EX	AF, AF'
write_hex_8_6:
	IN	A, ($20)
	AND	$04
	JR	Z, write_hex_8_6
	EX	AF, AF'
	OUT	($20), A

	JP	(HL)

; Entry point to memory test.

; Fill RAM $2000–$FFFF with the value in A.
fill_ram:
	EXX
	LD	E, A
	LD	HL, $2000
fill_ram_loop:
	LD	(HL), E
	INC	HL
	LD	A, H
	OR	L
	JR	NZ, fill_ram_loop
	LD	A, $2B
	LD	HL, fill_ram_gdp_cmd_ret
	JP	gdp_cmd
fill_ram_gdp_cmd_ret:
	EXX
	JP	(HL)

; Fill RAM HL'–$BFFF or $FFFF with addr (XOR of high and low bytes XORed with A).
; Or the complement of that (if B is non-zero).
fill_ram_addr:
	EXX
; HL is passed in by the caller.
	LD	E, A
fill_ram_addr_loop:
; Check if $00 or $FF before writing.
	LD	A, (HL)
	LD	D, A
	EXX
	LD	A, B
	OR	A
	EXX
	LD	A, D
	JR	Z, fill_ram_addr_skip_cpl
	CPL
fill_ram_addr_skip_cpl:
	OR	A
	JR	NZ, fill_ram_addr_fail
	LD	A, H
	XOR	L
	XOR	E
; Complement?
	LD	D, A
	EXX
	LD	A, B
	OR	A
	EXX
	LD	A, D
	JR	Z, fill_ram_addr_skip_cpl_2  ; Z/NZ from OR
	CPL
fill_ram_addr_skip_cpl_2:
	LD	(HL), A
	INC	HL
	LD	A, H
	CP	$C0
	JR	NZ, fill_ram_addr_not_C000
	LD	A, L
	OR	A
	JR	NZ, fill_ram_addr_not_C000
	JR	fill_ram_addr_done
fill_ram_addr_not_C000:
	LD	A, H
	OR	L
	JR	NZ, fill_ram_addr_loop
fill_ram_addr_done:
	LD	A, $2A
	LD	HL, fill_ram_addr_gdp_cmd_ret
	JP	gdp_cmd
fill_ram_addr_gdp_cmd_ret:
	EXX
	JP	(HL)
fill_ram_addr_fail:
; HL: address
; $00: expected
; A: actual
	LD	E, A
	LD	B, H
	LD	C, L
; Print address.
	LD	A, $20
	LD	HL, fill_ram_addr_gdp_cmd_ret_2
	JP	gdp_cmd
fill_ram_addr_gdp_cmd_ret_2:
	LD	HL, fill_ram_addr_write_hex_16_ret
	JP	write_hex_16
fill_ram_addr_write_hex_16_ret:
; Print expected.
	LD	A, $20
	LD	HL, fill_ram_addr_gdp_cmd_ret_3
	JP	gdp_cmd
fill_ram_addr_gdp_cmd_ret_3:
	LD	A, $00
	LD	HL, fill_ram_addr_write_hex_8_ret
	JP	write_hex_8
fill_ram_addr_write_hex_8_ret:
; Print actual.
	LD	A, $20
	LD	HL, fill_ram_addr_gdp_cmd_ret_4
	JP	gdp_cmd
fill_ram_addr_gdp_cmd_ret_4:
	LD	A, E
	LD	HL, fill_ram_addr_write_hex_8_ret_2
	JP	write_hex_8
fill_ram_addr_write_hex_8_ret_2:
	HALT

; Check RAM HL'–$BFFF or $FFFF for addr (XOR of high and low bytes XORed with A).
; Or the complement of that (if B is non-zero).
check_ram_addr:
	EXX
; HL is passed in by the caller.
	LD	E, A
check_ram_addr_loop:
	LD	A, H
	XOR	L
	XOR	E
; Complement?
	LD	D, A
	EXX
	LD	A, B
	OR	A
	EXX
	LD	A, D
	JR	Z, check_ram_addr_skip_cpl  ; Z/NZ from OR
	CPL
check_ram_addr_skip_cpl:
	LD	B, A
	LD	A, (HL)
	CP	B
	JR	NZ, check_ram_addr_fail
	INC	HL
	LD	A, H
	CP	$C0
	JR	NZ, check_ram_addr_not_C000
	LD	A, L
	OR	A
	JR	NZ, check_ram_addr_not_C000
	JR	check_ram_addr_done
check_ram_addr_not_C000:
	LD	A, H
	OR	L
	JR	NZ, check_ram_addr_loop
check_ram_addr_done:
	LD	A, $2A
	LD	HL, check_ram_addr_gdp_cmd_ret
	JP	gdp_cmd
check_ram_addr_gdp_cmd_ret:
	EXX
	JP	(HL)
check_ram_addr_fail:
; HL: address
; B: expected
; A: actual
	LD	E, A
	LD	D, B
	LD	B, H
	LD	C, L
; Print address.
	LD	A, $20
	LD	HL, check_ram_addr_gdp_cmd_ret_2
	JP	gdp_cmd
check_ram_addr_gdp_cmd_ret_2:
	LD	HL, check_ram_addr_write_hex_16_ret
	JP	write_hex_16
check_ram_addr_write_hex_16_ret:
; Print expected.
	LD	A, $20
	LD	HL, check_ram_addr_gdp_cmd_ret_3
	JP	gdp_cmd
check_ram_addr_gdp_cmd_ret_3:
	LD	A, D
	LD	HL, check_ram_addr_write_hex_8_ret
	JP	write_hex_8
check_ram_addr_write_hex_8_ret:
; Print actual.
	LD	A, $20
	LD	HL, check_ram_addr_gdp_cmd_ret_4
	JP	gdp_cmd
check_ram_addr_gdp_cmd_ret_4:
	LD	A, E
	LD	HL, check_ram_addr_write_hex_8_ret_2
	JP	write_hex_8
check_ram_addr_write_hex_8_ret_2:
	HALT

string_startup:
	DB	$A8, $00
	DB	"Memory Test"
	DB	$00

string_testing_memory:
	DB	$21, $00
	DB	"TESTING "
	DB	$00

string_passed:
	DB	$21, $00
	DB	"PASSED"
	DB	$00
