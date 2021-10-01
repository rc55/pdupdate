#-----------------------
# THIS ISN'T READY YET!
#-----------------------

Add-Type -AssemblyName System.Web

# ----------------------------------------------------------------
# Modify this to point the folder location of your downloaded sets
# ----------------------------------------------------------------
$DownloadRoot = "Z:\MAME + Pleasuredome"

# Create list of MAME folders
$MAMEFolders = @()
$Folders = Get-ChildItem -Path $DownloadRoot -Name
ForEach ($Folder in $Folders) {
    If ($Folder -like "*MAME 0.*") {
        $MAMEFolders += $Folder
    }
}

# Get Topics from Pleasuredome
$pleasuredome = (Invoke-WebRequest –Uri ‘https://pleasuredome.github.io/pleasuredome/mame/’).Links
$topics = @()
Foreach ($href in $pleasuredome) {
    If ($href.href -like "*mgnet.me*" -And $href.innerHTML -like "*MAME 0.*") {
        $topics += $href.innerHTML
    }
}

clear

# Compare Folder Names to Pleasuredome Topics
$updates = @()

ForEach ($MAMEFolder in $MAMEFolders) {
    ForEach ($topic in $topics) {
        # Check if "topic" matches
        If ($MAMEFolder.Substring(11) -eq $topic.Substring(11)) { 
            # Check if version matches
            If ($MAMEFolder -eq $topic) {
                # $MAMEFolder is up to date.
            }
            Else {
                # $MAMEFolder is out of date.
                $newupdate = ([pscustomobject]@{
                    OldFolder=$MAMEFolder
                    NewFolder=$topic
                })
                $updates += $newupdate
            }
        }
    }
}

# Function for getting Magnet URI from mgnet.me URL
Function GetMagnet ($url) {
    $page = (Invoke-WebRequest –Uri $url).Links
    Foreach ($link in $page) {
        If ($link.href -like "*magnet:*") {
            $output = [System.Web.HttpUtility]::HtmlDecode($link.href)
            $output = [System.Web.HttpUtility]::UrlDecode($output)
            Write-Output $output
        }
    }
}


# Fetch Magnet URIs 
ForEach ($update in $updates) {
    Write-Host Updating $update.OldFolder to $update.NewFolder 
    Foreach ($mgnethref in $pleasuredome) {
        If ($mgnethref.href -like "*mgnet.me*" -And $mgnethref.innerHTML -like $update.NewFolder) {
        $magnet = GetMagnet($mgnethref.href)
        # Stop Torrent Client
        Write-Host "Stop-Process -Name ""qbittorrent"""

        # Rename Folder
        $renamecommand =  "Rename-Item ""$($DownloadRoot)\$($update.OldFolder)"" ""$($DownloadRoot)\$($update.NewFolder)"""
        Write-Host $renamecommand

        # Start Torrent Client
        $cli = '& "C:\Program Files\qBittorrent\qbittorrent.exe" --skip-dialog=true --add-paused=false --save-path="'+$DownloadRoot+'" "' + $magnet + '"'
        Write-Host $cli
        }
    }
}




