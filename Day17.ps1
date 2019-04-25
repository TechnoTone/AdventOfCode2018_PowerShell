
$cellInvalid = ' '
$cellEmpty = '.'
$cellClay = '#'
$cellSpring = '+'
$cellWater = '$'
$cellWaterFalling = '|'
$cellWaterFlat = '~'

$left = -1
$right = 1

$queue = New-Object System.Collections.Queue


function parseCoordinates($lines) {
    foreach ($line in $lines) {
        $values = ($line -split ", ") | % {($_ -split "=")[1]}
        $range = $values[1] -split "\.\."
        @($range[0]..$range[1]) | % {
            if ($line.StartsWith("x")) {
                [PSCustomObject]@{X=$values[0];Y=$_}
            } else {
                [PSCustomObject]@{X=$_;Y=$values[0]}
            }
        }
    }
}

function nLoc($x,$y){
    [PSCustomObject]@{x=$x;y=$y}
}

function parseData($lines) {

    $coords = parseCoordinates $lines
    $xMin = ($coords.X | Measure-Object -Minimum).Minimum
    $xMax = ($coords.X | Measure-Object -Maximum).Maximum
    $yMin = ($coords.Y | Measure-Object -Minimum).Minimum
    $yMax = ($coords.Y | Measure-Object -Maximum).Maximum

    if ($yMin -gt 0) {$yMin = 0}

    $dx = $xMax - $xMin
    $dy = $yMax - $yMin

    $grid = @()

    @(0..$dy) | % {
        $grid = $grid + [string]::new($cellEmpty,$dx+1)
    }

    $data = [PSCustomObject]@{
        grid=$grid
        xMin=$xMin
        xMax=$xMax
        yMin=$yMin
        yMax=$yMax
        width=$dx
        height=$dy
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "getCell" -Value {
        param ($x,$y)
        if ($this.validCell($x,$y)) {
            $x = $x-$this.xmin
            $y = $y-$this.yMin
            $this.grid[$y][$x]
        } else {
            $cellInvalid
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "setCell" -Value {
        param ($x,$y,$value)
        $x = $x-($this.xMin)
        $y = $y-($this.yMin)
        $this.grid[$y] = ($this.grid[$y]).Remove($x,1).Insert($x,$value)
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "displayGrid" -Value {
        $this.grid
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "validCell" -Value {
        param ($x,$y)
        $x -ge $this.xMin -and $x -le $this.xMax -and $y -ge $this.yMin -and $y -le $this.yMax
    } | Add-Member -PassThru -MemberType ScriptProperty -Force -Name "waterCellCount" -Value {
        return ($this.grid | % {$_.ToCharArray() | ? {$_ -in ($cellWaterFalling,$cellWaterFlat)}}).Count
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "flow" -Value {
        param ($x,$y)
        $this.setCell($x, $y, $cellSpring)
        $n = 0
        do {Write-Host (++$n)} until ($this.addWater($x,$y+1))
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "addWater" -Value {
        param ($x,$y)
        $direction = $null
        $queue.Clear()
        do {
            
            $cell = $this.getCell($x,$y)
            if ($cell -eq $cellWaterFalling) {return $true}               # END!

            $cellNext = $this.getCell($x,$y+1)
            if ($cellNext -in ($cellInvalid,$cellWaterFalling)) {         # END!
                $this.setCell($x,$y,$cellWaterFalling)
                if ($queue.Count -eq 0) {
                    return $true
                } else {
                    $q = $queue.Dequeue()
                    $x = $q.x
                    $y = $q.y
                    $direction = $q.direction
                }
            } elseif($cellNext -in ($cellEmpty,$cellWater)) {             # flowing down
                if ($cell -eq $cellEmpty) {$this.setCell($x,$y,$cellWater)}
                $y++
                $direction = $null
            } else {                                                      # on clay or still water

                $cellNext = $this.getCell($x-1,$y) #######
                if ($cellNext -in ($cellEmpty,$cellWater)
                



                if ($direction -eq $null) {
                    $direction = $left
                    $queue.Enqueue([PSCustomObject]@{x = $x;y = $y;direction = $right})
                }

                if ($cell -eq $cellEmpty) {$this.setCell($x,$y,$cellWater)}

                $cellNext = $this.getCell($x+$direction,$y)
                if ($cellNext -in ($cellInvalid,$cellWaterFalling)) {     # END!
                    $this.setCell($x,$y,$cellWaterFalling)
                    if ($queue.Count -eq 0) {
                        return $true
                    } else {
                        $q = $queue.Dequeue()
                        $x = $q.x
                        $y = $q.y
                        $direction = $q.direction
                    }
                } elseif ($cellNext -in ($cellEmpty, $cellWater)) {       # flowing across
                    if ($cell -eq $cellEmpty) {$this.setCell($x,$y,$cellWater)}
                    $x += $direction
                } else {                                                  # clay
                    
                }
            }
        } until (0)
    }
    
    $coords | % { $data.setCell( $_.X, $_.Y, $cellClay ) }
    
    return $data
}


#Example
$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day17.test) )

$data
$data.flow(500,0)
$data.displayGrid()
Write-Host $data.waterCellCount -ForegroundColor Cyan

return



#Part 1

$start = Get-Date

$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day17.data) )

cls
$data
$data.displayGrid()
if ($data.flow(500,0)) {
    $data.displayGrid()
    Write-Host $data.waterCellCount -ForegroundColor Cyan
}

Write-Host ("Part 1 ({1:0.0000})" -f (Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

return


#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


