; ----------------------------------------

	ORG	$0000

; ----------------------------------------

; TODO: NMI interrupt handler at $0066

	DI

; PIO initialization
	LD	A,$07
	OUT	($31),A
	OUT	($33),A
	LD	A,$0F
	OUT	($31),A
	OUT	($33),A

	LD	A,$18
	OUT	($30),A
	LD	A,$6D
	OUT	($32),A
	XOR	A
	OUT	($39),A
	OUT	($36),A
	LD	E,A

; GDP initialization
	XOR	A
	OUT	($21),A

; Select and lower GDP pen
	LD	A,$03
	OUT	($21),A

	LD	A,$04	; Clear GDP image...
	LD HL,GDPUkaz_ret_1
	JP	gdp_cmd
GDPUkaz_ret_1:
	LD	A,$05	; ...and place the pen at the left edge.
	LD HL,GDPUkaz_ret_2
	JP	gdp_cmd
GDPUkaz_ret_2:
	XOR	A
	OUT	($39),A
	OUT	($30),A

; AVDC initialization
	LD	A,$00
	OUT	($39),A
	LD HL,Zakasnitev_ret
	JP	Zakasnitev2
Zakasnitev_ret:
	LD	HL,niz_init_avdc
	XOR	A

; SS1 := 0
	OUT	($3E),A
	OUT	($3F),A

; SS2 := 0
	OUT	($3A),A
	OUT	($3B),A

	LD	A,$10
	OUT	($39),A
	LD	B,$0A
	LD	C,$38
	OTIR

	LD	A,$3D
	OUT	($39),A

; AVDC cursor address := 0
	XOR	A
	OUT	($3D),A
	OUT	($3C),A

	LD	HL,$1FFF
	LD	A,$1A
	OUT	($39),A
	LD	A,L
	OUT	($38),A
	LD	A,H
	OUT	($38),A

; Fill AVDC framebuffer with spaces?
	LD	A,$20
	OUT	($34),A
	XOR	A
	OUT	($35),A
	LD	A,$BB	; Write from cursor to pointer
	OUT	($39),A

; GDP pen Y coordinate := 100
	LD	A,$64
	OUT	($2B),A

	LD HL,Prelom_ret
	JP PrelomVrstice2
Prelom_ret:

	LD HL,IzpisiNiz_ret
	LD	BC,sporocilo_zagon
	JP	IzpisiNiz2
IzpisiNiz_ret:

; Place the pen at the left edge again.
	LD	A,$05
	LD HL,GDPUkaz_ret
	JP	gdp_cmd
GDPUkaz_ret:

	LD HL,Prelom_ret_2
	JP PrelomVrstice2
Prelom_ret_2:

	LD HL,IzpisiNiz_ret_3
	LD BC,sporocilo_testing_memory
	JP	IzpisiNiz2
IzpisiNiz_ret_3:

	LD A,$00
	LD HL,FillRamZero_ret
	JP fill_ram
FillRamZero_ret:

	OUT	($90),A ; Switch to bank 2

	LD A,$00
	LD HL,FillRamZero_ret_2
	JP fill_ram
FillRamZero_ret_2:

	OUT	($88),A ; Switch back to bank 1

	LD B,$00

repeat_with_B1:

	LD A,$00
	EXX
	LD HL,$2000
	EXX
	LD HL,fill_ram_addr_ret
	JP fill_ram_addr
fill_ram_addr_ret:

	OUT	($90),A ; Switch to bank 2

	LD A,$01
	EXX
	LD HL,$2000
	EXX
	LD HL,fill_ram_addr_ret_2
	JP fill_ram_addr
fill_ram_addr_ret_2:

	OUT	($88),A ; Switch back to bank 1

	LD A,$00
	EXX
	LD HL,$2000
	EXX
	LD HL,check_ram_addr_ret
	JP check_ram_addr
check_ram_addr_ret:

	OUT	($90),A ; Switch to bank 2

	LD A,$01
	EXX
	LD HL,$2000
	EXX
	LD HL,check_ram_addr_ret_2
	JP check_ram_addr
check_ram_addr_ret_2:

	OUT	($88),A ; Switch back to bank 1

	; TEST SHARED MEMORY

	LD A,$00
	EXX
	LD HL,$C000
	EXX
	LD HL,fill_ram_addr_ret_3
	JP fill_ram_addr
fill_ram_addr_ret_3:

	LD A,$00
	EXX
	LD HL,$C000
	EXX
	LD HL,check_ram_addr_ret_3
	JP check_ram_addr
check_ram_addr_ret_3:

	OUT	($90),A ; Switch to bank 2

	LD A,$00
	EXX
	LD HL,$C000
	EXX
	LD HL,check_ram_addr_ret_4
	JP check_ram_addr
check_ram_addr_ret_4:

	OUT	($88),A

	LD A,B
	OR A
	JR NZ,done

	LD A,$FF
	LD HL,FillRamZero_ret_3
	JP fill_ram
