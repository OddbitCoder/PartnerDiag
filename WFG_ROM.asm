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
	JP	GDPUkaz2
GDPUkaz_ret_1:
	LD	A,0x05	; ...in postavimo pero na levi rob.
	LD HL,GDPUkaz_ret_2
	JP	GDPUkaz2
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
	JP	GDPUkaz2
GDPUkaz_ret:

	LD HL,Prelom_ret_2
	JP PrelomVrstice2
Prelom_ret_2:

	LD HL,IzpisiNiz_ret_3
	LD BC,sporocilo_testing_memory
	JP	IzpisiNiz2
IzpisiNiz_ret_3:

;	LD HL,DataBusTest_ret
;	JP DataBusTest
;DataBusTest_ret:

	LD HL,FillRamZero_ret
	JP FillRamZero
FillRamZero_ret:

	; Checkpoint
	LD A,'*'
	LD HL,GdpUkaz_ret_6
	JP GDPUkaz2
GdpUkaz_ret_6:

	OUT	(0x90),A ; Switch to bank 2

	LD HL,FillRamZero_ret_2
	JP FillRamZero
FillRamZero_ret_2:

	; Checkpoint
	LD A,'*'
	LD HL,GdpUkaz_ret_7
	JP GDPUkaz2
GdpUkaz_ret_7:

	OUT	(0x88),A ; Switch back to bank 1

;	; Address Bus Test
;	LD      BC,0001h                ; B=high, C=low mask
;MASK_LOOP:
;    ; probe = 2000h OR BC   (always within 2000h..FFFFh)
;	LD      L,C
;	LD      H,B
;	SET     5,H        ; equivalent to OR 20h on the high byte
;    ; write FF at probe (bank 1)
;    LD      (HL),FFh
;    ; PERFORM CHECKS
;    ; BANK 1 needs to be zeros and $FF at probe
;
;    LD HL,CheckRamVals_ret_2
;    LD D,$11 ; test for probe (yes) + memory bank reference
;    JP CheckRamVals
;CheckRamVals_ret_2:

;    ; BANK 2 needs to be all zeros

;    OUT	(0x90),A ; Switch to bank 2

;    LD HL,CheckRamVals_ret
;    LD D,$02 ; test for probe (no) + memory bank reference
;    JP CheckRamVals
;CheckRamVals_ret:

;	LD      L,C
;	LD      H,B
;	SET     5,H

; remove probe (bank 1)
;	OUT	(0x88),A
;    LD      (HL),0

; write FF at probe (bank 2)
;	OUT	(0x90),A
;    LD      (HL),FFh
;    ; PERFORM CHECKS
;	LD HL,CheckRamVals_ret_3
;    LD D,$12 ; test for probe (yes) + memory bank reference
;    JP CheckRamVals
;CheckRamVals_ret_3:

;	OUT	(0x88),A ; switch to bank 1

;	LD HL,CheckRamVals_ret_4
;    LD D,$01 ; test for probe (no) + memory bank reference
;    JP CheckRamVals
;CheckRamVals_ret_4:

; remove probe
;	OUT	(0x90),A
;	LD   H,B
;	LD   L,C
;	SET 5,H
;	LD      (HL),0

;	OUT	(0x88),A

;	; CHECKPOINT
;	LD A,'A'
;	LD HL,GdpUkaz_ret_8
;	JP GDPUkaz2
;GdpUkaz_ret_8:

	; INCREASE PROBE COUNTER (BC)
;	SLA C
;	RL B
; 	LD   A,B
;    OR   C
;    JR   NZ, MASK_LOOP

    LD HL,ram_test_ret
    LD BC,00h
    JP RamTest
ram_test_ret:

; AFTER THIS TEST, WE NEED TO AGAIN SET C000-FFFF TO ZERO (SHARED MEMORY)

	OUT	(0x90),A

    LD HL,ram_test_ret_2
    LD BC,01h
    JP RamTest
ram_test_ret_2:

	OUT	(0x88),A

    LD HL,ram_test_ret_3
    LD BC,10h
    JP RamTest
ram_test_ret_3:

	OUT	(0x90),A

    LD HL,ram_test_ret_4
    LD BC,11h
    JP RamTest
ram_test_ret_4:

	OUT	(0x88),A

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

GDPUkaz2:
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
	JP	GDPUkaz2

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

IzpisiHex16_2:
	LD	A,B
	EXX
	LD HL,Izpis_ret
	JP	IzpisiHex8_2
Izpis_ret:
	EXX
	LD	A,C
	EXX
	LD HL,Izpis_ret_2
	JP	IzpisiHex8_2
Izpis_ret_2
	EXX
	JP (HL)

IzpisiHex8_2:
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

RamTest:
	EXX
	; B' - complement (yes/no)
	; C' - number to add to the address
	LD BC, 2000h ; start address
RamTest_loop:
	; write
	LD A,B
	XOR C
	EXX
	XOR C
	EX AF,AF'
	LD A,B
	OR A ; check if B is zero
	JR Z,is_zero
	EX AF,AF'
	CPL
	EX AF,AF'
