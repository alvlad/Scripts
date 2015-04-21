#Set current Date
$data = Get-Date
#Set last date
$OldDate = $data.AddDays("-1");
#Folder source
$path = "D:\MSSQL\Backup\*.bak"
#Folder destination
$DestPath = "\\192.168.1.99\backup"
#Test folder source
if (Test-Path $DestPath)
{
    #Copy all files to destination folder
    Copy-Item -Path $path -Destination $DestPath -Force | Where-Object {$_.LastWriteTime -lt $OldDate}
    #Delete old files, more than $olddays, in destination folder
    Get-ChildItem $DestPath -Filter '*.bak' | Where-Object { $_.LastWriteTime -lt $OldDate } | Remove-Item -filter "*.bak" 
    
}
else
{
     Send-MailMessage -From "administrator@domain.com" -To "nm@domain.com" -Body "Error SQL backup" -Subject "SQL backup" -SmtpServer "exchange.domain.com" -
     exit
}