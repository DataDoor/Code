<#
Script is used to clear SQL backups 
older than a specified number of days
#>

#Number of to retain 
$limit = (Get-Date).AddDays(-14)

#Backup paths to cycle through
$backuppaths = "\\SQL-Backups\Sql1\","\\SQL-Backups\Sql2"

#look to delete files
foreach($path in $backuppaths)
{

Get-ChildItem -Path $path -Recurse | Where-Object {!$_.PSIsContainer -and $_.CreationTime -lt $limit -and $_.FullName -notmatch 'Retain'} | Remove-Item

} 



