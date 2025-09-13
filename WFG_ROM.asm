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

; Inicializacija SIO "CRT" kanala (za tipkovnico)
;	LD	C,0xD9
;	LD	HL,niz_init_ser
;	LD	B,0x07
;	OTIR

; Inicializacija SIO "LPT" kanala
;	LD	C,0xDB
;	LD	HL,niz_init_ser
;	LD	B,0x07
;	OTIR

; Inicializacija SIO "VAX" kanala
;	LD	C,0xE1
;	LD	HL,niz_init_ser
;	LD	B,0x07
;	OTIR

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

;	LD HL,IzpisiHex16_ret
;	LD BC,B00Bh
;	JP IzpisiHex16_2
;IzpisiHex16_ret:

	LD HL,DataBusTest_ret
	JP DataBusTest
DataBusTest_ret:

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
	LD	A,'*'
	LD HL,GDPUkaz_ret_3
	JP	GDPUkaz2
GDPUkaz_ret_3:
	EXX
	JP (HL)

DBUS_FAIL:
	; After CP E, A = expected, E = actual
	LD D,A
	EXX
	LD HL,Prelom_ret_3
	JP PrelomVrstice2
Prelom_ret_3:
	; expected
	EXX
	LD A,D
	LD HL,Izpis_hex_1
	JP IzpisiHex8_2
Izpis_hex_1:
	; actual
	EXX
	LD HL,Prelom_ret_5
	JP PrelomVrstice2
Prelom_ret_5:
	EXX
	LD HL,Izpis_hex_2
	LD A,E
	JP IzpisiHex8_2
Izpis_hex_2:
	HALT

; ----------------------------------------

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
    ;LD      A,'*'
    ;CALL    GDPUkaz
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
	;PUSH AF
	;CALL IzpisiHex16 ; HL
	;LD H,D
	;LD L,E
	;CALL IzpisiHex16 ; DE
	;CALL PrelomVrstice
	;POP AF
	;CALL IzpisiHex8 ; A
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
            ;LD      A,'*'
            ;CALL    GDPUkaz
            RET

; ----------------------------------------
; B = expected, A = actual, HL = failing address
FAIL_PA:
			;PUSH    AF
			;LD      A,'A'
			;CALL    GDPUkaz
			;JR      FAIL_report
FAIL_PB:
            ;PUSH    AF
            ;LD      A,'B'
            ;CALL    GDPUkaz
FAIL_report:
			;CALL    PrelomVrstice
			;POP     AF
			;CALL    IzpisiHex8 ; ACTUAL
			;CALL    PrelomVrstice
			;LD      A,B
			;CALL    IzpisiHex8 ; EXPECTED
			;CALL    PrelomVrstice
			;LD      A,C
			;CALL    IzpisiHex8 ; MEMORY BANK
			;CALL	IzpisiHex16 ; FAILING ADDRESS
			HALT

; ----------------------------------------

; Sporocxilo o testiranju spomina.
sporocilo_testing_memory:
	DB	$21, $00
	DB	"TESTING MEMORY "
	DB 	$00

; ----------------------------------------

sporocilo_initializing:
	DB	$21, $00
	DB	"INITIALIZING "
	DB 	$00

sporocilo_done:
	DB	$21, $00
	DB	"DONE"
	DB 	$00