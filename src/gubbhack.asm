
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
	lda #color
	sta VICII_BORDER_COLOR
}

!macro SetBackgroundColorA color {
	lda #color
	sta VICII_BACKGROUND_COLOR_0
}

;// BASIC header with a SYS call 
* = $0801
basicLoader
	!word basicLoaderNextLine
	!word 10						;// BASIC line number 
	!byte $9e,$20					;// "SYS <address>"	
	!byte <(((start/10000)%10)+$30)
	!byte <(((start/1000)%10)+$30)
	!byte <(((start/100)%10)+$30)
	!byte <(((start/10)%10)+$30)
	!byte <(((start/1)%10)+$30)
	!byte $00 						;// BASIC eol
basicLoaderNextLine
	!word 0,0						;// BASIC end marker 




;//* = $c000	;// start address for 6502 code
start	
		;// Back col 
 		+SetBorderColorA COLOR_BLACK
		+SetBackgroundColorA COLOR_BLACK	
		
		;// Init music
		lda #realstartSong
		jsr musicInit
				
		;// Setup interrupt
		sei
		
		lda #$7f
		sta CIA1_INTERRUPT_CONTROL_STATUS
		sta CIA2_INTERRUPT_CONTROL_STATUS
		lda CIA1_INTERRUPT_CONTROL_STATUS
		lda CIA2_INTERRUPT_CONTROL_STATUS
		
		lda #$7f
		and VICII_CONTROL_REGISTER_1 ;// reuses lda #$7f !
		sta VICII_CONTROL_REGISTER_1
		
		ldy #150
		sty VICII_RASTER_COUNTER
		
		lda #$35   ;//we turn off the BASIC and KERNAL rom here
		sta $01

		lda #<interrupt
		ldx #>interrupt
		;//sta UNKNOWN_0314
		;//stx UNKNOWN_0315
		sta $fffe
		stx $ffff
		
		lda #$01			;// enable raster interrupt
		sta	VICII_INTERRUPT_ENABLED
		cli
		
		;// Clear screen
		lda #32
		ldy #0
clearLoop
		sta $0400,y
		sta $0500,y
		sta $0600,y
		sta $0700,y
		dey
		bne clearLoop
		
mainLoop
		;// VBL border col (Idle)
 		+SetBorderColorA COLOR_BLACK
		
		;// Wait for frame
waitVbl
		lda VICII_RASTER_COUNTER			
		cmp #$ff
		bne waitVbl
		
		;// VBL border col (Work)
		+SetBorderColorA COLOR_RED
		
		;// Put chars
		ldx scrollChar	
		ldy #0
putCharLoop
		;//inc $D020
		
		lda scrolltext,X
		sta $0400+40,Y
		
		inx
		iny
		
		cpy #40
		bne putCharLoop
		
		;// Scroll pixel ...
		ldy scrollPixel
		dey
		cpy #0
		bne noNewScrollChar
		;// ... and Scroll char
		ldy #7		

		ldx scrollChar
		inx
		stx scrollChar
		
noNewScrollChar
		sty scrollPixel
		
		jmp mainLoop

interrupt
		pha
		txa
		pha
		tya
		pha
		
		;// VBL border col (Work=???)
		+SetBorderColorA COLOR_BROWN
		+SetBackgroundColorA COLOR_BROWN
		
		;//lda #0
		;//sbc scrollPixel
		 
		lda VICII_CONTROL_REGISTER_2
		and #$F0
		adc scrollPixel
		sta VICII_CONTROL_REGISTER_2
		
		jsr musicPlay
		
		;// VBL border col (Idle=black)
		+SetBorderColorA COLOR_BLACK
		+SetBackgroundColorA COLOR_BLACK
		
		lda #$ff 
		sta VICII_INTERRUPT_REGISTER
		
		pla
		tay
		pla
		tax
		pla
		
		rti
		;//jmp UNKNOWN_EA81
		
		
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

		;//Working
realstartSong = 2
		!src "..\data\sid\Ghosts_n_Goblins.asm"
		;//!src "..\data\sid\Ode_to_C64.asm"
		;//!src "..\data\sid\Last_Ninja_2.asm"
		;//!src "..\data\sid\Last_Ninja_2_real.asm"
		;//!src "..\data\sid\Commando.asm"
		;//!src "..\data\sid\Monty_on_the_Run.asm"
		
		
		;//Not working
		;// !src "..\data\sid\Ghostbusters.asm"
		;// !src "..\data\sid\Last_Ninja_4_loader.asm"
		