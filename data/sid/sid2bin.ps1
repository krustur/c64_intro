#function extractBin{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False)]
        [string]$sidFile='Ghosts_n_Goblins.sid',
        [Parameter(Mandatory=$False)]
        [string]$binFile='Ghosts_n_Goblins.bin'
    )
    Write-Output "Sid file: $sidFile"    
    $sidLen = (Get-Item $sidFile).length
    Write-Output "Sid file length: $sidLen"
   
    

    $stream = [System.IO.File]::OpenRead($sidFile)

    $barr = New-Object byte[] $sidLen
    $bytesRead = $stream.Read($barr,0,8) # read first 8, including dataOffest at 6
    $dataOffset = ($barr[6]*256)+$barr[7]
    Write-Output ("Sid data offset: {0:X0}" -f $dataOffset)

    $bytesRead = $stream.Read($barr, 0, $dataOffset-8+2) # skip dataOffset - 8, to get to the actual data
    $bytesRead = $stream.Read($barr, 0, $sidLen-$dataOffset) # read actual data
    
    $ostream = [System.IO.File]::OpenWrite($binFile)
    $ostream.Write($barr,0,$bytesRead);
    $ostream.close();

    echo "wrote $binFile"  
#}