	Trampolin equ F600h
	CPMLDR equ E000h
	Scroll equ FFEBh
	Neznano1 equ FFD0h
	Neznano2 equ FFD1h
	Neznano3 equ FFD2h
	Neznano4 equ FFD4h
	Neznano5 equ FFD5h
	Neznano6 equ FFD7h
	Neznano7 equ FFD8h

; ----------------------------------------

	ORG	$0

; ----------------------------------------

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

; GDP
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

; Inicializacija SIO "CRT" kanala (za tipkovnico)
	LD	C,0xD9
	LD	HL,niz_init_ser
	LD	B,0x07
	OTIR

; Inicializacija SIO "LPT" kanala
	LD	C,0xDB
	LD	HL,niz_init_ser
	LD	B,0x07
	OTIR

; Inicializacija SIO "VAX" kanala
	LD	C,0xE1
	LD	HL,niz_init_ser
	LD	B,0x07
	OTIR

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
	LD HL,Prelom_ret_2
	JP PrelomVrstice2
Prelom_ret_2:
	LD HL,IzpisiHex16_ret
	LD BC,B00Bh
	JP IzpisiHex16_2
IzpisiHex16_ret:

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
	DB	"Oddbit Retro"
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

; Procedure za izpis sxestnajstisxkih sxtevil.

IzpisiHex16:
	CALL	PrelomVrstice
	LD	A,H
	CALL	IzpisiHex8
	LD	A,L
	CALL	IzpisiHex8
	LD	A,0x20	; ' '
	JP	GDPUkaz
IzpisiHex8:
	PUSH	BC
	LD	B,A
	SRA	A
	SRA	A
	SRA	A
	SRA	A
	AND	0x0F
	CALL	IzpisiHex4
	LD	A,B
	AND	0x0F
	CALL	IzpisiHex4
	POP	BC
	RET
IzpisiHex4:
	CP	0x0A
	JP	M,x0099
	ADD	A,0x37
	JR	x009B
x0099:
	ADD	A,0x30
x009B:
	CALL	GDPUkaz
	RET

; ----------------------------------------

BeriInIzpisiZnak:
	IN	A,(0xD9)
	BIT	0,A
	JR	Z,BeriInIzpisiZnak	; Cxakaj, da je znak na voljo.
	IN	A,(0xD8)
	RES	7,A
	CP	0x20
	RET	C	; Cxe je kontrolni znak, koncxamo.

; ----------------------------------------

; Posxlje ukaz na GDP.

GDPUkaz:
	CALL	CakajGDP
	OUT	(0x20),A
	RET

; ----------------------------------------

; Pocxaka, da GDP koncxa izvajanje morebitnega ukaza.

CakajGDP:
	PUSH	AF
x00B3_4:
	IN	A,(0x20)
	AND	0x04
	JR	Z,x00B3_4
	POP	AF
	RET

; ----------------------------------------

; Izvede prelom vrstice.

; Pomaknemo vsebino zaslona 12 pikslov navzgor.
PrelomVrstice:
	CALL	CakajGDP
	LD	A,(Scroll)
	SUB	0x0C
	LD	(Scroll),A
	OUT	(0x36),A
	PUSH	HL
; Izbrisxemo novo vrstico.
	LD	HL,niz_premakni_pero_spodnji_levi_kot
	CALL	IzpisiNiz
; Premaknemo pero na levo.
	LD	HL,niz_premakni_pero_skrajno_levo
	CALL	IzpisiNiz
	POP	HL
; Izberemo nacxin risanja.
	XOR	A
	JP	GDPUkaz

; ----------------------------------------



; ----------------------------------------

; Vstopna tocxka v memory test.

	START_ADDR      EQU 2000h
	END_HI          EQU 0FFh
	END_LO_STOP     EQU 081h            ; stop when L reaches 81h in FFxx page

AddrBusTest:
    ; Fill background with 00h
    LD      HL,START_ADDR
FILL_LOOP:
    XOR     A
    LD      (HL),A
    INC     HL
    LD      A,H
    CP      END_HI
    JR      C,FILL_LOOP
    LD      A,L
    CP      END_LO_STOP
    JR      C,FILL_LOOP

    ; Masks: 0001h << k up to 8000h (tests A0..A15 relative to base)
    LD      BC,0001h                ; B=high, C=low mask
