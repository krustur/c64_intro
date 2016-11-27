!macro BasicLoader startAddress {
;// BASIC header with a SYS call 
basicLoader
	!word basicLoaderNextLine
	!word 10						;// BASIC line number 
	!byte $9e,$20					;// "SYS <address>"	
	!byte <(((startAddress/10000)%10)+$30)
	!byte <(((startAddress/1000)%10)+$30)
	!byte <(((startAddress/100)%10)+$30)
	!byte <(((startAddress/10)%10)+$30)
	!byte <(((startAddress/1)%10)+$30)
	!byte $00 						;// BASIC eol
basicLoaderNextLine
	!word 0,0						;// BASIC end marker 
}