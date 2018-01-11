/*CPU SCRIPTS - This Scripts can be help to with CPU problems*/


/* This script is useful to check pressure on cpu's, remember one schedule = on processor 
the where clause is there to remove the internal schedulers used by SQL Server internally

Remember 10+ in the runnable task count indicates problems with cpu pressure*/


SELECT 
	scheduler_id,
	Current_tasks_count, 
	runnable_tasks_count,
	work_queue_count,
	pending_disk_io_count
FROM 
	sys.dm_os_schedulers 
WHERE 
	scheduler_id < 255 
	
	
/*This will display all statements being run and the associated scheduler that the statement is running on is:*/
	
SELECT 
	a.scheduler_id ,
	b.session_id,
	 (SELECT TOP 1 SUBSTRING(s2.text,statement_start_offset / 2+1 , 
		  ( (CASE WHEN statement_end_offset = -1 
			 THEN (LEN(CONVERT(nvarchar(max),s2.text)) * 2) 
			 ELSE statement_end_offset END)  - statement_start_offset) / 2+1))  AS sql_statement
FROM sys.dm_os_schedulers a 
INNER JOIN sys.dm_os_tasks b on a.active_worker_address = b.worker_address
INNER JOIN sys.dm_exec_requests c on b.task_address = c.task_address
CROSS APPLY sys.dm_exec_sql_text(c.sql_handle) AS s2 
WHERE c.session_id != @@spid


/*This displays the amount percentage of signal time for the CPU's*/


Select signal_wait_time_ms=sum(signal_wait_time_ms)
          ,'%signal (cpu) waits' = cast(100.0 * sum(signal_wait_time_ms) / sum (wait_time_ms) as numeric(20,2))
          ,resource_wait_time_ms=sum(wait_time_ms - signal_wait_time_ms)
          ,'%resource waits'= cast(100.0 * sum(wait_time_ms - signal_wait_time_ms) / sum (wait_time_ms) as numeric(20,2))
From sys.dm_os_wait_stats



/* 
   This will recommend a MAXDOP setting appropriate for your machine's NUMA memory
   configuration.  You will need to evaluate this setting in a non-production 
   environment before moving it to production.

   MAXDOP can be configured using:  
   EXEC sp_configure 'max degree of parallelism',X;
   RECONFIGURE

   If this instance is hosting a Sharepoint database, you MUST specify MAXDOP=1 
   (URL wrapped for readability)
   http://blogs.msdn.com/b/rcormier/archive/2012/10/25/
   you-shall-configure-your-maxdop-when-using-sharepoint-2013.aspx

   Biztalk (all versions, including 2010): 
   MAXDOP = 1 is only required on the BizTalk Message Box
   database server(s), and must not be changed; all other servers hosting other 
   BizTalk Server databases may return this value to 0 if set.
   http://support.microsoft.com/kb/899000
*/


DECLARE @CoreCount int;
DECLARE @NumaNodes int;

SET @CoreCount = (SELECT i.cpu_count from sys.dm_os_sys_info i);
SET @NumaNodes = (
    SELECT MAX(c.memory_node_id) + 1 
    FROM sys.dm_os_memory_clerks c 
    WHERE memory_node_id < 64
    );

IF @CoreCount > 4 /* If less than 5 cores, don't bother. */
BEGIN
    DECLARE @MaxDOP int;

    /* 3/4 of Total Cores in Machine */
    SET @MaxDOP = @CoreCount * 0.75; 

    /* if @MaxDOP is greater than the per NUMA node
       Core Count, set @MaxDOP = per NUMA node core count
    */
    IF @MaxDOP > (@CoreCount / @NumaNodes) 
        SET @MaxDOP = (@CoreCount / @NumaNodes) * 0.75;

    /*
        Reduce @MaxDOP to an even number 
    */
    SET @MaxDOP = @MaxDOP - (@MaxDOP % 2);

    /* Cap MAXDOP at 8, according to Microsoft */
    IF @MaxDOP > 8 SET @MaxDOP = 8;

    PRINT 'Suggested MAXDOP = ' + CAST(@MaxDOP as varchar(max));
END
ELSE
BEGIN
    PRINT 'Suggested MAXDOP = 0 since you have less than 4 cores total.';
    PRINT 'This is the default setting, you likely do not need to do';
    PRINT 'anything.';
END