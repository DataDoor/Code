/*This script will produce SQL to reassign the database to owner 'sa'*/
SELECT 'ALTER AUTHORIZATION ON DATABASE::'+a.NAME+' TO '+'sa',
    a.NAME
	,a.owner_sid
	,b.sid
	,b.NAME
FROM sys.databases a
INNER JOIN sys.server_principals b ON a.owner_sid = b.sid
WHERE b.NAME <> 'sa'




/*This script will produce SQL to reassign the SQL Agent job to owner 'sa'*/
SELECT 'EXEC MSDB.dbo.sp_update_job ' + char(13) +
'@job_name = ' + char(39) + j.[Name] + char(39) + ',' + char(13) + 
'@owner_login_name = ' + char(39) + 'sa' + char(39) + char(13) + char(13)
FROM MSDB.dbo.sysjobs j
INNER JOIN Master.dbo.syslogins l
ON j.owner_sid = l.sid
WHERE l.[name] <> 'sa' 
ORDER BY j.[name]


