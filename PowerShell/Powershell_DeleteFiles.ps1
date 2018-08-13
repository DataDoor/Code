<#
Script is used to clear SQL backups 
older than a specified number of days
#>

#Number of to retain 
$limit = (Get-Date).AddDays(-14)

#Backup paths to cycle through
$backuppaths = "\\Path","\\Path" #Simply remove all but one from the array to just delete from one path.

#loop to delete files
foreach($path in $backuppaths)
{

Get-ChildItem -Path $path -Recurse | Where-Object {!$_.PSIsContainer -and $_.CreationTime -lt $limit -and $_.FullName -notmatch 'Retain'} | Remove-Item

} 



