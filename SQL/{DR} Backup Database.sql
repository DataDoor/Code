/* Backup Database Template*/

BACKUP DATABASE <Database Name, sysname,> 
	TO  DISK = N'<Backup Path,sysname,\\em-appl018\sqlbackups><Backup Name, sysname,>.bak' 
WITH 
/*Delete as Applicable*/
	COPY_ONLY
	--,NOFORMAT
	--,COMPRESSION
	--,NOINIT
	,NAME = N'<Database Name, sysname, Database Name>-Full Database Backup'
	,DESCRIPTION = '<Backup description, sysname,>' 
	--,STATS = 10;
GO


