# MYSQL Backup with PowerShell

## Prerequisites

- At least PowerShell 5.0
- The latest VC Runtime Version
  - https://www.microsoft.com/en-us/download/details.aspx?id=52685

## Configuration

In the `db.cnf` file define your `hostname`, `user` and `password`.

In the `mysql_backup.ps1` script, change the following variables, correspondingly to your environment:

- \$basepath
- \$backuppath
- \$database
- \$smtpserver
- \$username_mail
- \$password_mail
- \$sender_mail
- \$recipient_mail

## Deployment

Copy the repository to your Windows Client/Server where you would like to run the Backup.

To run the backup on a daily base, e.g. a scheduled task would be fitting.  
Here is an example on how to add a Scheduled Task with Powershell:

```powershell
$path_to_script = '"C:\temp\mysql_backup.ps1"'
$arguments = "-NoProfile -Noninteractive -ExecutionPolicy Bypass -File $($path_to_col)"

$action = New-ScheduledTaskAction -Execute '"powershell.exe"' `
-Argument $arguments

$trigger = New-ScheduledTaskTrigger -Daily -At 9pm

#The script may not work without a domain user
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "mysql_db_dumper" -Description "MySQL DB Dump for Database 'dbname'" -TaskPath "\" `
-User "domain\user" -Password 'P@ssw0rd' -RunLevel Highest
```
