
	!src "basicloader.asm"
	!src "vicii.asm"
	!src "cia.asm"
	!src "colors.asm"

                
;UNKNOWN_0314	= $0314
;UNKNOWN_0315	= $0315
                
;UNKNOWN_EA81	= $EA81

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
		
		jsr scroller
		
		jmp mainLoop


scroller

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
		rts
		
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
sinTable
		!binary "..\data\sinus.bin"

		;//Working
realstartSong = 2
		;//!src "..\data\sid\Ghosts_n_Goblins.asm"
		!src "..\data\sid\Ikari_Intro.asm"
		;//!src "..\data\sid\Accept_or_Die.asm"
		;//!src "..\data\sid\Iceman_01.asm"
		;//!src "..\data\sid\Ode_to_C64.asm"
		;//!src "..\data\sid\Last_Ninja_2.asm"
		;//!src "..\data\sid\Last_Ninja_2_real.asm"
		;//!src "..\data\sid\Commando.asm"
		;//!src "..\data\sid\Monty_on_the_Run.asm"
		
		
		;//Not working
		;// !src "..\data\sid\Ghostbusters.asm"
		;// !src "..\data\sid\Last_Ninja_4_loader.asm"
		