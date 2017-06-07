<#
        .SYNOPSIS
        No parameters needed.     

        .DESCRIPTION
        This script iterates through the ThinApp sandbox directory and outputs a list of used ThinApps and their last access date.

        Please change the following variables:

        $SearchPath: This should point to the user profile directory.
        Pattern for the sandbox directory: Look for '*client*' in this script). Changing this to your computer name pattern will help to eleminate
        the listing of duplicate ThinApps in the users sandbox directory.
        $Userfolder = Depending on your $SearchPath, you have to change the split-Method to match the username part of the directory name.


        History  
        v0.1: Under development
     
        .EXAMPLE
        Get-ThinAppUsage
    
        .NOTES
        Author: Patrick Terlisten, patrick@blazilla.de, Twitter @PTerlisten
    
        This script is provided 'AS IS' with no warranty expressed or implied. Run at your own risk.

        This work is licensed under a Creative Commons Attribution NonCommercial ShareAlike 4.0
        International License (https://creativecommons.org/licenses/by-nc-sa/4.0/).
    
        .LINK
        http://www.vcloudnine.de
#>

#Requires -Version 3

$SearchPath = 'D:\Test\*\Appdata\Roaming\Thinstall'
$FolderList = Get-Childitem -Path $SearchPath
$ObjectBox = @()

foreach ($Folder in $FolderList) {
  
  $Userfolder = ($Folder.FullName).split("\")[-4]
  $AppFolder = (Get-Childitem -Path $Folder -Directory | Sort-Object | Where-Object {$_ -notlike '*client*' -and $_ -notlike $null})
  
  foreach ($AppSubFolder in $AppFolder) {
  
    $Object = "" | Select-Object User,App, LastAccess
    $Object.User = $Userfolder
    $Object.App = $AppSubFolder
    $Object.LastAccess = $AppSubFolder.LastAccessTime.Date
    $ObjectBox += $Object
 
  }

}

$ObjectBox