MASK_LOOP:
    ; DE = probe = 2000h OR BC   (always within 2000h..FFFFh)
    LD      D,20h                   ; START_ADDR high
    LD      E,00h                   ; START_ADDR low
    LD      A,E
    OR      C
    LD      E,A
    LD      A,D
    OR      B
    LD      D,A                     ; DE = probe

    ; write FF at probe
    LD      H,D
    LD      L,E
    LD      A,0FFh
    LD      (HL),A

    ; verify whole window: only probe is FF, all others 00
    LD      HL,START_ADDR
VERIFY_LOOP:
    LD      A,H
    CP      D
    JR      NZ, NOT_PROBE_ROW
    LD      A,L
    CP      E
    JR      NZ, NOT_PROBE
    ; HL == DE → expect FF
    LD      A,(HL)          ; actual
    CP      0FFh
    JR      NZ, FAIL_AT_PROBE
    JR      ADV

NOT_PROBE_ROW:
NOT_PROBE:
    LD      A,(HL)          ; actual
    OR      A               ; compare with 00
    JR      NZ, FAIL_AT_OTHER

ADV:
    INC     HL
    LD      A,H
    CP      END_HI
    JR      C, VERIFY_LOOP
    LD      A,L
    CP      END_LO_STOP
    JR      C, VERIFY_LOOP

    ; restore 00 at probe
    LD      H,D
    LD      L,E
    XOR     A
    LD      (HL),A

    ; next mask: BC <<= 1 ; stop after 8000h processed
    SLA     C
    RL      B
    LD      A,B
    OR      C
    JR      NZ, MASK_LOOP

    ; success
    LD      A,'*'
    CALL    GDPUkaz
    RET

; ------------------------------------------------------------
; FAIL HANDLERS
; ------------------------------------------------------------

FAIL_AT_PROBE:
; HL = probe address
; DE = probe address (expected location)
; A  = actual value read (≠ FFh)
; Expectation was FFh but cell returned something else
FAIL_AT_OTHER:
; HL = address being checked (not the probe)
; DE = probe address (the only one supposed to contain FFh)
; A  = actual value read (≠ 00h)
; Expectation was 00h but another cell was corrupted (aliasing)
	PUSH AF
	CALL IzpisiHex16 ; HL
	LD H,D
	LD L,E
	CALL IzpisiHex16 ; DE
	CALL PrelomVrstice
	POP AF
	CALL IzpisiHex8 ; A
    HALT

MemoryTest:
;	START_ADDR      EQU 2000h
;	END_HI          EQU 0FFh           ; end page high byte
;	END_LO_STOP     EQU 081h           ; stop when L reaches 81h in FFxx page

; ------------ Pass A: write P = H XOR L ------------
            LD      HL, START_ADDR
PA_WRITE:
            LD      A,H
            XOR     L
            XOR     C
            LD      (HL),A

; range-specific increment/terminate (to FF80 inclusive)
            INC     HL
            LD      A,H
            CP      END_HI          ; H < FF ?
            JR      C, PA_WRITE     ; yes -> continue
            ; here H == FF (cannot be > FF)
            LD      A,L
            CP      END_LO_STOP     ; L < 81h ?
            JR      C, PA_WRITE     ; yes -> continue
            ; else L == 81h -> done writing pass A

; ------------ Pass A: verify P ------------
            LD      HL, START_ADDR
PA_VERIFY:
            LD      A,H
            XOR     L               ; expected = P
            XOR     C
            LD      B,A
            LD      A,(HL)          ; actual
            CP      B
            JR      NZ, FAIL_PA

            ; increment with same range-specific stop
            INC     HL
            LD      A,H
            CP      END_HI
            JR      C, PA_VERIFY
            LD      A,L
            CP      END_LO_STOP
            JR      C, PA_VERIFY
            ; done verifying pass A

; ------------ Pass B: write ~P ------------
            LD      HL, START_ADDR
