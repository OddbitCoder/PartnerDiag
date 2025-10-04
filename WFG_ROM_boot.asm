;
;  _____ _____  _____  __          ________ _____     ____   ____   ____ _______
; |_   _|  __ \|  __ \ \ \        / /  ____/ ____|   |  _ \ / __ \ / __ \__   __|
;   | | | |  | | |__) |_\ \  /\  / /| |__ | |  __    | |_) | |  | | |  | | | |
;   | | | |  | |  ___/___\ \/  \/ / |  __|| | |_ |   |  _ <| |  | | |  | | | |
;  _| |_| |__| | |        \  /\  /  | |   | |__| |   | |_) | |__| | |__| | | |
; |_____|_____/|_|         \/  \/   |_|    \_____|   |____/ \____/ \____/  |_|
;
; This is an IDP-WFG boot ROM. It does not use any stack or RAM before the
; RAM test.
;
; Created by Oddbit Retro, October 2025
;

	addr_trampoline EQU $F600
	addr_cpmldr EQU $E000
	addr_scroll EQU FFEBh
	addr_ffd0 EQU $FFD0
	addr_ffd1 EQU $FFD1
	addr_ffd2 EQU $FFD2
	addr_ffd4 EQU $FFD4
	addr_ffd5 EQU $FFD5
	addr_ffd7 EQU $FFD7
	addr_ffd8 EQU $FFD8

	DI

; GDP PIO initialization.
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
	LD	HL, line_break_1
	JP	line_break
line_break_1:
	LD	HL, write_string_ret_1
	LD	BC, string_version
	JP	write_string
write_string_ret_1:
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
	LD	A, $AA
	LD	HL, fill_ram_ret
	JP	fill_ram
fill_ram_ret:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $AA
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

	LD	A, $55
	LD	HL, fill_ram_ret_3
	JP	fill_ram
fill_ram_ret_3:
	OUT	($90), A  ; Switch to bank 2.
	LD	A, $55
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

; -----------------------------------------------------

	OUT	($88), A  ; Do we need to switch to bank 1?

	LD	A, E
	LD	(addr_scroll), A  ; Stop using E for scroll.

; Initialize SIO "CRT" channel (keyboard).
	LD	C, $D9
	LD	HL, data_init_ser
	LD	B, $07
	OTIR

; Initialize SIO "LPT" channel.
	LD	C, $DB
	LD	HL, data_init_ser
	LD	B, $07
	OTIR

; Initialize SIO "VAX" channel.
	LD	C, $E1
	LD	HL, data_init_ser
	LD	B, $07
	OTIR

	LD	SP, $FFC0

	CALL	fdc_init

	JP	fd_boot

; -----------------------------------------------------

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

data_init_ser:
	DB	$18, $04, $44, $03, $C1, $05, $68

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
; Check if $AA or $55 before writing.
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
	CP	$AA
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
; $AA: expected
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
	LD	A, $AA
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
	DB	"Oddbit ROM"
	DB	$00

string_version:
	DB	$21, $00
	DB	"[IDP-WFG Boot v1.0 Charlie]"
	DB	$00

string_testing_memory:
	DB	$21, $00
	DB	"TESTING RAM "
	DB	$00

string_passed:
	DB	$21, $00
	DB	"PASSED"
	DB	$00

; -----------------------------------------------------

fd_boot:
	CALL	fd_load_cpmldr
	LD	A,(addr_cpmldr)	; Prvi bajt prvega sektorja...
	CP	0xC3	; ... mora biti opcode za brezpogojni JP...
	JP	Z,x04EA
	CP	0x31	; ... ali LD SP, nn
	JP	Z,x04EA
	LD	HL,sporocilo_no_system_on_disk
	JP	error

; Nalagalnik OSa je nalozxen; skocximo vanj
x04EA:
	JP	addr_trampoline

fd_load_cpmldr:
	LD	A,0x13
	LD	(addr_ffd8),A
	XOR	A
	LD	(addr_ffd0),A
	CALL	x0351
	LD	HL,0xE000
	LD	(addr_ffd2),HL
