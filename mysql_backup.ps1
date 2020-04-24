#Requires -Version 5.0

##########################
## POSH MYSQL DB Dumper ##
##                v1.0  ##
##########################

# Prerequisits:
# VC Runtime must be installed
# https://www.microsoft.com/en-us/download/details.aspx?id=52685

## Change Variables to fit your environment ##
# Software & Configuration paths
$basepath = "C:\temp\mysql-backup-posh"
$mysqlpath = "$($basepath)\mysql" 
$backuppath = "$($basepath)\backups\" 
$7zippath = "$($basepath)\7zip" 
$config = "$($basepath)\db.cnf" 
$errorLog = "$($basepath)\logs\error_dump.log" 
$database = "databasename" 
# Backup File settings
$date = Get-Date 
$timestamp = "" + $date.day + $date.month + $date.year + "_" + $date.hour + $date.minute 
$backupfile = $backuppath + $database + "_" + $timestamp + ".sql" 
$backupzip = $backuppath + $database + "_" + $timestamp + ".zip" 
$dumps2keep = 30
# Mail settings
$smtpserver = "smtp.office365.com"
$username_mail = "name@contoso.com"
$password_mail = ConvertTo-SecureString 'yoursupersecretmailpassword' -asplaintext -force
$ps_creds_mail = new-object -typename System.Management.Automation.PSCredential -argumentlist $username_mail , $password_mail
$sender_mail = "sender@contoso.com" 
$recipient_mail = "recipient@contoso.com" 
 
try { 
    Remove-Item $errorLog -ErrorAction SilentlyContinue
    Set-Location $mysqlpath 
    .\mysqldump.exe --defaults-extra-file=$config --log-error=$errorLog  --result-file=$backupfile  --databases $database /c 
   
    Set-Location $7zippath 
    .\7z.exe a -tzip $backupzip $backupfile 
 
    $dumpsize = ((Get-Item $backupfile).length/1MB)
    $dumpsize = [math]::Round($dumpsize, 2)
    if ($dumpsize -le 0) {
        throw
    }
    Remove-Item $backupfile 

    Set-Location $backuppath 
    $oldbackups = Get-ChildItem *.zip* 
 
    for ($i = 0; $i -lt $oldbackups.count; $i++) { 
        if ($oldbackups[$i].CreationTime -lt $date.AddDays(-$dumps2keep)) { 
            $oldbackups[$i] | Remove-Item -Confirm:$false 
        } 
    } 
    $subject = "[Success] Database Dump"
    $body = "The Database was dumped successfully.<br><br> Dump Size: $($dumpsize) MB"
    Send-MailMessage -To $recipient_mail -From $sender_mail -Subject $subject -Body $body -BodyAsHtml -Credential $ps_creds_mail -UseSsl -SmtpServer $smtpserver -WarningAction SilentlyContinue
} 
catch { 
    $subject = "[Failure] Database Dump"
    $body = "The Database dump failed! <br><br><b>Errors:</b><br> - error_dump.log"
    Send-MailMessage -To $recipient_mail -From $sender_mail -Subject $subject -Body $body -BodyAsHtml  -Attachments $errorLog -UseSsl -Credential $ps_creds_mail -SmtpServer $smtpserver
}