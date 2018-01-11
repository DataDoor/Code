/*BACKUP AND RESTORE SCRIPTS

This script contain:

Backup information - This details the last backup and its details for each database
Last backup date - Thsi details when the database was last backed up by type
Database backup timings - This details how long each database is taking to be backed up
Failed database backup  - This compares the database which have been backed up in the last day against all database held on the instance
Restored database details - This details the last time a database was restore and what backup was used
Delete old files - This script removes backup files older than n days
 
*/

/*Backup details PIVOT*/

WITH backupCTE 
AS (
SELECT name, recovery_model_desc, d AS 'Last Full Backup', i AS 'Last Differential Backup', l AS 'Last Tlog Backup' 
FROM
	(
	SELECT db.name, db.recovery_model_desc,type, backup_finish_date
	FROM master.sys.databases db
	LEFT OUTER JOIN msdb.dbo.backupset a
	ON a.database_name = db.name
	WHERE db.state_desc = 'ONLINE'
) AS Sourcetable  
PIVOT
(MAX (backup_finish_date) FOR type IN (D,I,L) ) AS MostRecentBackup )
SELECT * FROM backupCTE


/*Backup information */

SELECT  
	sd.name AS [Database],
	CASE WHEN bs.type = 'D' THEN 'Full backup'
		 WHEN bs.type = 'I' THEN 'Differential'
		 WHEN bs.type = 'L' THEN 'Log'
		 WHEN bs.type = 'F' THEN 'File/Filegroup'
		 WHEN bs.type = 'G' THEN 'Differential file'
		 WHEN bs.type = 'P' THEN 'Partial'
		 WHEN bs.type = 'Q' THEN 'Differential partial'
		 ELSE 'Unknown (' + bs.type + ')'
	END AS [Backup Type],
	bs.backup_start_date AS [StartDate],
	bs.backup_finish_date AS [EndDate],
	bmf.physical_device_name,
	bs.user_name
FROM    
	master..sysdatabases sd
	INNER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
	INNER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
--WHERE sd.name = DB_Name() AND bs.backup_start_date < GETDATE() 
--WHERE bmf.physical_device_name ='\\em-vbackup\SQlbackups\SRM Phase2\UAT\Adhoc - Retain\Pre UAT Start Backups\egpl.bak'
--WHERE Datediff(day, bs.backup_finish_date,getdate()) <=7 AND bs.type = 'D' 
ORDER BY 
	sd.name, 
	[StartDate]


/*Last backup date*/

SELECT  
	sd.name AS [Database],
	CASE WHEN bs.type = 'D' THEN 'Full backup'
		 WHEN bs.type = 'I' THEN 'Differential'
		 WHEN bs.type = 'L' THEN 'Log'
		 WHEN bs.type = 'F' THEN 'File/Filegroup'
		 WHEN bs.type = 'G' THEN 'Differential file'
		 WHEN bs.type = 'P' THEN 'Partial'
		 WHEN bs.type = 'Q' THEN 'Differential partial'
		 WHEN bs.type IS NULL THEN 'No backups'
		 ELSE 'Unknown (' + bs.type + ')'
	END AS [Backup Type],
	max(bs.backup_start_date) AS [Last Backup of Type]
FROM    
	master..sysdatabases sd
    LEFT OUTER JOIN msdb..backupset bs ON rtrim(bs.database_name) = rtrim(sd.name)
    LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   
	sd.name <> 'tempdb' 
GROUP BY 
	sd.name,
    bs.type,
    bs.database_name
ORDER BY 
	sd.name, [Last Backup of Type]


/*Database backup timings*/

