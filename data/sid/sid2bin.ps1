#function extractBin{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False)]
        [string]$sidFile='Monty_on_the_Run.sid',
        [Parameter(Mandatory=$False)]
        [string]$binFile='Monty_on_the_Run.bin',
        [Parameter(Mandatory=$False)]
        [string]$asmFile='Monty_on_the_Run.asm'

    )
    Write-Output "Sid file: $sidFile"    
    $sidLen = (Get-Item $sidFile).length
    Write-Output " fileLength: $sidLen"
   
    

    $stream = [System.IO.File]::OpenRead($sidFile)

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

    $ostream = [System.IO.File]::OpenWrite($binFile)
    $ostream.Write($barr,0,$bytesRead);
    $ostream.close();

    echo "wrote $binFile"  


#        * = $AF00 
#musicInit = $AF00
#musicPlay = $C015
#		   !binary "..\data\sid\Dragons_Lair_Part_II.bin"

    '        * = $' | Out-File $asmFile -NoNewline -Encoding utf8
    "{0:X0}" -f $loadAddress | Out-File $asmFile -Append -Encoding utf8
    'musicInit = $' | Out-File $asmFile  -Append -NoNewline -Encoding utf8
    "{0:X0}" -f $initAddress | Out-File $asmFile -Append -Encoding utf8
    'musicPlay = $' | Out-File $asmFile  -Append -NoNewline -Encoding utf8
    "{0:X0}" -f $playAddress | Out-File $asmFile -Append -Encoding utf8
    'musicSongCount = $' | Out-File $asmFile  -Append -NoNewline -Encoding utf8
    "{0:X0}" -f $songs | Out-File $asmFile -Append -Encoding utf8
    'musicStartSong = $' | Out-File $asmFile  -Append -NoNewline -Encoding utf8
    "{0:X0}" -f $startSong | Out-File $asmFile -Append -Encoding utf8
    "          !binary`"..\data\sid\$binFile`"" | Out-File $asmFile -Append -Encoding utf8

    echo "wrote $asmFile" 
#}