#function extractBin{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [string]$binFile
        

    )
    
    $path = Split-Path -parent $PSCommandPath
    Write-Output "PSCommandpath: $path"
    $binFile = Join-Path $path $binFile
    $barr = New-Object byte[] 256
    

    $ostream = [System.IO.File]::OpenWrite("$binFile")

    [double]$pi = [System.Math]::PI
    Write-Output "PI: $pi"

    for ($i=0;$i -lt 256;$i++) {
        $barr[$i] = $i;
        $now = ($i * $pi * 2) / 256
        # Write-Output $now
        $val = 127.5 + ([System.Math]::Sin($now) * 127.5)
        $valb = [byte]$val
        #Write-Output $valb
        $barr[$i] = $valb
        Write-Output $barr[$i]
    }
    $ostream.Write($barr,0,256);
    $ostream.close();

    Write-Output "wrote $binFile"  


#}