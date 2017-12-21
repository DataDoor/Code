/*IO SQL Scripts - This set of Script shows the Input and output details for various senarios

This Script includes:

Physical and logical reads by SQL statements - Show read and writes by individual SQL statements
IO per database file - I/o data for each data file
Latency per by file for read and writes - this show the time its taking to read and write data from the disk
Pending I/O Requests - Shows I/o requests which are still pending
Read / Write ratio - This details the difference between the amount of read and writes so highlight heavy OLTP databases etc
Time delay I/o Check - This can be used to show how much I/o is happening on a database in a specified time frame

*/


/*This will show where its taken over 15 seconds, look for pattern i.e. CHECKDB is running, time of day */
sys.xp_readerrorlog 0,1,N'taking longer than 15 seconds'


/*Physical and logical reads & writes By SQL statements*/

SELECT 
	st.text as sqlscript
	, total_physical_reads
	, total_logical_writes
	, total_logical_reads
	, last_elapsed_time
FROM 
	sys.dm_exec_sessions s
		INNER JOIN sys.dm_exec_connections c
		ON c.session_id = s.session_id
		LEFT JOIN sys.dm_exec_query_stats qs
		ON c.most_recent_sql_handle = qs.sql_handle
		CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle ) st
		OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle)
WHERE 
	s.session_id <> @@SPID
ORDER BY total_logical_reads DESC


/*
IO per database file
*/

WITH IOSELECT AS
(
SELECT 
    DB_NAME(vfs.database_id) AS [Database Name]
    ,vfs.file_id
    ,smf.physical_name AS [File Path/Name]
    ,num_of_reads
    	,io_stall_read_ms / num_of_reads AS 'Avg Read Transfer/ms'
	,num_of_bytes_read
	,num_of_writes
	,io_stall_write_ms / num_of_writes AS 'Avg Write Transfer/ms'
	,num_of_bytes_written
	,size_on_disk_bytes
    ,sample_ms / 60000 AS [Number of minutes since server restart]
    ,io_stall_read_ms / 60000 AS [Read Stalls in Minutes]
    ,CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [Average Read Stalls in Milliseconds]
    ,io_stall_write_ms / 60000 AS [Write Stalls in Minutes]
    ,CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [Average Write Stalls in Milliseconds]
    ,io_stall / 60000 AS [Total Stalls in Minutes]
    ,CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [Average IO Stalls in Milliseconds]
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
INNER JOIN sys.master_files smf ON smf.database_id = vfs.database_id
AND smf.file_id = vfs.file_id
)
SELECT 
*
,CAST(100. * [Total Stalls in Minutes] / SUM([Total Stalls in Minutes]) OVER() AS DECIMAL(10, 2)) AS [IO Stall %]
,[Number of minutes since server restart] - [Total Stalls in Minutes] AS TimeNotStalling
FROM IOSELECT
ORDER BY [Total Stalls in Minutes] DESC


/*I/O Latancy*/


/*
Excellent: < 1ms
Very good: < 5ms
Good: 5 – 10ms
Poor: 10 – 20ms
Bad: 20 – 100ms
Really bad: 100 – 500ms
OMG!: > 500ms
*/

SELECT
    --virtual file latency
    [ReadLatency] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,
    [WriteLatency] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,
    [Latency] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,
    --avg bytes per IOP
    [AvgBPerRead] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,
    [AvgBPerWrite] =
        CASE WHEN [io_stall_write_ms] = 0
            THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,
    [AvgBPerTransfer] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE
                (([num_of_bytes_read] + [num_of_bytes_written]) /
                ([num_of_reads] + [num_of_writes])) END,
    LEFT ([mf].[physical_name], 2) AS [Drive],
    DB_NAME ([vfs].[database_id]) AS [DB],
    --[vfs].*,
    [mf].[physical_name]
FROM
    sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
JOIN sys.master_files AS [mf]
    ON [vfs].[database_id] = [mf].[database_id]
    AND [vfs].[file_id] = [mf].[file_id]
-- WHERE [vfs].[file_id] = 2 -- log files
-- ORDER BY [Latency] DESC
-- ORDER BY [ReadLatency] DESC
--ORDER BY [WriteLatency] DESC;
GO


/*Pending I/O Requests */