FillRamZero_ret_3

	OUT	($90),A ; Switch to bank 2

	LD A,$FF
	LD HL,FillRamZero_ret_4
	JP fill_ram
FillRamZero_ret_4:

	OUT	($88),A ; Switch back to bank 1

	LD B,$01
	JP repeat_with_B1

done:
	LD HL,Prelom_ret_4
	JP PrelomVrstice2
Prelom_ret_4:

	LD HL,IzpisiNiz_ret_4
	LD BC,sporocilo_done
	JP	IzpisiNiz2
IzpisiNiz_ret_4:

	HALT

; AVDC initialization string.
niz_init_avdc:
	DB	$D0, $2F, $0D, $05, $99, $4F, $0A, $EA
	DB	$00, $30

; Serial port initialization string.
niz_init_ser:
	DB	$18, $04, $44, $03, $C1, $05, $68

; GDP command string that moves the pen to the bottom-left corner and clears the line.
niz_premakni_pero_spodnji_levi_kot:
	DB	$03, $00, $05, $01, $0B, $0B, $0B, $0B
	DB	$0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	DB	$0B, $0B, $0B, $0B, $00

; ----------------------------------------

; GDP command string that moves the pen to the far left.
niz_premakni_pero_skrajno_levo:
	DB	$21, $00, $0D, $00

; Boot message.
sporocilo_zagon:
	DB	$A8, $00
	DB	"Memory Test"
	DB 	$00

gdp_cmd:
	EX	AF,AF'
x00B3:
	IN	A,($20)
	AND	$04
	JR	Z,x00B3
	EX	AF,AF'
	OUT	($20),A
	JP	(HL)

Zakasnitev2:
	LD	B,$FF
x025D:
	NOP
	DJNZ	x025D
	LD	B,$FF
x025D_3:
	NOP
	DJNZ	x025D_3
	LD	B,$FF
x025D_4:
	NOP
	DJNZ	x025D_4
	LD	B,$FF
x025D_5:
	NOP
	DJNZ	x025D_5
	JP (HL)

PrelomVrstice2:
	IN	A,($20)
	AND	$04
	JR	Z,PrelomVrstice2
	LD	A,E
	SUB	$0C
	LD	E,A
	OUT	($36),A
	EXX
	LD	BC,niz_premakni_pero_spodnji_levi_kot
	LD HL,IzpisiNiz_ret_1
	JP	IzpisiNiz2
IzpisiNiz_ret_1:
	LD	BC,niz_premakni_pero_skrajno_levo
	LD HL, IzpisiNiz_ret_2
	JP	IzpisiNiz2
IzpisiNiz_ret_2:
	EXX
; Select drawing mode.
	XOR	A
	JP	gdp_cmd

IzpisiNiz2:
	IN	A,($20)
	AND	$04
	JR	Z,IzpisiNiz2
	LD	A,(BC)
	OUT	($23),A
	INC	BC
	LD	A,(BC)
	OUT	($22),A
	INC	BC
x0251_2:
	LD	A,(BC)
	OR	A
	JR NZ,skip
	JP (HL)
skip:
	IN	A,($20)
	AND	$04
	JR	Z,skip
	LD A,(BC)
	OUT	($20),A
	INC	BC
	JR	x0251_2

write_hex_16:
	LD	A,B
	EXX
	LD HL,Izpis_ret
	JP	write_hex_8
Izpis_ret:
	EXX
	LD	A,C
	EXX
	LD HL,Izpis_ret_2
	JP	write_hex_8
Izpis_ret_2
	EXX
	JP (HL)

write_hex_8:
	LD	B,A
	SRA	A
	SRA	A
	SRA	A
	SRA	A
	AND	$0F

	CP	$0A
	JP	M,x0099_2
	ADD	A,$37
	JR	x009B_2
x0099_2:
	ADD	A,$30
x009B_2:
	EX AF,AF'
x009B_2_2:
	IN	A,($20)
	AND	$04
	JR	Z,x009B_2_2
	EX	AF,AF'
	OUT	($20),A

	LD	A,B
	AND	$0F

	CP	$0A
	JP	M,x0099_3
	ADD	A,$37
	JR	x009B_3
x0099_3:
	ADD	A,$30
x009B_3:
	EX AF,AF'
x009B_3_2:
	IN	A,($20)
	AND	$04
	JR	Z,x009B_3_2
	EX	AF,AF'
	OUT	($20),A

	JP (HL)

; ----------------------------------------

; Entry point to memory test.

; fills RAM $2000-$FFFF with what's in A
fill_ram:
	EXX
	LD E,A
	LD HL,$2000
fill_ram_loop:
	LD (HL),E
	INC HL
	LD A,H
	OR L
	JR NZ,fill_ram_loop
	LD A,$2B
	LD HL,fill_ram_gdp_cmd_ret
	JP gdp_cmd
fill_ram_gdp_cmd_ret:
	EXX
	JP (HL)