PB_WRITE:
            LD      A,H
            XOR     L
            XOR     C
            CPL                     ; ~P
            LD      (HL),A

            INC     HL
            LD      A,H
            CP      END_HI
            JR      C, PB_WRITE
            LD      A,L
            CP      END_LO_STOP
            JR      C, PB_WRITE
            ; done writing pass B

; ------------ Pass B: verify ~P ------------
            LD      HL, START_ADDR
PB_VERIFY:
            LD      A,H
            XOR     L
            XOR     C
            CPL                     ; expected = ~P
            LD      B,A
            LD      A,(HL)          ; actual
            CP      B
            JR      NZ, FAIL_PB

            INC     HL
            LD      A,H
            CP      END_HI
            JR      C, PB_VERIFY
            LD      A,L
            CP      END_LO_STOP
            JR      C, PB_VERIFY

; ------------ PASS ----------------------
PASS:
            LD      A,'*'
            CALL    GDPUkaz
            RET

; ----------------------------------------
; B = expected, A = actual, HL = failing address
FAIL_PA:
			PUSH    AF
			LD      A,'A'
			CALL    GDPUkaz
			JR      FAIL_report
FAIL_PB:
            PUSH    AF
            LD      A,'B'
            CALL    GDPUkaz
FAIL_report:
			CALL    PrelomVrstice
			POP     AF
			CALL    IzpisiHex8 ; ACTUAL
			CALL    PrelomVrstice
			LD      A,B
			CALL    IzpisiHex8 ; EXPECTED
			CALL    PrelomVrstice
			LD      A,C
			CALL    IzpisiHex8 ; MEMORY BANK
			CALL	IzpisiHex16 ; FAILING ADDRESS
			HALT

Zacetek:
	LD	SP,0xFFC0

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
	LD	(Scroll),A

; (odvecx)
	XOR	A
	OUT	(0x21),A

; Izbira in spust GDP peresa
	LD	A,0x03
	OUT	(0x21),A

	LD	A,0x04	; Pocxistimo GDP sliko...
	CALL	GDPUkaz
	LD	A,0x05	; ... in postavimo pero na levi rob.
	CALL	GDPUkaz

	XOR	A
	OUT	(0x39),A
	OUT	(0x30),A

; Inicializacija AVDC
	CALL	AVDCInit1
	CALL	AVDCInit2

; Inicializacija SIO "CRT" kanala (za tipkovnico)
	LD	C,0xD9
	LD	HL,niz_init_ser
	LD	B,0x07
	OTIR

; Inicializacija SIO "LPT" kanala
	LD	C,0xDB
	LD	HL,niz_init_ser
	LD	B,0x07
	OTIR

; Inicializacija SIO "VAX" kanala
	LD	C,0xE1
	LD	HL,niz_init_ser
	LD	B,0x07
	OTIR

	LD	SP,0xFFC0

; Y koordinata GDP peresa := 100
	LD	A,0x64
	OUT	(0x2B),A

	LD	HL,sporocilo_zagon
	CALL	IzpisiPrelomInNiz

; Spet postavimo pero na levi rob.
	LD	A,0x05
	CALL	GDPUkaz

	LD	HL,sporocilo_boot
	CALL	IzpisiPrelomInNiz

	;CALL DataBusTest

	CALL AddrBusTest

	LD	C,0
	CALL	MemoryTest
	OUT (0x90),A
	LD	C,1
	CALL	MemoryTest
	OUT (0x88),A

	CALL	FDCInit

	IN	A,(0xD9)
	AND	0x01	; Je na voljo znak na tipkovnici?
	JP	Z,HDBootSkok
	CALL	BeriInIzpisiZnak
	CP	0x03	; Je CTL+C?
	JP	NZ,HDBootSkok
	LD	HL,sporocilo_interrupted
	CALL	IzpisiPrelomInNiz

UkaznaVrstica:
	LD	SP,0xFFC0
	CALL	PrelomVrstice
	LD	A,0x2A	; '*'
	CALL	GDPUkaz
	CALL	BeriInIzpisiZnak
	AND	0xDF	; Pretvori v uppercase
	CP	0x41	; 'A'
	JP	Z,HDBootSkok
	CP	0x46	; 'F'
	JP	Z,FDBootSkok
NeznanUkaz:
	LD	A,0x3F	; '?'
	CALL	GDPUkaz
	JR	UkaznaVrstica

