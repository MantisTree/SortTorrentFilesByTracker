<#
Torrent Tracker Sorter.ps1
Copyright (C) 2020  MantisTree

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See <http://www.gnu.org/licenses/> to read the GNU General Public License.
#>

$allfiles = gci  "*.torrent"

$ToNatural= { [regex]::Replace($_, '\d+',{$args[0].Value.Padleft(20)})} # Define natural sort method

$allfiles  = $allfiles | Sort-Object $ToNatural

Foreach($ThisFileObject in $allfiles){

    $TrackerName = "(DHT)"

    $ThisFilePath = $ThisFileObject.FullName
    $ThisFileName = $ThisFileObject.Name

    Write-Host "Working $ThisFileName" -ForegroundColor Blue

    $ThisFilePath = $ThisFilePath.Replace("[","``[").Replace("]","``]")

    $FileContents = Get-Content $ThisFilePath -raw
    
    $searchstring = "d8:announce"

    $target = ($FileContents | Where-Object {$_.Contains($searchstring)})

    If($target){
        $trackerindex = $target.indexof($searchstring)+$searchstring.Length

        $trackerlen = $target.Substring($trackerindex,4).split(":")[0]

        $indexofcolon = $target.Substring($trackerindex,4).indexof(":")

        $trackerStart = $trackerindex + $indexofcolon +1

        $tracker = $target.Substring($trackerStart,$trackerlen)

        $Escapedtracker = $tracker.Replace("""","'")

        $TrackerName = $Escapedtracker.split("/")[2].split(":")[0]
    
        $TrackerPartCount = $TrackerName.split(".").count
    
        If($TrackerPartCount -gt 2){$TrackerName = ($TrackerName.split(".") | select -Last ($TrackerPartCount -1)) -join(".")}
    }

    Write-host "$($ThisFileName)'s tracker is '" -NoNewline
    Write-Host "$TrackerName" -NoNewline -ForegroundColor Yellow
    Write-Host "'"

    if(test-path $Trackername){
        mv $ThisFilePath $TrackerName
    }
    else
    {
        mkdir $TrackerName | Out-Null
        mv $ThisFilePath $TrackerName
    }

}
