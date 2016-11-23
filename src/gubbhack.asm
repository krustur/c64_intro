
VICII_X_COORDINATE_SPRITE_0		= $D000
VICII_Y_COORDINATE_SPRITE_0		= $D001
VICII_X_COORDINATE_SPRITE_1		= $D002
VICII_Y_COORDINATE_SPRITE_1		= $D003
VICII_X_COORDINATE_SPRITE_2		= $D004
VICII_Y_COORDINATE_SPRITE_2		= $D005
VICII_X_COORDINATE_SPRITE_3		= $D006
VICII_Y_COORDINATE_SPRITE_3		= $D007
VICII_X_COORDINATE_SPRITE_4		= $D008
VICII_Y_COORDINATE_SPRITE_4		= $D009
VICII_X_COORDINATE_SPRITE_5		= $D00A
VICII_Y_COORDINATE_SPRITE_5		= $D00B
VICII_X_COORDINATE_SPRITE_6		= $D00C
VICII_Y_COORDINATE_SPRITE_6		= $D00D
VICII_X_COORDINATE_SPRITE_7		= $D00E
VICII_Y_COORDINATE_SPRITE_7		= $D00F
VICII_MSBS_X_SPRITE				= $D010
VICII_CONTROL_REGISTER_1		= $D011
VICII_RASTER_COUNTER			= $D012
VICII_LIGHT_PEN_X				= $D013
VICII_LIGHT_PEN_Y				= $D014
VICII_SPRITE_ENABLED			= $D015
VICII_CONTROL_REGISTER_2		= $D016
VICII_SPRITE_Y_EXPANSION		= $D017
VICII_MEMORY_POINTERS			= $D018
VICII_INTERRUPT_REGISTER		= $D019
VICII_INTERRUPT_ENABLED			= $D01A
VICII_SPRITE_DATA_PRIORITY		= $D01B
VICII_SPRITE_MULTICOLOR			= $D01C
VICII_SPRITE_X_EXPANSION		= $D01D
VICII_SPRITE_SPRITE_COLLISION	= $D01E
VICII_SPRITE_DATA_COLLISION		= $D01F
VICII_BORDER_COLOR				= $D020
VICII_BACKGROUND_COLOR_0		= $D021
VICII_BACKGROUND_COLOR_1		= $D022
VICII_BACKGROUND_COLOR_2		= $D023
VICII_BACKGROUND_COLOR_3		= $D024
VICII_SPRITE_MULTI_COLOR_0		= $D025
VICII_SPRITE_MULTI_COLOR_1		= $D026
VICII_COLOR_SPRITE_0			= $D027
VICII_COLOR_SPRITE_1			= $D028
VICII_COLOR_SPRITE_2			= $D029
VICII_COLOR_SPRITE_3			= $D02A
VICII_COLOR_SPRITE_4			= $D02B
VICII_COLOR_SPRITE_5			= $D02C
VICII_COLOR_SPRITE_6			= $D02D
VICII_COLOR_SPRITE_7			= $D02E

CIA1_INTERRUPT_CONTROL_STATUS	= $DC0D

CIA2_INTERRUPT_CONTROL_STATUS	= $DD0D
                
;UNKNOWN_0314	= $0314
;UNKNOWN_0315	= $0315
                
;UNKNOWN_EA81	= $EA81


COLOR_BLACK			= $0
COLOR_WHITE			= $1
COLOR_RED			= $2
COLOR_CYAN			= $3
COLOR_PURPLE		= $4
COLOR_GREEN			= $5
COLOR_BLUE			= $6
COLOR_YELLOW		= $7
COLOR_ORANGE		= $8
COLOR_BROWN			= $9
COLOR_LIGHT_RED		= $A
COLOR_DARK_GREY		= $B
COLOR_GREY     		= $C
COLOR_LIGHT_GREEN	= $D
COLOR_LIGHT_BLUE	= $E
COLOR_LIGHT_GREY	= $F

!macro SetBorderColorA color {
	LDA #color
	STA VICII_BORDER_COLOR
}

!macro SetBackgroundColorA color {
	LDA #color
	STA VICII_BACKGROUND_COLOR_0
}

* = $0801	; BASIC start address ($0801=#2049)
			; puts BASIC line 2012 SYS 49152
		!byte $0d,$08,$dc,$07,$9e,$20,$34,$39
		!byte $31,$35,$32,$00,$00,$00           


* = $c000	; start address for 6502 code
start	
		; Back col 
 		+SetBorderColorA COLOR_BLACK
		+SetBackgroundColorA COLOR_BLACK	
		
		; Setup interrupt
		SEI
		
		LDA #$7f
		STA CIA1_INTERRUPT_CONTROL_STATUS
		STA CIA2_INTERRUPT_CONTROL_STATUS
		LDA CIA1_INTERRUPT_CONTROL_STATUS
		LDA CIA2_INTERRUPT_CONTROL_STATUS
		
		LDA #$7f
		AND VICII_CONTROL_REGISTER_1 ; reuses LDA #$7f !
		STA VICII_CONTROL_REGISTER_1
		
		LDY #150
		STY VICII_RASTER_COUNTER
		
		LDA #$35   ;we turn off the BASIC and KERNAL rom here
		STA $01

		LDA #<interrupt
		LDX #>interrupt
		;STA UNKNOWN_0314
		;STX UNKNOWN_0315
		STA $fffe
		STX $ffff
		
		LDA #$01			; enable raster interrupt
		STA	VICII_INTERRUPT_ENABLED
		CLI
		
		; Clear screen
		LDA #32
		LDY #0
clearLoop
		STA $0400,y
		STA $0500,y
		STA $0600,y
		STA $0700,y
		DEY
		BNE clearLoop
		
mainLoop
		; VBL border col (Idle)
 		+SetBorderColorA COLOR_BLACK
		
		; Wait for frame
waitVbl
		lda VICII_RASTER_COUNTER			
		cmp #$ff
		bne waitVbl
		
		; VBL border col (Work)
		+SetBorderColorA COLOR_RED
		
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
		DEY
		CPY #0
		BNE noNewScrollChar
		; ... and Scroll char
		LDY #7		

		LDX scrollChar
		INX
		STX scrollChar
		
noNewScrollChar
		STY scrollPixel
		
		JMP mainLoop

interrupt
		PHA
		TXA
		PHA
		TYA
		PHA
		
		; VBL border col (Work=???)
		+SetBorderColorA COLOR_BROWN
		+SetBackgroundColorA COLOR_BROWN
		
		;LDA #0
		;SBC scrollPixel
		 
		LDA VICII_CONTROL_REGISTER_2
		AND #$F0
		ADC scrollPixel
		STA VICII_CONTROL_REGISTER_2

		
		; VBL border col (Idle=black)
		+SetBorderColorA COLOR_BLACK
		+SetBackgroundColorA COLOR_BLACK
		
		LDA #$ff 
		STA VICII_INTERRUPT_REGISTER
		
		PLA
		TAY
		PLA
		TAX
		PLA
		
		RTI
		;JMP UNKNOWN_EA81
		
		
scrollPixel
		!byte 7
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
					!binary "..\data\sid\ode to 64.bin"