; ----------------------------------------

; Sporocxilo o prekinjenem zagonu.
sporocilo_interrupted:
	DB	$21, $00
	DB	"Interrupted"
	DB	$2C
	DB 	" press A or F to load the system !"
	DB 	$00

; ----------------------------------------

; Niz z verzijo programa.
sporocilo_boot:
	DB	$21, $00
	DB	"Oddbit Boot v1.0"
	DB 	$00

; ----------------------------------------

IzpisiPrelomInNiz:
	CALL	PrelomVrstice
; (se nadaljuje v IzpisiNiz)

; ----------------------------------------

; Izpisxe niz na GDP.
; Prvi bajt niza se zapisxe v GDP-jev register za velikost znakov,
; drugi pa v kontrolni register 2. V praksi je drugi bajt vedno 0,
; lahko bi pa bil 4 za lezxecxe besedilo.

; Vhod:
; HL -> niz, zakljucxen z 0

; Unicxi A.

IzpisiNiz:
	CALL	CakajGDP
	LD	A,(HL)
	OUT	(0x23),A
	INC	HL
	LD	A,(HL)
	OUT	(0x22),A
	INC	HL
x0251:
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	GDPUkaz
	INC	HL
	JR	x0251

; ----------------------------------------

Zakasnitev:
	PUSH	BC
	LD	B,0xFF
x025D_2:
	NOP
	DJNZ	x025D_2
	POP	BC
	RET

; ----------------------------------------

AVDCInit1:
	LD	A,0x00
	OUT	(0x39),A
	CALL	Zakasnitev
	CALL	Zakasnitev
	CALL	Zakasnitev
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

	RET

; ----------------------------------------

; Vkljucxi AVDC kurzor in ???
AVDCInit2:
	LD	A,0x3D
	OUT	(0x39),A

; Naslov AVDC kurzorja := 0
	XOR	A
	OUT	(0x3D),A
	OUT	(0x3C),A

	LD	HL,0x1FFF
	CALL	AVDCNastaviDispAddr

; Zapolni AVDC framebuffer s presledki?
	LD	A,0x20
	OUT	(0x34),A
	XOR	A
	OUT	(0x35),A
	LD	A,0xBB	; Write from cursor to pointer
	OUT	(0x39),A

	RET

; ----------------------------------------

; Nastavi AVDC inicializacijska registra 10 in 11
; (display address register lower/upper).

; Vhod:
; HL = novi display address

; Unicxi A.

AVDCNastaviDispAddr:
	LD	A,0x1A
	OUT	(0x39),A
	LD	A,L
	OUT	(0x38),A
	LD	A,H
	OUT	(0x38),A
	RET

; ----------------------------------------



; ----------------------------------------



; ----------------------------------------



; ----------------------------------------

; Sporocxilo o testiranju spomina.
sporocilo_testing_memory:
	DB	$21, $00
	DB	"TESTING MEMORY "
	DB 	$00

; ----------------------------------------

; To je v resnici IVT, ki kazxe tudi na FDC handler na 4CA
ivt:
	DW	FDCIntHandler, CTCIntHandler, NeznanIntHandler

; ----------------------------------------

HDBootSkok:
	JP	HDBoot

; ----------------------------------------

FDBootSkok:
	JP	FDBoot

; ----------------------------------------

FDCInit:
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

; ----------------------------------------
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

; ----------------------------------------
x0345:
	IN	A,(0xF0)
	AND	0xC0
	CP	0xC0
	JP	NZ,x0345
	IN	A,(0xF1)
	RET

; ----------------------------------------
x0351:
	LD	A,0x07
	CALL	x0337
	LD	A,(Neznano1)
	CALL	x0337
	EI
	HALT
	LD	A,0x08
	CALL	x0337
	CALL	x0345
	CALL	x0345
	XOR	A
	LD	(Neznano2),A
	LD	(Neznano6),A
	RET

; ----------------------------------------
x0371:
	CALL	x03ED
	RET	NZ
	LD	A,0x0A
	LD	(Neznano5),A
