; ----------------------------------------

	ORG	$0

; ----------------------------------------

; TODO: NMI interrupt handler at $66

	DI

; Inicializacija PIO
	LD	A,0x07
	OUT	(0x31),A
	OUT	(0x33),A
	LD	A,0x0F
	OUT	(0x31),A
	OUT	(0x33),A

	LD	A,0x18
	OUT	(0x30),A
	LD	A,0x6D
	OUT	(0x32),A
	XOR	A
	OUT	(0x39),A
	OUT	(0x36),A
	LD	E,A

; Inicializacija GDP
	XOR	A
	OUT	(0x21),A

; Izbira in spust GDP peresa
	LD	A,0x03
	OUT	(0x21),A

	LD	A,0x04	; Pocxistimo GDP sliko...
	LD HL,GDPUkaz_ret_1
	JP	gdp_cmd
GDPUkaz_ret_1:
	LD	A,0x05	; ...in postavimo pero na levi rob.
	LD HL,GDPUkaz_ret_2
	JP	gdp_cmd
GDPUkaz_ret_2:
	XOR	A
	OUT	(0x39),A
	OUT	(0x30),A

; Inicializacija AVDC
	LD	A,0x00
	OUT	(0x39),A
	LD HL,Zakasnitev_ret
	JP	Zakasnitev2
Zakasnitev_ret:
	LD	HL,niz_init_avdc
	XOR	A

; SS1 := 0
	OUT	(0x3E),A
	OUT	(0x3F),A

; SS2 := 0
	OUT	(0x3A),A
	OUT	(0x3B),A

	LD	A,0x10
	OUT	(0x39),A
	LD	B,0x0A
	LD	C,0x38
	OTIR

	LD	A,0x3D
	OUT	(0x39),A

; Naslov AVDC kurzorja := 0
	XOR	A
	OUT	(0x3D),A
	OUT	(0x3C),A

	LD	HL,0x1FFF
	LD	A,0x1A
	OUT	(0x39),A
	LD	A,L
	OUT	(0x38),A
	LD	A,H
	OUT	(0x38),A

; Zapolni AVDC framebuffer s presledki?
	LD	A,0x20
	OUT	(0x34),A
	XOR	A
	OUT	(0x35),A
	LD	A,0xBB	; Write from cursor to pointer
	OUT	(0x39),A

; Y koordinata GDP peresa := 100
	LD	A,0x64
	OUT	(0x2B),A

	LD HL,Prelom_ret
	JP PrelomVrstice2
Prelom_ret:

	LD HL,IzpisiNiz_ret
	LD	BC,sporocilo_zagon
	JP	IzpisiNiz2
IzpisiNiz_ret:

; Spet postavimo pero na levi rob.
	LD	A,0x05
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

	LD A,0
	LD HL,FillRamZero_ret
	JP fill_ram
FillRamZero_ret:

	; Checkpoint
	LD A,'+'
	LD HL,GdpUkaz_ret_6
	JP gdp_cmd
GdpUkaz_ret_6:

	OUT	(0x90),A ; Switch to bank 2

	LD A,0
	LD HL,FillRamZero_ret_2
	JP fill_ram
FillRamZero_ret_2:

	; Checkpoint
	LD A,'+'
	LD HL,GdpUkaz_ret_7
	JP gdp_cmd
GdpUkaz_ret_7:

	OUT	(0x88),A ; Switch back to bank 1

	LD B,0
	LD A,0
	EXX
	LD HL,$2000
	EXX
	LD HL,fill_ram_addr_ret
	JP fill_ram_addr
fill_ram_addr_ret:

	OUT	(0x90),A ; Switch to bank 2

	LD B,0
	LD A,1
	EXX
	LD HL,$2000
	EXX
	LD HL,fill_ram_addr_ret_2
	JP fill_ram_addr
fill_ram_addr_ret_2:

	OUT	(0x88),A ; Switch back to bank 1

	LD B,0
	LD A,0
	EXX
	LD HL,$2000
	EXX
	LD HL,check_ram_addr_ret
	JP check_ram_addr
check_ram_addr_ret:

	OUT	(0x90),A ; Switch to bank 2

	LD B,0
	LD A,1
	EXX
	LD HL,$2000
	EXX
	LD HL,check_ram_addr_ret_2
	JP check_ram_addr
check_ram_addr_ret_2:

	OUT	(0x88),A ; Switch back to bank 1

	; TEST SHARED MEMORY

	LD B,0
	LD A,0
	EXX
	LD HL,$C000
	EXX
	LD HL,fill_ram_addr_ret_3
	JP fill_ram_addr
fill_ram_addr_ret_3:

	LD B,0
	LD A,0
	EXX
	LD HL,$C000
	EXX
	LD HL,check_ram_addr_ret_3
	JP check_ram_addr
check_ram_addr_ret_3:

	OUT	(0x90),A ; Switch to bank 2

	LD B,0
	LD A,0
	EXX
	LD HL,$C000
	EXX
	LD HL,check_ram_addr_ret_4
	JP check_ram_addr
check_ram_addr_ret_4:

	LD HL,Prelom_ret_4
	JP PrelomVrstice2
Prelom_ret_4:

	LD HL,IzpisiNiz_ret_4
	LD BC,sporocilo_done
	JP	IzpisiNiz2
IzpisiNiz_ret_4:

	HALT

; Inicializacijski niz za AVDC.
niz_init_avdc:
	DB	$D0, $2F, $0D, $05, $99, $4F, $0A, $EA
	DB	$00, $30

