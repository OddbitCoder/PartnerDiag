;
; This is an IDP-G ROM for GDP testing.
; It does not boot IDP.
;
; Created by Oddbit Retro, 2026
;

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
	OUT	($3A), A
	OUT	($3B), A

; Set SS2 to 0.
	OUT	($3E), A
	OUT	($3F), A

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

; SIO "CRT" initialization (keyboard)
	LD	C,0xD9
	LD	HL,0x02B6
	LD	B,0x07
	OTIR

; SIO "LPT" initialization
	LD	C,0xDB
	LD	HL,0x02B6
	LD	B,0x07
	OTIR

; SIO "VAX" initialization
	LD	C,0xE1
	LD	HL,0x02B6
	LD	B,0x07
	OTIR

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

	LD	HL, line_break_ret_1
	JP	line_break
line_break_ret_1:

	LD	HL, write_string_ret_1
	LD	BC, string_version
	JP	write_string
write_string_ret_1:

; Place the pen at the left edge again.
	LD	A, $05
	LD	HL, gdp_cmd_ret_3
	JP	gdp_cmd
gdp_cmd_ret_3:

	LD	HL, line_break_ret_2
	JP	line_break
line_break_ret_2:

	LD	HL, write_string_ret_2
	LD	BC, string_testing_gdp
	JP	write_string
write_string_ret_2:

; GDP diagnostics.
	LD	A, '*'
	CALL	write_char
	LD	HL, 5000
	CALL	msleep

	CALL	avdc_reset
	LD	A, '*'
	CALL	write_char
	LD	HL, 5000
	CALL	msleep

	CALL avdc_clear_screen
	LD	A, '*'
	CALL	write_char
	LD	HL, 5000
	CALL	msleep

	LD	A, '#'
	CALL	write_char

	HALT

; Wait until AVDC status READY flag is set.
avdc_wait_ready:
avdc_wait_ready_loop:
	IN	A, ($39)
	AND	$20
	JR	Z, avdc_wait_ready_loop
	RET

; Wait for one full AVDC access window.
avdc_wait_access:
avdc_wait_access_high:
	IN	A, ($36)
	AND	$10
	JR	Z, avdc_wait_access_high
avdc_wait_access_low:
	IN	A, ($36)
	AND	$10
	JR	NZ, avdc_wait_access_low
	RET

; Wait for completion of a delayed AVDC command.
; Repeats access-window sync until READY is observed.
avdc_wait_long_command:
avdc_wait_long_command_loop:
	CALL	avdc_wait_access
	IN	A, ($39)
	AND	$20
	JR	Z, avdc_wait_long_command_loop
	RET

; Set AVDC cursor address from HL.
avdc_set_cursor_addr:
	CALL	avdc_wait_access
	CALL	avdc_wait_ready
	LD	A, L
	OUT	($3C), A
	LD	A, H
	OUT	($3D), A
	RET

; Write HL as a 16-bit address at current cursor using WRITE_AT_CUR.
avdc_write_addr_at_cursor:
	CALL	avdc_wait_access
	CALL	avdc_wait_ready
	LD	A, L
	OUT	($34), A
	XOR	A
	OUT	($35), A
	LD	A, $AB
	OUT	($39), A
	CALL	avdc_wait_ready
	LD	A, H
	OUT	($34), A
	XOR	A
	OUT	($35), A
	LD	A, $AB
	OUT	($39), A
	RET

; Clear one AVDC text row.
; IN: HL = row start address (row * 132 + 450)
avdc_clear_row:
	PUSH	HL
	CALL	avdc_wait_access
	CALL	avdc_wait_ready

; Set cursor.
	LD	A, L
	OUT	($3C), A
	LD	A, H
	OUT	($3D), A

; Set pointer to row end (addr + 131).
	LD	DE, 131
	ADD	HL, DE
	LD	A, $1A
	OUT	($39), A
	LD	A, L
	OUT	($38), A
	LD	A, H
	OUT	($38), A

; Write cursor to pointer.
	LD	A, 'M'
	OUT	($34), A
	XOR	A
	OUT	($35), A
	LD	A, $BB
	OUT	($39), A
	CALL	avdc_wait_long_command
	POP	HL
	RET

; Clear full AVDC text screen (26 rows).
avdc_clear_screen:
	LD	HL, 450
	LD	B, 26
avdc_clear_screen_loop:
	PUSH	BC
	PUSH	HL
	CALL	avdc_clear_row
	POP	HL
	LD	DE, 132
	ADD	HL, DE
	POP	BC
	DJNZ	avdc_clear_screen_loop
	RET

; Reset and initialize AVDC.
avdc_reset:
	CALL	avdc_wait_access
	CALL	avdc_wait_ready
	XOR	A
	OUT	($39), A
avdc_reset_wait_access_low:
	IN	A, ($36)
	AND	$10
	JR	NZ, avdc_reset_wait_access_low
	XOR	A
	OUT	($39), A

; Set common text attributes.
	LD	A, $C4
	OUT	($32), A

; Wait for V blanking edge on GDP status bit 1.
avdc_reset_wait_vblank_high:
	IN	A, ($20)
	AND	$02
	CP	$02
	JR	NZ, avdc_reset_wait_vblank_high
avdc_reset_wait_vblank_low:
	IN	A, ($20)
	AND	$02
	CP	$02
	JR	Z, avdc_reset_wait_vblank_low

; Set screen start 2.
	XOR	A
	OUT	($3E), A
	OUT	($3F), A

; Write init register sequence.
	LD	A, $10
	OUT	($39), A
	LD	HL, data_avdc_init_reset
	LD	B, 10
avdc_reset_init_loop:
	LD	A, (HL)
	OUT	($38), A
	INC	HL
	DJNZ	avdc_reset_init_loop

; Set screen start 2 again.
	XOR	A
	OUT	($3E), A
	OUT	($3F), A

; Turn display back on.
	LD	A, $3D
	OUT	($39), A

; Write row table.
	LD	HL, 0
	CALL	avdc_set_cursor_addr
	LD	HL, 450
	LD	B, 26
avdc_reset_table_loop:
	PUSH	BC
	PUSH	HL
	CALL	avdc_write_addr_at_cursor
	POP	HL
	LD	DE, 132
	ADD	HL, DE
	POP	BC
	DJNZ	avdc_reset_table_loop
	RET

; Sleep HL milliseconds.
msleep:
msl_loop:
    LD      B, 233
msl_inner_loop:
    NOP
    DJNZ    msl_inner_loop
    DEC     HL
    LD      A, H
    OR      L
    JR      NZ, msl_loop
    RET

; Write character in A.
write_char:
	LD	HL, write_char_ret
	JP	gdp_cmd
write_char_ret:
	RET

; AVDC initialization string.
data_avdc_init:
	DB	$D0, $2F, $0D, $05, $99, $4F, $0A, $EA
	DB	$00, $30

; AVDC init sequence used by avdc_reset.
data_avdc_init_reset:
	DB	$D0, $3E, $BF, $05, $99, $83, $0B, $EA
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

string_startup:
	DB	$A8, $00
	DB	"Oddbit ROM"
	DB	$00

string_version:
	DB	$21, $00
	DB	"[GDP Test v1.0]"
	DB	$00

string_testing_gdp:
	DB	$21, $00
	DB	"TESTING GDP "
	DB	$00
