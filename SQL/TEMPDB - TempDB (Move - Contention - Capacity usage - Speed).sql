/*TEMPDB - These SQL Scripts can be used with the Temp db to check for space, contention and move the TempDB

Scripts Included:

Space usage  - This scripts can be used to determine which files are hold the most data, and tasks which are consuming the most data space
Contention  - This is where tasks are fighting over space in the TempDB 
Move TempDB - This will move the tempDB to a new location 

/*

SPACE USAGE

SQL has to keep track of everything in tempdb. It organizes the above objects into three
groups: internal objects, external objects, and the version store. You can
see how much total tempdb disk space is allocated to each category by
querying the dynamic management view (DMV) sys.dm_db_file_space_
usage.
*/

SELECT 
	FreePages = SUM(unallocated_extent_page_count),
	FreeSpaceMB = SUM(unallocated_extent_page_count)/128.0,
	VersionStorePages = SUM(version_store_reserved_page_count),
	VersionStoreMB = SUM(version_store_reserved_page_count)/128.0,
	InternalObjectPages = SUM(internal_object_reserved_page_count),
	InternalObjectsMB = SUM(internal_object_reserved_page_count)/128.0,
	UserObjectPages = SUM(user_object_reserved_page_count),
	UserObjectsMB = SUM(user_object_reserved_page_count)/128.0
FROM 
	sys.dm_db_file_space_usage;


/* Tempdb space usage by file*/
SELECT SUM(total_page_count)*8/1024 AS 'tempdb size (MB)',
       SUM(total_page_count) AS 'tempdb pages',
       SUM(allocated_extent_page_count) AS 'in use pages',
       SUM(user_object_reserved_page_count) AS 'user object pages',
       SUM(internal_object_reserved_page_count) AS 'internal object pages',
       SUM(mixed_extent_page_count) AS 'Total Mixed Extent Pages'
FROM   sys.dm_db_file_space_usage ;
GO

/* Tempdb space usage by task*/
SELECT TOP 5 *
FROM sys.dm_db_task_space_usage
WHERE session_id > 50
ORDER BY user_objects_alloc_page_count + internal_objects_alloc_page_count ;
GO

/* Tempdb space by session*/
SELECT *
FROM sys.dm_db_session_space_usage
WHERE session_id > 50
ORDER BY user_objects_alloc_page_count + internal_objects_alloc_page_count DESC ;
GO



/*
CONTENTION

	Tasks waiting on PageIOLatch or PageLatch wait types are experiencing contention. 
	The resource description points to the page that is experiencing contention
	and you can easily parse the resource description to get the page number.
	Then it’s just a math problem to determine if it is an allocation page.
*/

WITH Tasks
AS 
(
	SELECT session_id,
	wait_type,
	wait_duration_ms,
	blocking_session_id,
	resource_description,
	PageID = CAST(Right(resource_description, LEN(resource_description) - CHARINDEX(':', resource_description,3))	AS INT)
FROM sys.dm_os_waiting_tasks
WHERE 
	wait_type LIKE 'PAGE%LATCH_%'
	AND resource_description LIKE '2:%'
)
SELECT 
	session_id,
	wait_type,
	wait_duration_ms,
	blocking_session_id,
	resource_description,
	ResourceType =
	CASE
		WHEN PageID = 1 Or PageID % 8088 = 0 	THEN 'Is PFS Page'
		WHEN PageID = 2 Or PageID % 511232 = 0 	THEN 'Is GAM Page'
		WHEN PageID = 3 Or (PageID - 1) % 	511232 = 0
		THEN 'Is SGAM Page' 	ELSE 'Is Not PFS, GAM, or SGAM page'
	END
FROM Tasks;

/*THIS SQL  CHECKS THE SPEEDS FO THE READ AND WRITES*/

SELECT files.physical_name, 
files.name, 
stats.num_of_writes, 
(1.0 * stats.io_stall_write_ms / stats.num_of_writes) AS avg_write_stall_ms, --both need to be below 25ms
stats.num_of_reads, 
(1.0 * stats.io_stall_read_ms / stats.num_of_reads) AS avg_read_stall_ms --both need to be below 25ms
FROM sys.dm_io_virtual_file_stats(2, NULL) as stats
INNER JOIN master.sys.master_files AS files 
ON stats.database_id = files.database_id
AND stats.file_id = files.file_id
WHERE files.type_desc = 'ROWS'


/*MOVE TEMPDB

To use this script initially check the tempdb database files use the sp_helpfile command below and then used the template replacement button to 
change the values as required.
*/





use tempdb;

sp_helpfile;


USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb.mdf>',   
SIZE = 2048MB,
FILEGROWTH = 0)
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = N'<TempDB_LogFile2,sysname,H:\MSSQL\Logs\tempdb.ldf>')  
GO


ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev2,
FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb2.mdf>',
SIZE = 2048mb,
FILEGROWTH = 0
)
GO

ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev3,
FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb3.mdf>',
SIZE = 2048mb,
FILEGROWTH = 0
)
GO


ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev4,
FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb4.mdf>',
SIZE = 2048mb,
FILEGROWTH = 0
)


