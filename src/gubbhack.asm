
;============================================================
; BASIC loader 
;============================================================

* = $0801	; BASIC start address ($0801=#2049)
			; puts BASIC line 2012 SYS 49152
		!byte $0d,$08,$dc,$07,$9e,$20,$34,$39
		!byte $31,$35,$32,$00,$00,$00           


* = $c000	; start address for 6502 code
start	
		; Back col 
 		LDX #0: STX $D020	
		LDX #0: STX $D021	
		
		; LDA #LO(mainLoop) 
		
		; Clear screen
		LDA #32
		LDY #0
clearLoop
		STA $0400,y
		STA $0500,y
		STA $0600,y
		STA $0700,y
		DEY
		;CPY #0
		BNE clearLoop
		
		; JMP start
		
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
		STA $0400+40,Y
		
		INX
		INY
		
		CPY #40
		BNE putCharLoop
		
		; Scroll pixel ...
		LDY scrollPixel
		INY
		CPY #6
		BNE noNewScrollChar
		; ... and Scroll char
		LDY #0		

		LDX scrollChar
		INX
		STX scrollChar
		
noNewScrollChar
		STY scrollPixel
		
		JMP mainLoop


		
		
scrollPixel
		!byte 0
scrollChar
		!byte 0
		
scrolltext
		!scr "                                        " 
		!scr "oh my im awesome! yes i am, coz i have m"
		!scr "ade a c64 scroller in asm. basic but it "
		!scr "will improve. hell yeah. elvira is the b" 
		!scr "est, no protest! greetz flyes out to run"
		!scr "e, scoon, gasso, ekart and every other l"
		!scr "amer i know!! :)"
		