is_zero:
	EX AF,AF'
	EXX
	; check if (BC) is 0 before writing
	LD D,A
	LD A,(BC)
	LD E,A ; actual = (BC)
	OR A ; check if 0
	JR NZ,is_zero_fail
	JR ok
is_zero_fail:
	LD D,0 ; expected = 0
	JR RamTest_fail
ok:
	LD A,D
	LD (BC),A
	; read & check
	LD A,(BC)
	LD E,A
	XOR D
	JR NZ,RamTest_fail
	INC BC
	LD   A,B
    OR   C
    JR   NZ, RamTest_loop ; did we go over $FFFF?
    LD	A,'M'
	LD HL,GDPUkaz_ret_8
	JP	GDPUkaz2
GDPUkaz_ret_8:
    EXX
    JP (HL)
RamTest_fail:
	; D - expected
	; E - actual
	; BC - address
	LD A,' '
	LD HL,gdp_ukaz_ret_5
	JP GDPUkaz2
gdp_ukaz_ret_5:
	LD HL,izpisi_16_ret_3
	JP IzpisiHex16_2
izpisi_16_ret_3:
	LD A,' '
	LD HL,gdp_ukaz_ret_6
	JP GDPUkaz2
gdp_ukaz_ret_6:
	LD A,D
	LD HL,izpisi_8_ret_3
	JP IzpisiHex8_2
izpisi_8_ret_3:
	LD A,' '
	LD HL,gdp_ukaz_ret_7
	JP GDPUkaz2
gdp_ukaz_ret_7:
	LD A,E
	LD HL,izpisi_8_ret_4
	JP IzpisiHex8_2
izpisi_8_ret_4:

	HALT

DataBusTest:

	EXX

    LD      HL,2000h        ; test location
    LD      B,8             ; 8 data lines
    LD      A,01h           ; start with 0000 0001

DBUS_LOOP:
; --- Walking 1s ---
	LD      (HL),A
	LD      E,(HL)
	CP      E
	JR      NZ,DBUS_FAIL    ; if mismatch, bail

; --- Walking 0s (complement) ---
    CPL                     ; complement A (walking 0s)
    LD      (HL),A
    LD      E,(HL)
    CP      E
    JR      NZ,DBUS_FAIL

    CPL                     ; restore original walking-1s
    RLCA                    ; rotate left to next bit
    DJNZ    DBUS_LOOP

DBUS_PASS:
	LD	A,'D'
	LD HL,GDPUkaz_ret_3
	JP	GDPUkaz2
GDPUkaz_ret_3:
	EXX
	JP (HL)

DBUS_FAIL:
	LD D,A
	; D = expected, E = actual
; Print expected
	LD A,D
	LD HL,Izpis_hex_1
	JP IzpisiHex8_2
Izpis_hex_1:
; Print actual
	LD A,' '
	LD HL,GDPUkaz_ret_5
	JP	GDPUkaz2
GDPUkaz_ret_5:
	LD A,E
	LD HL,Izpis_hex_2
	JP IzpisiHex8_2
Izpis_hex_2:
	HALT

; ----------------------------------------

FillRamZero:
    EXX
    LD      HL,2000h
    XOR     A
    LD      (HL),A           ; place one zero at 2000h
    LD      DE,2001h
    LD      BC,0DFFFh        ; remaining bytes: E000 - 1
    LDIR                        ; copy zero from 2000h to 2001h..FFFFh
    EXX
    JP      (HL)

CheckRamVals:
	EXX

	; BC' = counter => probe address can be computed
	; D' = [test for probe?][memory bank reference]

    LD      HL,2000h         ; start
    LD      BC,0E000h        ; count = 2000h..FFFFh (57344 bytes)

_loop:
    LD      A,(HL)           ; fetch byte
    OR      A                ; Z=1 if byte == 0
    JR      NZ,_not_zero     ; bail if any non-zero
_continue:
    INC     HL
    DEC     BC
    LD      A,B              ; test BC != 0 without affecting HL
    OR      C
    JR      NZ,_loop

    ; success
    EXX
    JP      (HL)

_not_zero:
	; do we want to test for probe?
	EXX
	LD A,D
	EXX
	AND  F0h        ; isolate high nibble
	JR   Z, _fail ; if result is zero, flag was false
	; HERE, WE DO WANT TO TEST THE PROBE
	; check if BC' equals HL, then we want $FF instead
	EXX
	LD A,B
	EXX
	SET 5,A
	CP H
	JR NZ,_fail
	EXX
	LD A,C
	EXX
	CP L
	JR NZ,_fail
	; BC' == HL
	LD      A,(HL)
	CP FFh
	JR Z,_continue
_fail:
	; BC' = probe counter
	; HL = address being checked
	; D' = function parameters
	; (HL) = actual value
	; expected = if (probe address)==HL, then FF, else 00
; DE = probe address
	EXX
	LD A,B
	EXX
	LD D,A
	EXX
	LD A,C
	EXX
	LD E,A
	SET 5,D
; Print HL
	LD B,H
	LD C,L
	LD A,' '
	LD HL,gdp_ukaz_ret
	JP GDPUkaz2
gdp_ukaz_ret:
	LD HL,izpisi_16_ret
	JP IzpisiHex16_2
