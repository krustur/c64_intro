
;============================================================
; BASIC loader 
;============================================================

* = $0801	; BASIC start address ($0801=#2049)
			; puts BASIC line 2012 SYS 49152
		!byte $0d,$08,$dc,$07,$9e,$20,$34,$39
		!byte $31,$35,$32,$00,$00,$00           


* = $c000	; start address for 6502 code

start 		
		; ; Scroll pixel ...
		; LDY scrollPixel
		; INY
		; CPY #8
		; BNE noNewScrollChar
		; ; ... and Scroll char
		; LDY #0		

		; LDX scrollChar
		; INX
		; STX scrollChar
		
; noNewScrollChar
		; STY scrollPixel
		

		
		
		
		LDY #0				; DELETE
		STY scrollChar		; DELETE
mainLoop
		; VBL border col (Idle=black)
 		LDX #0: STX $D020	
		
		; Wait for frame
waitVbl
		lda $d012			
		cmp #$ff
		bne waitVbl
		
		; VBL border col (Work=red)
		LDX #2: STX $D020	
		
		; Put chars
		LDX scrollChar
		LDY #0
putCharLoop
		;INC $D020
		
		LDA scrolltext,X
		STA $0400,Y
		
		INX
		INY
		
		CPX #17
		BNE putCharLoop
		
		LDY scrollChar
		INY
		STY scrollChar
		
		CPY #17
		BNE mainLoop
		
		JMP start

scrollPixel
		!byte 0
scrollChar
		!byte 0
		
scrolltext
		;!scr "                                        " 
		!scr "oh my im awesome!"


		
		; 256 characters
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		;!scr "0123456789012345678901234567890123456789012345678901234567890123"
		