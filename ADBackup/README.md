Active Directory Backup Script

📄 Synopsis

This PowerShell script performs a full backup of core Active Directory (AD) configuration data.

📌 Description

This script automates the export of:

All AD Users

Organizational Units (OUs)

Subnets

Domain Controllers

Trusts

Group Policy Objects (GPOs) including linked OUs and HTML reports

It automatically:

Creates a unique backup folder with the domain name and a timestamp

Saves CSV and HTML reports to the backup folder

Logs all actions to a transcript log for auditing and troubleshooting

✅ Prerequisites

PowerShell with the ActiveDirectory module installed

GroupPolicy module installed

Run with an account that has sufficient permissions to read AD objects and manage GPOs

🚀 How to Run

Open PowerShell as Administrator on a domain-joined server or management workstation.

Copy the script to a .ps1 file, e.g., Backup-ADSettings.ps1.

Execute the script:

.\Backup-ADSettings.ps1

The output will be saved under C:\ADSettingsBackup with subfolders named by DomainName_Date.

📂 Output

The script creates:

AllPSAUsers.csv

xx_OUs.csv

xx_Subnets.csv

xx_DCs.csv

xx_ADTrust.csv

ListGPO.csv

LinkedGPOwithOU.csv

GPOReport.html

BackupLog.txt

GPO backups in the GPOBackUp subfolder

All filenames include the domain name for easy identification.

🛡️ Notes

For large environments, ensure you have enough disk space.

Test backups and restores regularly.

Review permissions if you encounter access errors.

📖 License

This script is provided as-is with no warranty. Use at your own risk.

Contributions welcome! Feel free to fork and submit pull requests on GitHub.

Author: [Mina Hana]Version: 1.0

Enjoy backing up safely! 🔒

