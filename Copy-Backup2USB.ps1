<#
        .SYNOPSIS
        Dieses Skript kopiert Ordner mit Hilfe von Robocopy.

        .DESCRIPTION
        Dieses Skript kopiert Daten mit Hilfe von Robocopy und versendet am Ende ein Log per Mail.

        History  
        v1.0: Initial Release
     
        .EXAMPLE
        Copy-Backup2USB.ps1 -BackupSource C:\TEMP -BackupDestination E:\TEMP -ReportAddress patrick@blazilla.de
    
        .NOTES
        Author: Patrick Terlisten, patrick@blazilla.de, Twitter @PTerlisten
    
        This script is provided 'AS IS' with no warranty expressed or implied. Run at your own risk.

        This work is licensed under a Creative Commons Attribution NonCommercial ShareAlike 4.0
        International License (https://creativecommons.org/licenses/by-nc-sa/4.0/).

        .LINK
        https://www.vcloudnine.de
#>

#Requires -Version 3

# Parameter bindings

[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true, 
        Position = 0,
        HelpMessage = 'Input file with files/ folders to copy',
        ValueFromPipeline = $false)]
    [ValidateNotNullorEmpty()]
    [Alias("Source")]
    [string]$BackupSource,
    
    [Parameter(Mandatory = $true,
        Position = 1,
        HelpMessage = 'Backup destination',
        ValueFromPipeline = $false)]
    [ValidateNotNullorEmpty()]
    [Alias("Destination")]
    [string]$BackupDestination,
    
    [Parameter(Mandatory = $true,
        Position = 2,
        HelpMessage = 'Receipient for backup report',
        ValueFromPipeline = $false)]
    [Alias("Report")]
    [string]$ReportAddress
)

# Variables

$LogfileDate = Get-Date -Format "yyyyMMdd"
$RoboCopyLog = "C:\TEMP\$LogfileDate-Robocopy.txt"
$MailFrom = "Copy2USB Script <noreply@domain.local>" 
$Mailserver = "mailrelay.domain.local"

# Preparing Mailobject
$MailObject = new-object Net.Mail.MailMessage

# Copy files

ROBOCOPY $BackupSource $BackupDestination /MIR /NODCOPY /NOOFFLOAD /XO /R:0 /W:0 /NP | Out-File $RoboCopyLog

if ($LastExitCode -eq 0 -or $LastExitCode -eq 1) {

    $MailBody = "Das Backup war erfolgreich. Im Anhang befindet sich das Logfile." 
    $MailObject.Subject = "Copy to USB war erfolgreich!"
}

elseif ($LastExitCode -eq 16) {

    $MailBody = "Das Backup NICHT erfolgreich und ist total in die Hose gegangen. Im Anhang befindet sich das Logfile. Bitte das Backup fixen!" 
    $MailObject.Subject = "Copy to USB NICHT erfolgreich! BITTE LOGFILE CHECKEN!"

}

else {

    $MailBody = "Das Backup weitestgehend erfolgreich. Im Anhang befindet sich das Logfile. Bitte das Logfile prüfen." 
    $MailObject.Subject = "Copy to USB weitestgehend erfolgreich! BITTE LOGFILE CHECKEN!"
}

# Creating email

$MailObject.From = $MailFrom
$MailObject.To.Add($ReportAddress)
$MailObject.Body = $MailBody
$MailAttachment = New-Object Net.Mail.Attachment($RoboCopyLog);
$MailObject.Attachments.Add($MailAttachment);

# Sending email

$SMTPConnection = new-object Net.Mail.SmtpClient("$Mailserver", "25");
$SMTPConnection.EnableSSL = $true;
$SMTPConnection.send($MailObject);
$MailAttachment.Dispose();