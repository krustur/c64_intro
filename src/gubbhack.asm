
	!src "basicloader.asm"
	!src "vicii.asm"
	!src "cia.asm"
	!src "colors.asm"

                
;UNKNOWN_0314	= $0314
;UNKNOWN_0315	= $0315
                
;UNKNOWN_EA81	= $EA81

!macro WaitRasterA raster {
.waitVbl
		lda VICII_RASTER_COUNTER			
		cmp #raster
		bne .waitVbl
}

* = $0801
	+BasicLoader start

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
		and VICII_CONTROL_REGISTER_1
		sta VICII_CONTROL_REGISTER_1
		
		ldy #220
		sty VICII_RASTER_COUNTER
		
		lda #$35   ;//we turn off the BASIC and KERNAL rom here
		sta $01

		cli	
		
		;// Clear screen
		lda #32
		ldy #0
clearLoop
		lda baseScreen,y
		sta $0400,y
		lda baseScreen+$100,y
		sta $0500,y
		lda baseScreen+$200,y
		sta $0600,y
		lda baseScreen+$300,y
		sta $0700,y
		dey
		bne clearLoop

		;// Clear colors screen
		
		ldy #0
clearColLoop
		lda #3
		sta $D800,y
		lda #4
		sta $D900,y
		lda #4
		sta $DA00,y
		lda #14
		sta $DB00,y
		dey
		bne clearColLoop

mainLoop
		;// VBL border col (Idle)
		;//+WaitRasterA $ff
 		;//+SetBorderColorA COLOR_BLACK
		
		;// Wait for frame
		;//+WaitRasterA $ff
		
		;// VBL border col (Work)
		;//+SetBorderColorA COLOR_RED			
		
		;//+SetBorderColorA COLOR_BLUE
		jsr scrollChars

		+WaitRasterA $57
		;//+SetBorderColorA COLOR_YELLOW
		jsr scrollPixels	


		ldy #$62	;// Raster start
		jsr rasterBars			
		;//+SetBorderColorA COLOR_RED		

		jsr noScrollPixels
		jsr musicPlay
		
		jmp mainLoop

colors
		;//!byte $06,$06,$0e,$06
		;//!byte $0e,$0e,$03,$0e
		;//!byte $03,$03,$01,$03
		;//!byte $01,$01       
		;//!byte $03,$01,$03,$03
		;//!byte $0e,$03,$0e,$0e
		;//!byte $06,$0e,$06,$06

		;//byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

		!byte $06,$06,$06,$0e,$06,$0e
        !byte $0e,$06,$0e,$0e,$0e,$03
        !byte $0e,$03,$03,$0e,$03,$03
        !byte $03,$01,$03,$01,$01,$03
        !byte $01,$01,$01,$03,$01,$01
        !byte $03,$01,$03,$03,$03,$0e
        !byte $03,$03,$0e,$03,$0e,$0e
        !byte $0e,$06,$0e,$0e,$06,$0e
        !byte $06,$06,$06
colorsEnd
		!byte $00

scrollChars
		

		;// Put chars
		ldx scrollChar	
		ldy #0
putCharLoop 
		lda scrolltext,X
		sta $0400+320,Y
		
		inx
		iny
		
		cpy #39
		bne putCharLoop
		
		;// Scroll pixel ...
		ldy scrollPixel
		dey
		cpy #0
		bne noNewScrollChar
		;// ... and Scroll char
		ldy #8	

		ldx scrollChar
		inx
		stx scrollChar
		
noNewScrollChar
		sty scrollPixel
		rts

scrollPixels
		
		lda VICII_CONTROL_REGISTER_2
		and #$F0
		clc
		adc scrollPixel
		and #$F7
		sta VICII_CONTROL_REGISTER_2
		rts

noScrollPixels
		lda VICII_CONTROL_REGISTER_2
		and #$F0
		clc
		adc #$08
		sta VICII_CONTROL_REGISTER_2
		rts

rasterBars
		;// y = raster start
						
		ldx #$00
rastloop
		lda colors,x                      

		cpy VICII_RASTER_COUNTER
		bne *-3

		sta VICII_BORDER_COLOR
		sta VICII_BACKGROUND_COLOR_0

		cpx #(colorsEnd-colors)
		beq rastdone

		inx 
		iny

		jmp rastloop
rastdone
		rts

scrollPixel
		!byte 7
scrollChar
		!byte 0
		
scrolltext
		!scr "                                        " 
		!scr "dear sirs! you have been invited to the "
		!scr "official gubbhack 2017! this time locate"
		!scr "d at the magnificent -=[ hiq ]=- venue i" 
		!scr "n oerebro. greetz flyes out to rune, sco"
		!scr "on, gasso, ekart and every other lamer i"
		!scr " know!! :)      "
baseScreen
		!scr " |||    |  ||   ||     |  ||   |||    | "
		!scr "|    |  | |  | |  | |  | |  | |    | |  "
		!scr "| || |  | |||  |||  |||| |||| |    ||   "
		!scr "|  | |  | |  | |  | |  | |  | |    | |  "
		!scr "|||  |||  |||  |||  | |  | |  |||  | |  "		
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "           .... when  02/29-31/2017 ... "
		!scr "         ..... where  hiq oerebro? ..   "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "                                        "
		!scr "  ... code  krustur ..                  "
		!scr "    .. gfx  krustur ....                "
		!scr " ... music  queu? ...                   "
;//sinTable
;//		!binary "..\data\sinus.bin"


realstartSong = 1
		!src "..\data\sid.asm"
