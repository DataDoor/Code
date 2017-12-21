CREATE PROC usp_IOWait_TimeDelayComparison (@Hours INT = 0, @Minutes INT = 0, @Seconds INT = 0)
AS 

IF (@Hours) = 0 AND (@Minutes) = 0 AND (@Seconds) = 0 

BEGIN

	RAISERROR('This stored procedure required a delay time to be supplied and currently the delay is set at 0, please resupply the required @Hours, @Minutes, @Seconds Parameters wiht values greater than 0',12,0)
	
END

ELSE 


BEGIN


/*BUILD DELAY*/


/*DROP TEMP TABLES*/

IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##IOStats1')
	DROP TABLE [##IOStats1];
 
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##IOStats2')
	DROP TABLE [##IOStats2];

IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##WaitStats1')
	DROP TABLE [##WaitStats1];
 
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##WaitStats2')
	DROP TABLE [##WaitStats2];


/*INSERT BASELINE I/O & WAIT DATA INTO TEMP TABLES*/
 
SELECT [database_id], [file_id], [num_of_reads], [io_stall_read_ms],
       [num_of_writes], [io_stall_write_ms], [io_stall],
       [num_of_bytes_read], [num_of_bytes_written], [file_handle]
INTO ##IOStats1
FROM sys.dm_io_virtual_file_stats (NULL, NULL);

SELECT [wait_type], [waiting_tasks_count], [wait_time_ms],
       [max_wait_time_ms], [signal_wait_time_ms]
INTO ##WaitStats1
FROM sys.dm_os_wait_stats;




 /*DELAY*/

/*BUILD REQUIRED DELAY*/

/*DECLARE @Hours INT, @Minutes INT, @Seconds INT*/
--DECLARE @Hours_Parsed CHAR(2), @Minutes_Parsed CHAR(2), @Seconds_Parsed CHAR(2)
DECLARE @Delay CHAR(8)

SET @Delay = '00:00:01'

/*SET @Hours = 0
SET @Minutes = 2
SET @Seconds =3*/

/*SELECT 
	@Hours_Parsed = CASE 
										WHEN @Hours = 0 THEN '00'
										WHEN @Hours > 0 AND LEN(@Hours) = 1 THEN '0'+CONVERT(CHAR(1),@Hours)
										ELSE CONVERT(CHAR(2),@Hours)
									END
	,@Minutes_Parsed = CASE 
										WHEN @Minutes = 0 THEN '00'
										WHEN @Minutes > 0 AND LEN(@Minutes) = 1 THEN '0'+CONVERT(CHAR(1),@Minutes)
										ELSE CONVERT(CHAR(2),@Minutes)
									END
	,@Seconds_Parsed = CASE 
										WHEN @Seconds = 0 THEN '00'
										WHEN @Seconds > 0 AND LEN(@Seconds) = 1 THEN '0'+CONVERT(CHAR(1),@Seconds)
										ELSE CONVERT(CHAR(2),@Seconds)
									END

SET @DELAY = @Hours_Parsed+':'+@Minutes_Parsed+':'+@Seconds_Parsed
*/

WAITFOR DELAY @Delay



/*INSERT SECOND I/O & WAIT DATA INTO TEMP TABLES, POST DELAY*/
 
SELECT [database_id], [file_id], [num_of_reads], [io_stall_read_ms],
       [num_of_writes], [io_stall_write_ms], [io_stall],
       [num_of_bytes_read], [num_of_bytes_written], [file_handle]
INTO ##IOStats2
FROM sys.dm_io_virtual_file_stats (NULL, NULL);

SELECT [wait_type], [waiting_tasks_count], [wait_time_ms],
       [max_wait_time_ms], [signal_wait_time_ms]
INTO ##WaitStats2
FROM sys.dm_os_wait_stats;


 


/*I/O COMPARISON*/
    
WITH [DiffLatencies] AS
(SELECT
/*Files that weren't in the first snapshot*/
        [ts2].[database_id],
        [ts2].[file_id],
        [ts2].[num_of_reads],
        [ts2].[io_stall_read_ms],
        [ts2].[num_of_writes],
        [ts2].[io_stall_write_ms],
        [ts2].[io_stall],
        [ts2].[num_of_bytes_read],
        [ts2].[num_of_bytes_written]
    FROM [##IOStats2] AS [ts2]
    LEFT OUTER JOIN [##IOStats1] AS [ts1]
        ON [ts2].[file_handle] = [ts1].[file_handle]
    WHERE [ts1].[file_handle] IS NULL
UNION
SELECT
/*Diff of latencies in both snapshots*/
        [ts2].[database_id],
        [ts2].[file_id],
        [ts2].[num_of_reads] - [ts1].[num_of_reads] AS [num_of_reads],
        [ts2].[io_stall_read_ms] - [ts1].[io_stall_read_ms] AS [io_stall_read_ms],
        [ts2].[num_of_writes] - [ts1].[num_of_writes] AS [num_of_writes],
        [ts2].[io_stall_write_ms] - [ts1].[io_stall_write_ms] AS [io_stall_write_ms],
        [ts2].[io_stall] - [ts1].[io_stall] AS [io_stall],
        [ts2].[num_of_bytes_read] - [ts1].[num_of_bytes_read] AS [num_of_bytes_read],
        [ts2].[num_of_bytes_written] - [ts1].[num_of_bytes_written] AS [num_of_bytes_written]
    FROM [##IOStats2] AS [ts2]
    LEFT OUTER JOIN [##IOStats1] AS [ts1]
        ON [ts2].[file_handle] = [ts1].[file_handle]
    WHERE [ts1].[file_handle] IS NOT NULL)
SELECT
    DB_NAME ([vfs].[database_id]) AS [DB],
    LEFT ([mf].[physical_name], 2) AS [Drive],
    [mf].[type_desc],
    [num_of_reads] AS [Reads],
    [num_of_writes] AS [Writes],
    [ReadLatency(ms)] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,
    [WriteLatency(ms)] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,
    /*[Latency] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,*/
    [AvgBPerRead] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,
    [AvgBPerWrite] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,
    /*[AvgBPerTransfer] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE
                (([num_of_bytes_read] + [num_of_bytes_written]) /
                ([num_of_reads] + [num_of_writes])) END,*/
    [mf].[physical_name]
FROM [DiffLatencies] AS [vfs]
JOIN sys.master_files AS [mf]
    ON [vfs].[database_id] = [mf].[database_id]
    AND [vfs].[file_id] = [mf].[file_id]
-- ORDER BY [ReadLatency(ms)] DESC
ORDER BY [WriteLatency(ms)] DESC;



 
 /*WAIT STATS COMPARISON*/

 WITH [DiffWaits] AS
(SELECT
-- Waits that weren't in the first snapshot
        [ts2].[wait_type],
        [ts2].[wait_time_ms],
        [ts2].[signal_wait_time_ms],
        [ts2].[waiting_tasks_count]
    FROM [##WaitStats2] AS [ts2]
    LEFT OUTER JOIN [##WaitStats1] AS [ts1]
        ON [ts2].[wait_type] = [ts1].[wait_type]
    WHERE [ts1].[wait_type] IS NULL
    AND [ts2].[wait_time_ms] > 0
UNION
SELECT
-- Diff of waits in both snapshots
        [ts2].[wait_type],
        [ts2].[wait_time_ms] - [ts1].[wait_time_ms] AS [wait_time_ms],
        [ts2].[signal_wait_time_ms] - [ts1].[signal_wait_time_ms] AS [signal_wait_time_ms],
        [ts2].[waiting_tasks_count] - [ts1].[waiting_tasks_count] AS [waiting_tasks_count]
    FROM [##WaitStats2] AS [ts2]
    LEFT OUTER JOIN [##WaitStats1] AS [ts1]
        ON [ts2].[wait_type] = [ts1].[wait_type]
    WHERE [ts1].[wait_type] IS NOT NULL
    AND [ts2].[waiting_tasks_count] - [ts1].[waiting_tasks_count] > 0
    AND [ts2].[wait_time_ms] - [ts1].[wait_time_ms] > 0),
[Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM [DiffWaits]
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',         N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',            N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',          N'CHECKPOINT_QUEUE',
        N'CHKPT',                       N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',            N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',          N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',       N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',             N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                    N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',           N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',        N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',             N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',              N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',           N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',             N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',         N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',        N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',            N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',         N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',       N'WAIT_FOR_RESULTS',
        N'WAITFOR',                     N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',          N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',         N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',          N'XE_TIMER_EVENT')
    )
SELECT
    [W1].[wait_type] AS [WaitType],
    CAST ([W1].[WaitS] AS DECIMAL (16, 2)) AS [Wait_S],
    CAST ([W1].[ResourceS] AS DECIMAL (16, 2)) AS [Resource_S],
    CAST ([W1].[SignalS] AS DECIMAL (16, 2)) AS [Signal_S],
    [W1].[WaitCount] AS [WaitCount],
    CAST ([W1].[Percentage] AS DECIMAL (5, 2)) AS [Percentage],
    CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgWait_S],
    CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgRes_S],
    CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (16, 4)) AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS],
    [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage threshold



/*TEMP TABLE CLEANUP*/
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
    WHERE [name] = N'##IOStats1')
    DROP TABLE [##IOStats1];
 
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
    WHERE [name] = N'##IOStats2')
    DROP TABLE [##IOStats2];

IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
    WHERE [name] = N'##WaitStats1')
    DROP TABLE [##WaitStats1];
 
IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
    WHERE [name] = N'##WaitStats2')
    DROP TABLE [##WaitStats2];

END

GO