x037A:
	LD	A,0x05
	OUT	(0xC0),A
	LD	A,0xCF
	OUT	(0xC0),A
	CALL	x045C
	LD	HL,niz_init_fdc
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
	CALL	IzpisiPrelomInNiz
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
	LD	A,(Neznano5)
	OR	A
	JP	Z,x03EB
	DEC	A
	LD	(Neznano5),A
	LD	A,(Neznano2)
	PUSH	AF
	INC	A
	LD	(Neznano2),A
	LD	A,(Neznano6)
	PUSH	AF
	CALL	x03ED
	POP	AF
	LD	(Neznano6),A
	POP	AF
	LD	(Neznano2),A
	CALL	x03ED
	JP	x037A
x03EB:
	INC	A
	RET

; ----------------------------------------
x03ED:
	CALL	x0501
	LD	A,0x0F
	CALL	x0337
	CALL	x041B
	CALL	x0337
	LD	A,(Neznano2)
	CALL	x0337
	EI
	HALT
	LD	A,0x08
	CALL	x0337
	CALL	x0345
	CALL	x0345
	LD	B,A
	LD	A,(Neznano2)
	CP	B
	JP	Z,x0419
	XOR	A
	INC	A
	RET
x0419:
	XOR	A
	RET

; ----------------------------------------
x041B:
	LD	A,(Neznano6)
	RLCA
	RLCA
	AND	0x04
	PUSH	BC
	LD	B,A
	LD	A,(Neznano1)
	OR	B
	POP	BC
	RET

; ----------------------------------------
x042A:
	CALL	x0337
	CALL	x041B
	CALL	x0337
	LD	A,(Neznano2)
	CALL	x0337
	LD	A,(Neznano6)
	CALL	x0337
	LD	A,(Neznano4)
	CALL	x0337
	RET

; ----------------------------------------
x0446:
	LD	A,0x01
	CALL	x0337
	LD	A,(Neznano4)
	CALL	x0337
	LD	A,0x0A
	CALL	x0337
	LD	A,0xFF
	CALL	x0337
	RET

; ----------------------------------------
x045C:
	LD	A,0x79
	OUT	(0xC0),A
	LD	HL,(Neznano3)
	LD	A,L
	OUT	(0xC0),A
	LD	A,H
	OUT	(0xC0),A
	LD	B,0x0B
	LD	C,0xC0
	RET

; ----------------------------------------

; Init string za FDC???
niz_init_fdc:
	DB	$FF, $00, $14, $28, $85, $F1, $8A, $CF
	DB	$01, $CF, $87, $FF, $00, $14, $28, $85
	DB	$F1, $8A, $CF, $05, $CF, $87

; ----------------------------------------

FDNaloziCPMLDR:
	LD	A,0x13
	LD	(Neznano7),A
	XOR	A
	LD	(Neznano1),A
	CALL	x0351
	LD	HL,0xE000
	LD	(Neznano3),HL
x0496:
	XOR	A
	INC	A
	LD	(Neznano4),A
x049B:
	CALL	x0371
	JP	NZ,x06D1
	LD	DE,0x0100 ; NI NASLOV
	LD	HL,(Neznano3)
	ADD	HL,DE
	LD	(Neznano3),HL
	LD	A,(Neznano4)
	INC	A
	LD	(Neznano4),A
	LD	HL,0xFFD8
	CP	(HL)
	JP	NZ,x049B
	LD	A,(Neznano6)
	OR	A
	RET	NZ
	INC	A
	LD	(Neznano6),A
	LD	A,0x0E
	LD	(Neznano7),A
	JP	x0496

; ----------------------------------------

FDCIntHandler:
	EI
	SCF
	RETI

; ----------------------------------------

FDBoot:
	CALL	FDNaloziCPMLDR
	LD	A,(CPMLDR)	; Prvi bajt prvega sektorja...
	CP	0xC3	; ... mora biti opcode za brezpogojni JP...
	JP	Z,x04EA
	CP	0x31	; ... ali LD SP, nn
	JP	Z,x04EA
	LD	HL,sporocilo_no_system_on_disk
	JP	Napaka

; Nalagalnik OSa je nalozxen; skocximo vanj
x04EA:
	JP	Trampolin

; ----------------------------------------
x04ED:
	IN	A,(0x98)
	AND	0x01
	RET

; ----------------------------------------
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

