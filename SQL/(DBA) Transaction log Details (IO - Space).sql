/*T-LOG Details - These Scripts show information on the transaction log

Script included:

Logspace =  To determine how much space is left in the t-log
I/o on the t-log  - This will determine which databases have heavy i/o activity on the transaction log

*/


/*Find out size of Tran Logs */

DBCC SQLPERF(logspace)


/*I/O access of the T-SQL LOG*/


SELECT 
	DTST.[session_id],  
	DES.[login_name] AS [Login Name],  
	DB_NAME (DTDT.database_id) AS [Database],  
	DTDT.[database_transaction_begin_time] AS [Begin Time],  
	-- DATEDIFF(ms,DTDT.[database_transaction_begin_time], GETDATE()) AS [Duration ms],  
	CASE DTAT.transaction_type    
		WHEN 1 THEN 'Read/write'     
		WHEN 2  THEN 'Read-only'    
		WHEN 3 THEN  'System'    
		WHEN 4 THEN 'Distributed'   
	END AS [Transaction Type],   
	CASE DTAT.transaction_state	
		WHEN 0 THEN 'Not fully initialized'     
		WHEN 1 THEN  'Initialized, not started'     
		WHEN 2 THEN  'Active'     
		WHEN 3 THEN 'Ended'     
		WHEN 4 THEN  'Commit initiated'     
		WHEN 5 THEN 'Prepared, awaiting resolution'     
		WHEN 6 THEN  'Committed'     
		WHEN 7 THEN 'Rolling back'     
		WHEN 8 THEN 'Rolled back'   
	END AS [Transaction State],  
	DTDT.[database_transaction_log_record_count] AS [Log Records],  
	DTDT.[database_transaction_log_bytes_used] AS [Log Bytes Used],  
	DTDT.[database_transaction_log_bytes_reserved] AS [Log Bytes RSVPd],  
	DEST.[text] AS [Last Transaction Text],  
	DEQP.[query_plan] AS [Last Query Plan]
FROM 
	sys.dm_tran_database_transactions DTDT
	INNER JOIN sys.dm_tran_session_transactions DTST    
		ON DTST.[transaction_id] = DTDT.[transaction_id]  
	INNER JOIN sys.[dm_tran_active_transactions] DTAT    
		ON DTST.[transaction_id] = DTAT.[transaction_id]  
	INNER JOIN sys.[dm_exec_sessions] DES    
		ON DES.[session_id] = DTST.[session_id]  
	INNER JOIN sys.dm_exec_connections DEC    
		ON DEC.[session_id] = DTST.[session_id]  
	LEFT JOIN sys.dm_exec_requests DER    
		ON DER.[session_id] = DTST.[session_id]  
	CROSS APPLY sys.dm_exec_sql_text (DEC.[most_recent_sql_handle]) AS DEST  
	OUTER APPLY sys.dm_exec_query_plan (DER.[plan_handle]) AS DEQP 
ORDER BY DTDT.[database_transaction_log_bytes_used] 
DESC; -- ORDER BY [Duration ms] DESC;
	