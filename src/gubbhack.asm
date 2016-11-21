
;!cpu 6502
;!to "output/gubbhack.prg",cbm

;============================================================
; BASIC loader 
;============================================================

* = $0801	; BASIC start address ($0801=#2049)
			; puts BASIC line 2012 SYS 49152
		!byte $0d,$08,$dc,$07,$9e,$20,$34,$39
		!byte $31,$35,$32,$00,$00,$00           


* = $c000	; start address for 6502 code

start 	
		
		LDY #0
		STY scrollpos
loop1
 		LDX #0: STX $D020
		
		lda $d012		; Wait for frame
		cmp #$ff
		bne loop1
			
		LDX #2: STX $D020
		
		LDX scrollpos
		LDY #0
loop2
		;INC $D020
		
		LDA scrolltext,X
		STA $0400,Y
		
		INX
		INY
		
		CPX #17
		BNE loop2
		
		LDY scrollpos
		INY
		STY scrollpos
		
		CPY #17
		BNE loop1
		
		JMP start

		
scrolltext
		!scr "oh my im awesome!"

scrollpos
		!byte 0
		
		; 256 characters
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		