; ----------------------------------------
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

; ----------------------------------------

NeznanIntHandler:
	EI
	SCF
	CCF
	RETI

; ----------------------------------------

; Sporocxilo, da disketni pogon ni pripravljen.
sporocilo_floppy_disk_not_ready:
	DB	$21, $00
	DB	"FLOPPY DISK NOT READY !!!!"
	DB	$00

; ----------------------------------------

HDBoot:
	CALL	HDNaloziCPMLDR
	LD	A,(CPMLDR)	; Prvi bajt prvega sektorja...
	CP	0x31	; ... mora biti opcode za LD SP, nn
	JP	Z,x0557
	LD	HL,sporocilo_no_system_on_disk
	JP	Napaka
x0557:
; Kopiramo ROM na 2000h
	LD	HL,0x0000 ; NI NASLOV
	LD	DE,0x2000
	LD	BC,0x0800 ; NI NASLOV
	LDIR

; Kopiramo interrupt handler(?)
	LD	HL,ivt_2
	LD	DE,0xC000
	LD	BC,0x006C ; NI NASLOV
	LDIR

	DI
	LD	A,0x03
	OUT	(0xC8),A
	OUT	(0xC9),A
	LD	HL,0xC000
	LD	A,H
	LD	I,A
	LD	A,L
	OUT	(0xE8),A
	OUT	(0xC8),A
	LD	A,0x47
	OUT	(0xC8),A
	LD	A,0xFF
	OUT	(0xC8),A
	LD	A,0xC7
	OUT	(0xC9),A
	LD	A,0x64
	OUT	(0xC9),A
	EI

; Nalagalnik OSa je nalozxen; skocximo vanj
	JP	Trampolin

; ----------------------------------------

; Sporocxilo, da trdi disk ni zagonski.
sporocilo_no_system_on_disk:
	DB	$21, $00
	DB	"NO SYSTEM ON DISK"
	DB	$00

; ----------------------------------------

x05AD:
	XOR	A
	OUT	(0x12),A
	DI
	LD	A,0x47
	OUT	(0xC8),A
	LD	A,0xFF
	OUT	(0xC8),A
	LD	A,0xC7
	OUT	(0xC9),A
	LD	A,0x50
	OUT	(0xC9),A
	EI
	CALL	x05FC
x05C5:
	LD	HL,x0755
	CALL	x063D
	CALL	x0662
	JP	NZ,x05C5
	LD	A,0x03
	OUT	(0xC9),A
	RET

; ----------------------------------------

CTCIntHandler:
	LD	A,0x03
	OUT	(0xC9),A
	CALL	IzvediRETI
	EI
	LD	HL,sporocilo_hard_disk_not_ready
	JP	Napaka

; ----------------------------------------

IzvediRETI:
	RETI

; ----------------------------------------

; Sporocxilo, da trdi disk ni pripravljen.
sporocilo_hard_disk_not_ready:
	DB	$21, $00
	DB	"HARD DISK NOT READY"
	DB	$00

; ----------------------------------------
x05FC:
	LD	HL,x0747
	CALL	x0652
	CALL	x0662
	RET	Z
	LD	A,0x34
	JP	x06D7

; ----------------------------------------

HDNaloziCPMLDR:
	CALL	x05AD
	LD	A,0xC3
	OUT	(0xC0),A
	LD	HL,x075B
	CALL	x063D
x0618:
	IN	A,(0x10)
	AND	0x40
	JP	Z,x0618
	IN	A,(0x10)
	AND	0x10
	JP	NZ,x0634
	LD	A,0x22
	OUT	(0x10),A
	CALL	x06A9
x062D:
	IN	A,(0x10)
	AND	0x10
	JP	Z,x062D
x0634:
	CALL	x0662
	RET	Z
	LD	A,0x32
	JP	x06D7

; ----------------------------------------
x063D:
	CALL	x067F
x0640:
	CALL	x069B
	LD	B,A
	AND	0x10
	RET	Z
	LD	A,B
	AND	0x40
	RET	NZ
	LD	A,(HL)
	OUT	(0x11),A
	INC	HL
	JP	x0640

; ----------------------------------------
x0652:
	CALL	x067F
