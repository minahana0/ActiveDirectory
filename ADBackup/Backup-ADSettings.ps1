<#
.SYNOPSIS
This script performs a full backup of core Active Directory settings.

.DESCRIPTION
This PowerShell script collects and exports data for all AD users, Organizational Units (OUs), subnets, domain controllers, trusts, and Group Policy Objects (GPOs). It creates backup folders that include the domain name and a timestamp, logs actions to a transcript, and saves CSV and HTML reports for later restoration or documentation purposes.
#>

# ===============================
# Active Directory Backup Script with Domain in Folder Name and Filenames
# ===============================

$DateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$DomainName = (Get-ADDomain).DNSRoot -replace "\\.", "_"
$RootBackupFolder = "C:\\${DomainName}_ADBackup\$DateStamp"
$GPOBackUp = "$RootBackupFolder\\${DomainName}_GPOBackUp"

If (!(Test-Path -Path $RootBackupFolder)) { New-Item -Path $RootBackupFolder -ItemType Directory -Verbose }
If (!(Test-Path -Path $GPOBackUp)) { New-Item -Path $GPOBackUp -ItemType Directory -Verbose }

$LogFile = "$RootBackupFolder\\BackupLog.txt"
Start-Transcript -Path $LogFile

Try {
    Get-ADUser -Filter * -Properties * | Export-Csv -Path "$RootBackupFolder\\${DomainName}_AllPSAUsers.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export users: $_" }

Try {
    Get-ADOrganizationalUnit -Properties CanonicalName -Filter * |
        Select-Object CanonicalName, DistinguishedName |
        Sort-Object CanonicalName |
        Export-Csv -Path "$RootBackupFolder\\${DomainName}_OUs.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export OUs: $_" }

Try {
    Get-ADReplicationSubnet -Filter * |
        Select-Object Name, Site |
        Export-CSV -Path "$RootBackupFolder\\${DomainName}_Subnets.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export subnets: $_" }

Try {
    $DcList = (Get-ADForest).Domains | ForEach { Get-ADDomainController -Discover -DomainName $_ } | ForEach { Get-ADDomainController -Server $_.Name -Filter * } | Select Site, Name, Domain
    $DcList | Export-Csv -Path "$RootBackupFolder\\${DomainName}_DCs.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export DCs: $_" }

Try {
    Get-ADTrust -Filter * | Export-Csv -Path "$RootBackupFolder\\${DomainName}_ADTrust.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export Trusts: $_" }

If (!(Get-Module -ListAvailable -Name GroupPolicy)) {
    Write-Error "The GroupPolicy module is not installed!"
    Stop-Transcript
    Exit
} Else { Import-Module GroupPolicy }

Try {
    Backup-GPO -All -Path $GPOBackUp -ErrorAction Stop
} Catch { Write-Error "Failed to backup GPOs: $_" }

Try {
    Get-GPO -All | Select-Object DisplayName, Id, GpoId | Export-Csv -Path "$RootBackupFolder\\${DomainName}_ListGPO.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export GPO list: $_" }

Try {
    (Get-ADOrganizationalUnit -Filter * | Get-GPInheritance).GpoLinks | Export-Csv -Path "$RootBackupFolder\\${DomainName}_LinkedGPOwithOU.csv" -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} Catch { Write-Error "Failed to export Linked GPOs: $_" }

Try {
    Get-GPOReport -All -ReportType Html -Path "$RootBackupFolder\\${DomainName}_GPOReport.html" -ErrorAction Stop
} Catch { Write-Error "Failed to export GPO report: $_" }

Stop-Transcript
Write-Host "Backup completed to $RootBackupFolder"
