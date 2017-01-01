#function extractBin{
    [CmdletBinding()]
    param(
        #[Parameter(Mandatory=$True)]
        #[string]$path,        
        [Parameter(Mandatory=$True)]
        [string]$sidFile,
        [Parameter(Mandatory=$True)]
        [string]$binFile,
        [Parameter(Mandatory=$True)]
        [string]$asmFile

    )
    Write-Output "Sid file: $sidFile"    
    $sidLen = (Get-Item "$sidFile").length
    Write-Output " fileLength: $sidLen"
   
    

    $stream = [System.IO.File]::OpenRead("$sidFile")

    $barr = New-Object byte[] $sidLen
    $bytesRead = $stream.Read($barr,0,76) # read first 76

    $dataOffset = ($barr[0x6]*256)+$barr[0x7]
    $loadAddress = ($barr[0x8]*256)+$barr[0x9]
    $initAddress = ($barr[0xa]*256)+$barr[0xb]
    $playAddress = ($barr[0xc]*256)+$barr[0xd]
    $songs = ($barr[0xe]*256)+$barr[0xf]
    $startSong = ($barr[0x10]*256)+$barr[0x11]


    $bytesRead = $stream.Read($barr, 0, $dataOffset-76) # skip dataOffset - 76, to get to the actual data
    $bytesRead = $stream.Read($barr, 0, 2) # ??
    $loadAddress2 = ($barr[0x1]*256)+$barr[0x0]
    if ($loadAddress -eq 0) {
        $loadAddress = $loadAddress2
    }
    Write-Output (" dataOffset: {0:X0}" -f $dataOffset)
    Write-Output (" loadAddress: {0:X0}" -f $loadAddress)
    Write-Output (" loadAddress2: {0:X0}" -f $loadAddress2)
    Write-Output (" initAddress: {0:X0}" -f $initAddress)
    Write-Output (" playAddress: {0:X0}" -f $playAddress)
    Write-Output (" songs: {0:X0}" -f $songs)
    Write-Output (" startSong: {0:X0}" -f $startSong)
    
    $bytesRead = $stream.Read($barr, 0, $sidLen-$dataOffset) # read actual data
    $stream.Close();

    $ostream = [System.IO.File]::OpenWrite("$binFile")
    $ostream.Write($barr,0,$bytesRead);
    $ostream.close();

    Write-Output "wrote $binFile"  


#        * = $AF00 
#musicInit = $AF00
#musicPlay = $C015
#		   !binary "..\data\sid\Dragons_Lair_Part_II.bin"
    #$incBin = '.import binary'
    #$const = '.const '
    $incBin = '!binary'
    $const = ''
    $enc = 'ascii'

    ("        * = $`{0:X0}") -f $loadAddress | Out-File "$asmFile" -Encoding utf8
    ("${const}musicInit = `${0:X0}" -f $initAddress) | Out-File "$asmFile" -Encoding utf8 -Append
    ("${const}musicPlay = `${0:X0}" -f $playAddress) | Out-File "$asmFile" -Encoding utf8 -Append
    ("${const}musicSongCount = `${0:X0}" -f $songs) | Out-File "$asmFile"  -Encoding utf8 -Append
    ("${const}musicStartSong = `${0:X0}" -f $startSong) | Out-File "$asmFile"  -Encoding utf8 -Append
    "$incBin `"$binFile`"" | Out-File "$asmFile" -Encoding utf8 -Append 

    Write-Output "wrote $asmFile"
#}

#$sidName = 'Ikari_Intro'
#extractBin -path 'F:\Google Drive\Projects\C64\c64_intro\data\sid' -sidFile "$sidName.sid" -binFile "$sidName.bin" -asmFile "$sidName.asm"