x0655:
	CALL	x069B
	AND	0x40
	RET	NZ
	LD	A,(HL)
	OUT	(0x11),A
	INC	HL
	JP	x0655

; ----------------------------------------
x0662:
	CALL	x069B
	AND	0x10
	JP	NZ,x066F
	LD	A,0x42
	JP	x06D7
x066F:
	IN	A,(0x11)
	LD	B,A
	INC	HL
	CALL	x069B
	IN	A,(0x11)
	XOR	A
	OUT	(0x10),A
	LD	A,B
	AND	0x03
	RET

; ----------------------------------------
x067F:
	IN	A,(0x10)
	AND	0x08
	JP	Z,x068B
	LD	A,0x41
	JP	x06D7
x068B:
	LD	A,0x01
	OUT	(0x10),A
x068F:
	IN	A,(0x10)
	AND	0x08
	JP	Z,x068F
	LD	A,0x02
	OUT	(0x10),A
	RET

; ----------------------------------------
x069B:
	IN	A,(0x10)
	RLA
	JP	NC,x069B
	RRA
	RET

; ----------------------------------------
x06A3:
	LD	HL,niz_init_dma_2
	JP	x06AC

; ----------------------------------------
x06A9:
	LD	HL,niz_init_dma
x06AC:
	LD	C,0xC0
	LD	B,0x0F
	OTIR
	RET

; ----------------------------------------

; ??? init string za DMA
niz_init_dma:
	DB	$79, $00, $E0, $FF, $1E, $14, $28, $95
	DB	$11, $00, $8A, $CF, $01, $CF, $87

; ----------------------------------------

; ??? init string za DMA
niz_init_dma_2:
	DB	$79, $00, $E0, $FF, $1E, $14, $28, $95
	DB	$11, $00, $8A, $CF, $05, $CF, $87

; ----------------------------------------
x06D1:
	LD	HL,sporocilo_floppy_disk_malfunction
	JP	Napaka
x06D7:
	LD	HL,sporocilo_hard_disk_malfunction
Napaka:
	CALL	IzpisiPrelomInNiz
	HALT

; ----------------------------------------

; Sporocxilo, da je nekaj narobe z disketnim pogonom.
sporocilo_floppy_disk_malfunction:
	DB	$21, $00
	DB	"FLOPPY DISK MALFUNCTION !!!RETRY WITH COMMAND  F "
	DB 	$00

; ----------------------------------------

; Sporocxilo, da je nekaj narobe s trdim diskom.
sporocilo_hard_disk_malfunction:
	DB	$21, $00
	DB	"HARD DISK MALFUNCTION >>> RETRY WITH COMMAND  A "
	DB	$00

; ----------------------------------------

; ???
x0747:
	DB	$0C, $00, $00, $00
	DB	$00, $00, $01, $32
	DB	$04, $00, $80, $00
	DB	$40, $0B
x0755:
	DB	$01, $00
	DB	$00, $00, $00, $00
x075B:
	DB	$08, $00, $00, $00
	DB	$1F, $00

; ----------------------------------------

; IVT z 2 vnosoma za ???, ki kazxeta na rutino spodaj, ko je prekopirana.
ivt_2:
	DW	$C004, $C004

; ----------------------------------------

; Rutina za ???, ki se prekopira na C000 skupaj z zgornjim IVT.

	DI
	LD	A,0x03
	OUT	(0xC8),A
	OUT	(0xC9),A
	OUT	(0x88),A
	LD	HL,0x2000
	LD	DE,0x0000 ; NI NASLOV
	LD	BC,0x0800 ; NI NASLOV
	LDIR
	LD	HL,ivt
	LD	A,L
	OUT	(0xE8),A
	OUT	(0xC8),A
	LD	A,H
	LD	I,A
	EI
	CALL	IzvediRETI
	LD	HL,sporocilo_loading_error
	JP	IzpisiPrelomInNiz

; ----------------------------------------

; Sporocxilo o napaki pri nalaganju s trdega diska, ki se nikoli ne izpisxe?
sporocilo_loading_error:
	DB	$11, $00
	DB	"LOADING ERROR FROM HARD DISK TRY TO LOAD SYSTEM FROM FLOPPY "
	DB	$00