; Inicializacijski niz za serijska vrata.
niz_init_ser:
	DB	$18, $04, $44, $03, $C1, $05, $68

; Niz ukazov za GDP, ki premakne pero v spodnji levi kot in pobrisxe vrstico.
niz_premakni_pero_spodnji_levi_kot:
	DB	$03, $00, $05, $01, $0B, $0B, $0B, $0B
	DB	$0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	DB	$0B, $0B, $0B, $0B, $00

; ----------------------------------------

; Niz ukazov za GDP, ki premakne pero na skrajno levo.
niz_premakni_pero_skrajno_levo:
	DB	$21, $00, $0D, $00

; Zagonsko sporocxilo.
sporocilo_zagon:
	DB	$A8, $00
	DB	"Memory Test"
	DB 	$00

gdp_cmd:
	EX	AF,AF'
x00B3:
	IN	A,(0x20)
	AND	0x04
	JR	Z,x00B3
	EX	AF,AF'
	OUT	(0x20),A
	JP	(HL)

Zakasnitev2:
	LD	B,0xFF
x025D:
	NOP
	DJNZ	x025D
	LD	B,0xFF
x025D_3:
	NOP
	DJNZ	x025D_3
	LD	B,0xFF
x025D_4:
	NOP
	DJNZ	x025D_4
	LD	B,0xFF
x025D_5:
	NOP
	DJNZ	x025D_5
	JP (HL)

PrelomVrstice2:
	IN	A,(0x20)
	AND	0x04
	JR	Z,PrelomVrstice2
	LD	A,E
	SUB	0x0C
	LD	E,A
	OUT	(0x36),A
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
; Izberemo nacxin risanja.
	XOR	A
	JP	gdp_cmd

IzpisiNiz2:
	IN	A,(0x20)
	AND	0x04
	JR	Z,IzpisiNiz2
	LD	A,(BC)
	OUT	(0x23),A
	INC	BC
	LD	A,(BC)
	OUT	(0x22),A
	INC	BC
x0251_2:
	LD	A,(BC)
	OR	A
	JR NZ,skip
	JP (HL)
skip:
	IN	A,(0x20)
	AND	0x04
	JR	Z,skip
	LD A,(BC)
	OUT	(0x20),A
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
	AND	0x0F

	CP	0x0A
	JP	M,x0099_2
	ADD	A,0x37
	JR	x009B_2
x0099_2:
	ADD	A,0x30
x009B_2:
	EX AF,AF'
x009B_2_2:
	IN	A,(0x20)
	AND	0x04
	JR	Z,x009B_2_2
	EX	AF,AF'
	OUT	(0x20),A

	LD	A,B
	AND	0x0F

	CP	0x0A
	JP	M,x0099_3
	ADD	A,0x37
	JR	x009B_3
x0099_3:
	ADD	A,0x30
x009B_3:
	EX AF,AF'
x009B_3_2:
	IN	A,(0x20)
	AND	0x04
	JR	Z,x009B_3_2
	EX	AF,AF'
	OUT	(0x20),A

	JP (HL)

; ----------------------------------------

; Vstopna tocxka v memory test.

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
	EXX
	JP (HL)

; fills RAM HL'-$BFFF or $FFFF with addr (xor-ed hi and lo byte xor-ed with what's in A)
; or the complement of that (if B is set to non-zero)
fill_ram_addr:
	EXX
	; HL is passed in by the caller
	LD E,A
fill_ram_addr_loop:
	; check if 0 before writing
	LD A,(HL)
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
	JR Z,fill_ram_addr_skip_cpl ; Z/NZ from OR
	CPL
fill_ram_addr_skip_cpl:
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
	LD A,'*'
	LD HL,fill_ram_addr_gdp_cmd_ret
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret:
	EXX
	JP (HL)
fill_ram_addr_fail:
	; HL - address
	; 0 - expected
	; A - actual
	LD E,A
	LD B,H
	LD C,L
	; print address
	LD A,' '
	LD HL,fill_ram_addr_gdp_cmd_ret_2
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret_2:
	LD HL,fill_ram_addr_write_hex_16_ret
	JP write_hex_16
fill_ram_addr_write_hex_16_ret:
	; print expected
	LD A,' '
	LD HL,fill_ram_addr_gdp_cmd_ret_3
	JP gdp_cmd
fill_ram_addr_gdp_cmd_ret_3:
	LD A,0
	LD HL,fill_ram_addr_write_hex_8_ret
	JP write_hex_8
fill_ram_addr_write_hex_8_ret:
	; print actual
	LD A,' '
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
	LD A,'*'
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
	LD A,' '
	LD HL,check_ram_addr_gdp_cmd_ret_2
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret_2:
	LD HL,check_ram_addr_write_hex_16_ret
	JP write_hex_16
check_ram_addr_write_hex_16_ret:
	; print expected
	LD A,' '
	LD HL,check_ram_addr_gdp_cmd_ret_3
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret_3:
	LD A,D
	LD HL,check_ram_addr_write_hex_8_ret
	JP write_hex_8
check_ram_addr_write_hex_8_ret:
	; print actual
	LD A,' '
	LD HL,check_ram_addr_gdp_cmd_ret_4
	JP gdp_cmd
check_ram_addr_gdp_cmd_ret_4:
	LD A,E
	LD HL,check_ram_addr_write_hex_8_ret_2
	JP write_hex_8
check_ram_addr_write_hex_8_ret_2:
	HALT

; ----------------------------------------

; Sporocxilo o testiranju spomina.
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