; fills RAM HL'-$BFFF or $FFFF with addr (xor-ed hi and lo byte xor-ed with what's in A)
; or the complement of that (if B is set to non-zero)
fill_ram_addr:
	EXX
	; HL is passed in by the caller
	LD E,A
fill_ram_addr_loop:
	; check if $00 or $FF before writing
	LD A,(HL)
	LD D,A
	EXX
	LD A,B
	OR A
	EXX
	LD A,D
	JR Z,fill_ram_addr_skip_cpl
	CPL
fill_ram_addr_skip_cpl:
	OR A
	JR NZ,fill_ram_addr_fail
	LD A,H
	XOR L
	XOR E
	; complement?
	LD D,A
	EXX
	LD A,B
	OR A
	EXX
	LD A,D
	JR Z,fill_ram_addr_skip_cpl_2 ; Z/NZ from OR
	CPL
fill_ram_addr_skip_cpl_2:
	LD (HL),A
	INC HL
	LD A,H
	CP $C0
	JR NZ,fill_ram_addr_not_C000
	LD A,L
	OR A
	JR NZ,fill_ram_addr_not_C000
	JR fill_ram_addr_done
fill_ram_addr_not_C000:
	LD A,H
	OR L
	JR NZ,fill_ram_addr_loop
fill_ram_addr_done:
	LD A,$2A
	LD HL,fill_ram_addr_gdp_cmd_ret
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret:
	EXX
	JP (HL)
fill_ram_addr_fail:
	; HL - address
	; $00 - expected
	; A - actual
	LD E,A
	LD B,H
	LD C,L
	; print address
	LD A,$20
	LD HL,fill_ram_addr_gdp_cmd_ret_2
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret_2:
	LD HL,fill_ram_addr_write_hex_16_ret
	JP write_hex_16
fill_ram_addr_write_hex_16_ret:
	; print expected
	LD A,$20
	LD HL,fill_ram_addr_gdp_cmd_ret_3
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret_3:
	LD A,$00
	LD HL,fill_ram_addr_write_hex_8_ret
	JP write_hex_8
fill_ram_addr_write_hex_8_ret:
	; print actual
	LD A,$20
	LD HL,fill_ram_addr_gdp_cmd_ret_4
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret_4:
	LD A,E
	LD HL,fill_ram_addr_write_hex_8_ret_2
	JP write_hex_8
fill_ram_addr_write_hex_8_ret_2:
	HALT

; checks RAM HL'-$BFFF or $FFFF if addr is there (xor-ed hi and lo byte xor-ed with what's in A)
; or the complement of that (if B is set to non-zero)
check_ram_addr:
	EXX
	; HL is passed in by the caller
	LD E,A
check_ram_addr_loop:
	LD A,H
	XOR L
	XOR E
	; complement?
	LD D,A
	EXX
	LD A,B
	OR A
	EXX
	LD A,D
	JR Z,check_ram_addr_skip_cpl ; Z/NZ from OR
	CPL
check_ram_addr_skip_cpl:
	LD B,A
	LD A,(HL)
	CP B
	JR NZ,check_ram_addr_fail
	INC HL
	LD A,H
	CP $C0
	JR NZ,check_ram_addr_not_C000
	LD A,L
	OR A
	JR NZ,check_ram_addr_not_C000
	JR check_ram_addr_done
check_ram_addr_not_C000:
	LD A,H
	OR L
	JR NZ,check_ram_addr_loop
check_ram_addr_done:
	LD A,$2A
	LD HL,check_ram_addr_gdp_cmd_ret
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret:
	EXX
	JP (HL)
check_ram_addr_fail:
	; HL - address
	; B - expected
	; A - actual
	LD E,A
	LD D,B
	LD B,H
	LD C,L
	; print address
	LD A,$20
	LD HL,check_ram_addr_gdp_cmd_ret_2
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret_2:
	LD HL,check_ram_addr_write_hex_16_ret
	JP write_hex_16
check_ram_addr_write_hex_16_ret:
	; print expected
	LD A,$20
	LD HL,check_ram_addr_gdp_cmd_ret_3
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret_3:
	LD A,D
	LD HL,check_ram_addr_write_hex_8_ret
	JP write_hex_8
check_ram_addr_write_hex_8_ret:
	; print actual
	LD A,$20
	LD HL,check_ram_addr_gdp_cmd_ret_4
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret_4:
	LD A,E
	LD HL,check_ram_addr_write_hex_8_ret_2
	JP write_hex_8
check_ram_addr_write_hex_8_ret_2:
	HALT

; ----------------------------------------

; Memory testing message.
sporocilo_testing_memory:
	DB	$21, $00
	DB	"TESTING "
	DB 	$00

; ----------------------------------------

sporocilo_initializing:
	DB	$21, $00
	DB	"INITIALIZING "
	DB 	$00

sporocilo_done:
	DB	$21, $00
	DB	"PASSED"
	DB 	$00