izpisi_16_ret:
; print actual value
	LD A,' '
	LD HL,gdp_ukaz_ret_2
	JP GDPUkaz2
gdp_ukaz_ret_2:
	LD A,(BC)
	LD HL,Izpis_hex_1_2
	JP IzpisiHex8_2
Izpis_hex_1_2:
; print parameters
	LD A,' '
	LD HL,gdp_ukaz_ret_3
	JP GDPUkaz2
gdp_ukaz_ret_3:
	EXX
	LD A,D
	EXX
	LD HL,Izpis_hex_1_4
	JP IzpisiHex8_2
Izpis_hex_1_4:
; print probe address
	LD A,' '
	LD HL,gdp_ukaz_ret_4
	JP GDPUkaz2
gdp_ukaz_ret_4:
	LD B,D
	LD C,E
	LD HL,izpisi_16_ret_2
	JP IzpisiHex16_2
izpisi_16_ret_2:

	HALT

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

; fills RAM $2000-$BFFF with addr (xor-ed hi and lo byte xor-ed with what's in A)
; or the complement of that (if B is set to non-zero)
fill_ram_addr:
	EXX
	LD E,A
	LD HL,$2000
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
	JR NZ,fill_ram_addr_loop
	EXX
	JP (HL)
fill_ram_addr_fail:
	; HL - address
	; 0 - expected
	; A - actual
	LD E,A
	; print address
	LD A,' '
	LD HL,fill_ram_addr_gdp_cmd_ret
	JP GDPUkaz2
fill_ram_addr_gdp_cmd_ret:
	LD B,H
	LD C,L
	LD HL,fill_ram_addr_write_hex_16_ret
	JP IzpisiHex16_2
fill_ram_addr_write_hex_16_ret:
	; print expected
	LD A,' '
	LD HL,fill_ram_addr_gdp_cmd_ret_2
	JP GDPUkaz2
fill_ram_addr_gdp_cmd_ret_2:
	LD A,0
	LD HL,fill_ram_addr_write_hex_8_ret
	JP IzpisiHex8_2
fill_ram_addr_write_hex_8_ret:
	; print actual
	LD A,' '
	LD HL,fill_ram_addr_gdp_cmd_ret_2
	JP GDPUkaz2
fill_ram_addr_gdp_cmd_ret_2:
	LD A,E
	LD HL,fill_ram_addr_write_hex_8_ret
	JP IzpisiHex8_2
fill_ram_addr_write_hex_8_ret:
	HALT

; checks RAM $2000-$BFFF if addr correctly written (xor-ed hi and lo byte xor-ed with what's in A)
; or the complement of that (if B is set to non-zero)
check_ram_addr:
	EXX
	LD E,A
	LD HL,$2000
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
	; A == (HL)?
	LD D,(HL)
	CP D
	JR NZ,check_ram_addr_fail
	INC HL
	LD A,H
	CP $C0
	JR NZ,check_ram_addr_loop
	EXX
	JP (HL)
check_ram_addr_fail:
	; HL - address
	; A - expected
	; D - actual
	HALT

; fills RAM $C000-$FFFF with addr (xor-ed hi and lo byte)
; or the complement of that (if B is set to non-zero)
fill_ram_addr_shared:
	EXX
	LD HL,$C000
fill_ram_addr_shared_loop:
	; check if 0 before writing
	LD A,(HL)
	OR A
	JR NZ,fill_ram_addr_shared_fail
	OUT ($90),A ; bank 2
	LD A,(HL)
	OR A
	JR NZ,fill_ram_addr_shared_fail
	OUT ($88),A ; back to bank 1
	LD A,H
	XOR L
	; complement?
	LD D,A
	EXX
	LD A,B
	OR A
	EXX
	LD A,D
	JR Z,fill_ram_addr_shared_skip_cpl ; Z/NZ from OR
	CPL
fill_ram_addr_shared_skip_cpl:
	LD (HL),A
	INC HL
	LD A,H
	OR L
	JR NZ,fill_ram_addr_shared_loop
	EXX
	JP (HL)
fill_ram_addr_shared_fail:
	; HL - address
	; 0 - expected
	; A - actual
	HALT

; checks RAM $C000-$FFFF if addr correctly written (xor-ed hi and lo byte xor-ed with what's in A)
; or the complement of that (if B is set to non-zero)
check_ram_addr_shared:
	EXX
	LD E,A
	LD HL,$C000
check_ram_addr_shared_loop:
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
	JR Z,check_ram_addr_shared_skip_cpl ; Z/NZ from OR
	CPL
check_ram_addr_shared_skip_cpl:
	; A == (HL)?
	LD D,(HL)
	CP D
	JR NZ,check_ram_addr_shared_fail
	OUT ($90),A ; bank 2
	LD D,(HL)
	CP D
	JR NZ,check_ram_addr_shared_fail
	OUT ($88),A ; back to bank 1
	INC HL
	LD A,H
	OR L
	JR NZ,check_ram_addr_shared_loop
	EXX
	JP (HL)
check_ram_addr_shared_fail:
	; HL - address
	; A - expected
	; D - actual
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