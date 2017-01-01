# Sid
$scriptPath = Split-Path -parent $PSCommandPath
$args = @()
$args += ("-sidFile", "'$scriptPath\sid\Ikari_Intro.sid'")
$args += ("-binFile", "'$scriptPath\data\sid.bin'")
$args += ("-asmFile", "'$scriptPath\data\sid.asm'")
$ps1 = "$scriptPath\src\sid2bin.ps1"
Invoke-Expression "& '$ps1' $args"

# Assemble to gubbhack.prg
Push-Location '.\src'
&"..\bin\ACME\ACME.exe" -f cbm --cpu 6502 --vicelabels ..\output\gubbhack.vl -o ..\output\gubbhack.prg gubbhack.asm 
Pop-Location

# Format d64-file with gubbhack.prg
&"E:\Emulation\WinVICE-2.4-x64\c1541.exe" -format GUBBHACK,1 d64 output\gubbhack.d64 -attach output\gubbhack.d64 -write output\gubbhack.prg gubbhack