x0496:
	XOR	A
	INC	A
	LD	(addr_ffd4),A
x049B:
	CALL	x0371
	JP	NZ,x06D1
	LD	DE,0x0100 ; NI NASLOV
	LD	HL,(addr_ffd2)
	ADD	HL,DE
	LD	(addr_ffd2),HL
	LD	A,(addr_ffd4)
	INC	A
	LD	(addr_ffd4),A
	LD	HL,0xFFD8
	CP	(HL)
	JP	NZ,x049B
	LD	A,(addr_ffd7)
	OR	A
	RET	NZ
	INC	A
	LD	(addr_ffd7),A
	LD	A,0x0E
	LD	(addr_ffd8),A
	JP	x0496

x0351:
	LD	A,0x07
	CALL	x0337
	LD	A,(addr_ffd0)
	CALL	x0337
	EI
	HALT
	LD	A,0x08
	CALL	x0337
	CALL	x0345
	CALL	x0345
	XOR	A
	LD	(addr_ffd1),A
	LD	(addr_ffd7),A
	RET

x0371:
	CALL	x03ED
	RET	NZ
	LD	A,0x0A
	LD	(addr_ffd5),A
x037A:
	LD	A,0x05
	OUT	(0xC0),A
	LD	A,0xCF
	OUT	(0xC0),A
	CALL	x045C
	LD	HL,data_init_fdc
	OTIR
	LD	A,0x06
	OR	0x40
	CALL	x042A
	CALL	x0446
x0394:
	EI
	HALT
	JP	C,x03AB
	IN	A,(0x98)
	AND	0x01
	JP	NZ,x0394
	LD	HL,sporocilo_floppy_disk_not_ready
	CALL	write_lnbrk_and_string
	OUT	(0x98),A
	JP	x0394
x03AB:
	LD	A,0x03
	OUT	(0xCA),A
	CALL	x0345
	CALL	x0345
	PUSH	AF
	LD	B,0x05
x03B8:
	CALL	x0345
	DEC	B
	JP	NZ,x03B8
	POP	AF
	CP	0x80
	RET	Z
	LD	A,(addr_ffd5)
	OR	A
	JP	Z,x03EB
	DEC	A
	LD	(addr_ffd5),A
	LD	A,(addr_ffd1)
	PUSH	AF
	INC	A
	LD	(addr_ffd1),A
	LD	A,(addr_ffd7)
	PUSH	AF
	CALL	x03ED
	POP	AF
	LD	(addr_ffd7),A
	POP	AF
	LD	(addr_ffd1),A
	CALL	x03ED
	JP	x037A
x03EB:
	INC	A
	RET

x06D1:
	LD	HL,sporocilo_floppy_disk_malfunction
error:
	CALL	write_lnbrk_and_string
	JP	UkaznaVrstica

x0337:
	PUSH	AF
x0338:
	IN	A,(0xF0)
	AND	0xC0
	CP	0x80
	JP	NZ,x0338
	POP	AF
	OUT	(0xF1),A
	RET

x0345:
	IN	A,(0xF0)
	AND	0xC0
	CP	0xC0
	JP	NZ,x0345
	IN	A,(0xF1)
	RET

x03ED:
	CALL	x0501
	LD	A,0x0F
	CALL	x0337
	CALL	x041B
	CALL	x0337
	LD	A,(addr_ffd1)
	CALL	x0337
	EI
	HALT
	LD	A,0x08
	CALL	x0337
	CALL	x0345
	CALL	x0345
	LD	B,A
	LD	A,(addr_ffd1)
	CP	B
	JP	Z,x0419
	XOR	A
	INC	A
	RET
x0419:
	XOR	A
	RET

x045C:
	LD	A,0x79
	OUT	(0xC0),A
	LD	HL,(addr_ffd2)
	LD	A,L
	OUT	(0xC0),A
	LD	A,H
	OUT	(0xC0),A
	LD	B,0x0B
	LD	C,0xC0
	RET

