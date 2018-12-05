﻿param(
    [Parameter(Mandatory, Position=0)]
    [ValidateRange(1,25)]
    [int]$Day
)

$scriptFolder = $PSCommandPath | Split-Path -Parent
$scriptName = "Day{0:00}.ps1" -f $Day
$dataFileName = "Day{0:00}.data" -f $Day

if (ls $scriptFolder -Filter $scriptName) {
    Write-Host "File for day $Day already exists." -ForegroundColor Red
} else {

    Set-Content -Path (Join-Path $scriptFolder $scriptName) -Value "

`$start = Get-Date

`$data = cat (Join-Path (Join-Path (`$PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) $dataFileName)



#Part 1

Write-Host (`"Part 1 = {0} ({1})`" -f `"answer`",(Get-Date).Subtract(`$start).TotalSeconds) -ForegroundColor Cyan



#Part 2

Write-Host (`"Part 2 = {0} ({1})`" -f `"answer`",(Get-Date).Subtract(`$start).TotalSeconds) -ForegroundColor Cyan

"

    if ($Host.Name -match "ISE") {
        psEdit (Join-Path $scriptFolder $scriptName)
    } 
}