SELECT 
     ROW_NUMBER() OVER (PARTITION BY sd.name,bs.type ORDER BY sd.name,bs.type) AS [DatabaseBackupRowID]
	,@@SERVERNAME AS [SQLInstance]
	,sd.name AS [Database]
	,CASE WHEN bs.type = 'D' THEN 'Full backup'
		 WHEN bs.type = 'I' THEN 'Differential'
		 WHEN bs.type = 'L' THEN 'Log'
	END AS [Backup Type]
	,CAST(CAST(bs.backup_size / 1000000 AS INT) AS VARCHAR(14)) AS [CurrentBackupSize(MB)]
	,MAX(CAST(bs.backup_size / 1000000 AS INT)) OVER (PARTITION BY sd.name,bs.type)  AS [MaxBackupSize(MB)]
	,MIN(CAST(bs.backup_size / 1000000 AS INT)) OVER (PARTITION BY sd.name,bs.type)  AS [MinBackupSize(MB)]
	,AVG(CAST(bs.backup_size / 1000000 AS INT)) OVER (PARTITION BY sd.name,bs.type) AS [AvgBackupSize(MB)]
	,bs.backup_start_date AS [StartDate]
	,bs.backup_finish_date AS [EndDate]
	,DATEDIFF(ss,bs.backup_start_date,bs.backup_finish_date) AS [BackupTimeSecs]
	,MAX(DATEDIFF(ss,bs.backup_start_date,bs.backup_finish_date)) OVER (PARTITION BY sd.name,bs.type) AS [MaxBackupTimeSecs]
	,MIN(DATEDIFF(ss,bs.backup_start_date,bs.backup_finish_date)) OVER (PARTITION BY sd.name,bs.type) AS [MinBackupTimeSecs]
	,AVG(DATEDIFF(ss,bs.backup_start_date,bs.backup_finish_date)) OVER (PARTITION BY sd.name,bs.type) AS [AvgBackupTimeSecs]
	,bmf.physical_device_name
FROM    
	master..sysdatabases sd
	LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
	LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE sd.name = 'databaserequired' AND bs.[type] = 'D'


/*Failed database backup script*/

SELECT name FROM sys.databases

EXCEPT 

SELECT  
	sd.name AS [Database]
FROM 
	master..sysdatabases sd
	LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
	LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE 
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'D'  --Full
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'I'  --Differential	 
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'L'  --Log 	 
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'F'  --File/Filegroup
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'G' --Differential file
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'P'  --Partial
	--DATEDIFF(DAY, bs.backup_start_date,GETDATE()) = 0 and bs.type = 'Q'  --Differential partial



/*Restored database details*/

SELECT TOP 10 
	CONVERT(VARCHAR,Restore_date,103)[RestoreDate],
	bs.database_name [BackupOfDatabase],
	Bs.Server_Name[ServerBackupTakenFrom],
	RH.Destination_Database_Name [DatbaseRestored],
	RH.[User_name],
	REVERSE(SUBSTRING(REVERSE(Physical_device_name),0,PATINDEX('%\%',REVERSE(Physical_device_name)))) [PhysicalBackupFileUsed]  
FROM 
	msdb..restorehistory RH
	INNER JOIN msdb..backupset BS ON (RH.Backup_Set_id = BS.Backup_Set_id)
	INNER JOIN msdb..backupmediafamily bmf ON (bs.media_set_id = bmf.media_set_id)
ORDER BY 
	Restore_date DESC



/*
This procedure deletes old backup files

On the actual xp_delete_file proc the First parmeter 0 is for backup files, Change to 1 for report files
Last parameter 0 is for no sub folders
*/
/*



DECLARE @DeleteDate NVARCHAR(50)
DECLARE @Days INT
DECLARE @Path NVARCHAR(2000)
DECLARE @FileType NVARCHAR(10)


SET @Days = -5
SET @DeleteDate = (SELECT REPLACE(CONVERT(NVARCHAR, DATEADD(DAY,@days,GETDATE()), 111), '/', '-') + 'T' + CONVERT(NVARCHAR,DATEADD(DAY,@days,GETDATE()), 108))
SET @Path = 'C:\SQLBackups'
SET @FileType = 'bak'


EXECUTE master.dbo.xp_delete_file 0,@Path,@FileType,@DeleteDate,0

*/