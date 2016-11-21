@echo off
REM "E:\Emulation\WinVICE-2.4-x64\petcat.exe" -w2 basicheader.bas >basicheader.obj
java -jar E:\Dev\KickAssembler\KickAss.jar -vicesymbols src\gubbhack.asm 
"E:\Emulation\WinVICE-2.4-x64\c1541.exe" -format GUBBHACK,1 d64 gubbhack.d64 -attach gubbhack.d64 -write gubbhack.prg gubbhack