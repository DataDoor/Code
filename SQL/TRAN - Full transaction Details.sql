/*TRANSACTIONS - These SQL Scripts show all details for transactions in progress

Scripts include:

Full transaction state details
High Detailed Snapshot Version Store usage
Active snapshot versioning transactions
Full Transcations details using Snapshot Versioning
*/

/*Full transaction state details*/


SELECT 
	DTAT.[Transaction_id],
	DTAT.[name] ,         
	DTAT.transaction_begin_time ,         
	CASE DTAT.transaction_type           
		WHEN 1 THEN 'Read/write'           
		WHEN 2 THEN 'Read-only'           
		WHEN 3 THEN 'System'           
		WHEN 4 THEN 'Distributed'         
	END AS transaction_type ,         
	CASE DTAT.transaction_state          
		WHEN 0 THEN 'Not fully initialized'           
		WHEN 1 THEN 'Initialized, not started'           
		WHEN 2 THEN 'Active'           
		WHEN 3 THEN 'Ended' -- only applies to read-only transactions           
		WHEN 4 THEN 'Commit initiated'-- distributed transactions only           
		WHEN 5 THEN 'Prepared, awaiting resolution'           
		WHEN 6 THEN 'Committed'           
		WHEN 7 THEN 'Rolling back'           
		WHEN 8 THEN 'Rolled back'
	END AS transaction_state ,         
	CASE DTAT.dtc_state           
		WHEN 1 THEN 'Active'           
		WHEN 2 THEN 'Prepared'           
		WHEN 3 THEN 'Committed'           
		WHEN 4 THEN 'Aborted'           
		WHEN 5 THEN 'Recovered'         
	END AS dtc_state 
FROM    
	sys.dm_tran_active_transactions DTAT         
	INNER JOIN sys.dm_tran_session_transactions DTST                          
		ON DTAT.transaction_id = DTST.transaction_id 
WHERE   
	[DTST].[is_user_transaction] = 1 
ORDER BY DTAT.transaction_begin_time

/*High Detailed Snapshot Version Store usage*/


WITH     version_store ( [rowset_id], [bytes consumed] )           
AS ( 
SELECT TOP 1                         
	[rowset_id] ,                         
	SUM([record_length_first_part_in_bytes]+ [record_length_second_part_in_bytes]) AS [bytes consumed]                
FROM     
	sys.dm_tran_version_store               
	
GROUP BY 
	[rowset_id]                
ORDER BY 
	SUM([record_length_first_part_in_bytes] + [record_length_second_part_in_bytes]))      
SELECT 
	VS.[rowset_id] ,             
	VS.[bytes consumed] ,             
	DB_NAME(DTVS.[database_id]) AS [database name] ,             
	DTASDT.[session_id] AS session_id ,             
	DES.[login_name] AS [session login] ,             
	DEST.text AS [session command]     
FROM    
	version_store VS             
	INNER JOIN sys.[dm_tran_version_store] DTVS                          
		ON VS.rowset_id = DTVS.[rowset_id]             
	INNER JOIN sys.[dm_tran_active_snapshot_database_transactions] DTASDT                          
		ON DTVS.[transaction_sequence_num] =  DTASDT.[transaction_sequence_num]
	INNER JOIN sys.dm_exec_connections DEC 	
		ON DTASDT.[session_id] = DEC.[most_recent_session_id]             
	INNER JOIN sys.[dm_exec_sessions] DES                          
		ON DEC.[most_recent_session_id] = DES.[session_id]             
	CROSS APPLY sys.[dm_exec_sql_text](DEC.[most_recent_sql_handle]) DEST;

/*Active snapshot versioning transactions*/


SELECT  
	DTASDT.transaction_id          
	,DTASDT.session_id          
	,DTASDT.transaction_sequence_num       
	,DTASDT.first_snapshot_sequence_num          
	,DTASDT.commit_sequence_num       
	,DTASDT.is_snapshot   
	,DTASDT.elapsed_time_seconds          
	,DEST.text AS [command text] 
FROM    
	sys.dm_tran_active_snapshot_database_transactions DTASDT
	INNER JOIN sys.dm_exec_connections DEC 
		ON DTASDT.session_id = DEC.most_recent_session_id         
	INNER JOIN sys.dm_tran_database_transactions DTDT                        
		ON DTASDT.transaction_id = DTDT.transaction_id         
	CROSS APPLY sys.dm_exec_sql_text(DEC.most_recent_sql_handle) AS DEST 
WHERE   DTDT.database_id = DB_ID()


/*Full Transcations details using Snapshot Versioning */


SELECT  
	DTTS.[transaction_sequence_num] ,         
	trx_current.[session_id] AS current_session_id ,         
	DES_current.[login_name] AS [current session login] ,         
	DEST_current.text AS [current session command] ,         
	DTTS.[snapshot_sequence_num] ,         
	trx_existing.[session_id] AS existing_session_id ,         
	DES_existing.[login_name] AS [existing session login] ,         
	DEST_existing.text AS [existing session command] 
FROM    
	sys.dm_tran_transactions_snapshot DTTS
	 INNER JOIN sys.dm_tran_active_snapshot_database_transactions trx_current                          
		ON DTTS.[transaction_sequence_num] =  trx_current.[transaction_sequence_num]         
	INNER JOIN sys.[dm_exec_connections] DEC_current                          
		ON trx_current.[session_id] = DEC_current.[most_recent_session_id]         
	INNER JOIN sys.[dm_exec_sessions] DES_current                          
		ON DEC_current.[most_recent_session_id] = DES_current.[session_id]         
	INNER JOIN sys.[dm_tran_active_snapshot_database_transactions] trx_existing
		ON DTTS.[snapshot_sequence_num] = trx_existing.[transaction_sequence_num]         
	INNER JOIN sys.[dm_exec_connections] DEC_existing
		ON trx_existing.[session_id] = DEC_existing.[most_recent_session_id]         
	INNER JOIN sys.[dm_exec_sessions] DES_existing 
		ON DEC_existing.[most_recent_session_id] = DES_existing.[session_id]         
	CROSS APPLY sys.[dm_exec_sql_text] (DEC_current.[most_recent_sql_handle]) DEST_current         
	CROSS APPLY sys.[dm_exec_sql_text] (DEC_existing.[most_recent_sql_handle]) DEST_existing 
ORDER BY 
	DTTS.[transaction_sequence_num] ,         
	DTTS.[snapshot_sequence_num] ;