SELECT
	mf.physical_name,
	dipir.io_pending,
	dipir.io_pending_ms_ticks 
FROM 
	sys.dm_io_pending_io_requests AS dipir
	JOIN sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs ON (dipir.io_handle = divfs.file_handle)
	JOIN sys.master_files AS mf ON divfs.database_id = mf.database_id AND divfs.file_id = mf.file_id 
ORDER BY 
	dipir.io_pending--Show I/O completed by the OS first         dipir.io_pending_ms_ticks DESC


/*Read / Write ratio */

DECLARE @databaseName SYSNAME 
SET @databaseName = '%'--obviously not the real name  --'%' gives all databases




SELECT 
	CASE  WHEN
		(SUM(user_updates + user_seeks + user_scans + user_lookups) = 0 ) THEN NULL
		ELSE ( CAST(SUM(user_seeks + user_scans + user_lookups) AS DECIMAL) /CAST(SUM(user_updates+user_seeks+user_scans +user_lookups) AS DECIMAL)) END AS RatioOfReads,
		CASE WHEN (SUM(user_updates + user_seeks + user_scans + user_lookups) = 0 ) THEN NULL 
		ELSE (CAST(SUM(user_updates) AS DECIMAL)/CAST(SUM(user_updates+user_seeks+user_scans+user_lookups) AS DECIMAL))END AS RatioOfWrites ,
		SUM(user_updates + user_seeks + user_scans + user_lookups) AS TotalReadOperations,
		SUM(user_updates) AS TotalWriteOperations 
FROM sys.dm_db_index_usage_stats AS ddius 
WHERE DB_NAME(database_id) LIKE @databaseName



/*Time delay I/o Check*/

---Gather baseline data of physical i/o on data files 

SELECT 
	DB_NAME(mf.database_id) AS databaseName,
	mf.physical_name,
	divfs.num_of_reads,
	divfs.num_of_bytes_read,
	divfs.io_stall_read_ms,
	divfs.num_of_writes,
	divfs.num_of_bytes_written,
	divfs.io_stall_write_ms,
	divfs.io_stall,
	size_on_disk_bytes,
	GETDATE() AS baselineDate  INTO  #baseline 
FROM
	sys.dm_io_virtual_file_stats(NULL,NULL) AS divfs 
	JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id AND mf.file_id = divfs.file_id

----Check data 

SELECT
	physical_name,
	num_of_reads,
	num_of_bytes_read,
	io_stall_read_ms 
FROM #baseline 
--WHERE databaseName = 'DatabaseName'


----Add delay for to show differences 

WAITFOR DELAY '00:10:00';

---show data after time delay to highight differences.

WITH currentLine AS
(
	SELECT
			DB_NAME(mf.database_id) AS databaseName,
			mf.physical_name,
			num_of_reads,
			num_of_bytes_read,
			io_stall_read_ms,
			num_of_writes,num_of_bytes_written,
			io_stall_write_ms,
			io_stall,
			size_on_disk_bytes,
			GETDATE() AS currentlineDate
			FROM
				sys.dm_io_virtual_file_stats(NULL,NULL) AS divfs
				JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id AND mf.file_id = divfs.file_id
) 
SELECT
	currentLine.databaseName, 
	LEFT(currentLine.physical_name,1) AS drive, 
	currentLine.physical_name,
	DATEDIFF(millisecond,baseLineDate,currentLineDate) AS elapsed_ms, 
	currentLine.io_stall - #baseline.io_stall AS io_stall_ms,
	currentLine.io_stall_read_ms - #baseline.io_stall_read_ms AS io_stall_read_ms,
	currentLine.io_stall_write_ms - #baseline.io_stall_write_ms AS io_stall_write_ms,
	currentLine.num_of_reads - #baseline.num_of_reads AS num_of_reads ,
	currentLine.num_of_bytes_read - #baseline.num_of_bytes_read AS num_of_bytes_read ,
	currentLine.num_of_writes - #baseline.num_of_writes AS num_of_writes,
	currentLine.num_of_bytes_written - #baseline.num_of_bytes_written AS num_of_bytes_written 
FROM 
	currentLine 
	INNER JOIN #baseline ON #baseLine.databaseName = currentLine.databaseName
	AND #baseLine.physical_name = currentLine.physical_name 
--WHERE 
--	#baseline.databaseName = 'DatabaseName'