x042A:
	CALL	x0337
	CALL	x041B
	CALL	x0337
	LD	A,(addr_ffd1)
	CALL	x0337
	LD	A,(addr_ffd7)
	CALL	x0337
	LD	A,(addr_ffd4)
	CALL	x0337
	RET

x0446:
	LD	A,0x01
	CALL	x0337
	LD	A,(addr_ffd4)
	CALL	x0337
	LD	A,0x0A
	CALL	x0337
	LD	A,0xFF
	CALL	x0337
	RET

x0501:
	CALL	x04ED
	JP	NZ,x050C
	OUT	(0x98),A
	CALL	x04F2
x050C:
	XOR	A
	OUT	(0x98),A
	LD	A,0x47
	OUT	(0xC8),A
	OUT	(0xC9),A
	LD	A,0x82
	OUT	(0xC8),A
	OUT	(0xC9),A
	LD	A,0xA7
	OUT	(0xCA),A
	LD	A,0xFF
	OUT	(0xCA),A
	RET

x041B:
	LD	A,(addr_ffd7)
	RLCA
	RLCA
	AND	0x04
	PUSH	BC
	LD	B,A
	LD	A,(addr_ffd0)
	OR	B
	POP	BC
	RET

x04ED:
	IN	A,(0x98)
	AND	0x01
	RET

x04F2:
	LD	A,0xFF
	PUSH	BC
x04F5:
	LD	B,0xFF
x04F7:
	DEC	B
	JP	NZ,x04F7
	DEC	A
	JP	NZ,x04F5
	POP	BC
	RET

fdc_init:
	DI
	IM	2
	LD	HL,ivt
	LD	A,L
	OUT	(0xE8),A
	OUT	(0xC8),A
	LD	A,H
	LD	I,A
	EI
	HALT
	LD	A,0x08
	CALL	x0337
	CALL	x0345
	CALL	x0345
	LD	A,0x03
	CALL	x0337
	LD	A,0x0D
	AND	0x0F
	RLCA
	RLCA
	RLCA
	RLCA
	LD	B,A
	LD	A,0x0E
	AND	0x0F
	OR	B
	CALL	x0337
	LD	A,0x04
	RLCA
	AND	0xFE
	CALL	x0337
	RET

; WARNME: location!!!!
ivt:
	DW	FDCIntHandler, CTCIntHandler, NeznanIntHandler

FDCIntHandler:
	EI
	SCF
	RETI

CTCIntHandler:
	LD	A,0x03
	OUT	(0xC9),A
	CALL	do_reti
	EI
	LD	HL,sporocilo_hard_disk_not_ready
	JP	error

; ----------------------------------------

do_reti:
	RETI

NeznanIntHandler:
	EI
	SCF
	CCF
	RETI

; Init string za FDC
data_init_fdc:
	DB	$FF, $00, $14, $28, $85, $F1, $8A, $CF
	DB	$01, $CF, $87, $FF, $00, $14, $28, $85
	DB	$F1, $8A, $CF, $05, $CF, $87

sporocilo_no_system_on_disk:
	DB	$21, $00
	DB	"NO SYSTEM ON DISK"
	DB	$00

write_lnbrk_and_string:
	PUSH DE
	LD A,(addr_scroll)
	LD E,A

	LD HL,write_lnbrk_and_string_line_break_ret
	JP line_break
write_lnbrk_and_string_line_break_ret:

	LD A,E
	LD (addr_scroll),A
	POP DE
	PUSH BC
	PUSH HL
	;LD BC,HL
	LD B,H
	LD C,L

	LD HL,write_lnbrk_and_string_write_string_ret
	JP write_string
write_lnbrk_and_string_write_string_ret:

	POP HL
	POP BC
	RET

sporocilo_floppy_disk_malfunction:
	DB	$21, $00
	DB	"FLOPPY DISK MALFUNCTION"
	DB 	$00

sporocilo_floppy_disk_not_ready:
	DB	$21, $00
	DB	"FLOPPY DISK NOT READY"
	DB	$00

sporocilo_hard_disk_not_ready:
	DB	$21, $00
	DB	"HARD DISK NOT READY"
	DB	$00