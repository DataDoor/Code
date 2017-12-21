/*LOCKS - These SQL scripts detail locking information

Scripts included:

Blocked or blocking sessions
Current lock information
Locking waits
Resources being held by current locks
*/

/*Blocked or blocking sessions*/

SELECT  
	db_name(DTL.[resource_database_id]) AS [Database],
	DTL.[resource_type] AS [Resource Type] ,
	CASE WHEN DTL.[resource_type] IN ( 'DATABASE', 'FILE', 'METADATA' )
		 THEN DTL.[resource_type]
		 WHEN DTL.[resource_type] = 'OBJECT'
		 THEN OBJECT_NAME(DTL.resource_associated_entity_id)
		 WHEN DTL.[resource_type] IN ( 'KEY', 'PAGE', 'RID' )
		 THEN ( SELECT  OBJECT_NAME([object_id])
				FROM    sys.partitions
				WHERE   sys.partitions.[hobt_id] =
							 DTL.[resource_associated_entity_id]
			  )
		 ELSE 'Unidentified'
	END AS [Parent Object] ,
	DTL.[request_mode] AS [Lock Type] ,
	DTL.[request_status] AS [Request Status] ,
	DOWT.[wait_duration_ms] AS [Wait Duration (ms)] ,
	DOWT.[wait_type] AS [Wait Type] ,
	DOWT.[session_id] AS [Blocked Session ID] ,
	DES_Blocked.[login_name] AS [Blocked Login] ,
	SUBSTRING(DEST_Blocked.text, (DER.statement_start_offset / 2) + 1,
			  ( CASE WHEN DER.statement_end_offset = -1 
					 THEN DATALENGTH(DEST_Blocked.text) 
					 ELSE DER.statement_end_offset 
				END - DER.statement_start_offset ) / 2) 
										  AS [Blocked Command] , 
	DOWT.[blocking_session_id] AS [Blocking Session ID] ,
	DES_Blocking.[login_name] AS [Blocking Login] ,
	DEST_Blocking.[text] AS [Blocking Command] ,
	DOWT.resource_description AS [Blocking Resource Detail]
FROM
	sys.dm_tran_locks DTL
	INNER JOIN sys.dm_os_waiting_tasks DOWT
		ON DTL.lock_owner_address = DOWT.resource_address
	INNER JOIN sys.[dm_exec_requests] DER
		ON DOWT.[session_id] = DER.[session_id]
	INNER JOIN sys.dm_exec_sessions DES_Blocked
		ON DOWT.[session_id] = DES_Blocked.[session_id]
	INNER JOIN sys.dm_exec_sessions DES_Blocking
		ON DOWT.[blocking_session_id] = DES_Blocking.[session_id]
	INNER JOIN sys.dm_exec_connections DEC
		ON DOWT.[blocking_session_id] = DEC.[most_recent_session_id]
	CROSS APPLY sys.dm_exec_sql_text(DEC.[most_recent_sql_handle])AS DEST_Blocking
	CROSS APPLY sys.dm_exec_sql_text(DER.sql_handle) AS DEST_Blocked


/* Current lock information*/
SELECT 
	resource_type
	,resource_subtype
	,resource_description
	,resource_associated_entity_id
	,request_mode
	,request_status

FROM sys.dm_tran_locks
WHERE request_session_id = @@spid;



/*Locking waits*/

SELECT
	wait_type,
	waiting_tasks_count,
	wait_time_ms,
	max_wait_time_ms 
FROM sys.dm_os_wait_stats 
WHERE
	wait_type LIKE 'LCK%' 
	AND Waiting_tasks_count >0 
ORDER BY waiting_tasks_count DESC


/*Resources being held by current locks*/


SELECT  
	[resource_type] ,         
	DB_NAME([resource_database_id]) AS [Database Name] ,         
	CASE 
		WHEN DTL.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' )              
		THEN DTL.resource_type              
		WHEN DTL.resource_type = 'OBJECT'              
		THEN OBJECT_NAME(DTL.resource_associated_entity_id,DTL.[resource_database_id])              
		WHEN DTL.resource_type IN ( 'KEY', 'PAGE', 'RID' )
		THEN ( SELECT  OBJECT_NAME([object_id])                     
		FROM    sys.partitions                     
		WHERE   sys.partitions.hobt_id =  DTL.resource_associated_entity_id )              
		ELSE 'Unidentified'
	END AS requested_object_name ,         
	[request_mode] ,         
	[resource_description] 
FROM    sys.dm_tran_locks DTL 
WHERE   
	DTL.[resource_type] <> 'Database'


SELECT 
	L.request_session_id AS SPID,
	DB_NAME(L.resource_database_id) AS DatabaseName,
	O.Name AS LockedObjectName,
	P.object_id AS LockedObjectId,
	L.resource_type AS LockedResource,
	L.request_mode AS LockType,
	ST.text AS SqlStatementText,
	ES.login_name AS LoginName,
	ES.host_name AS HostName,
	TST.is_user_transaction as IsUserTransaction,
	AT.name as TransactionName,
	CN.auth_scheme as AuthenticationMethod
FROM 
	sys.dm_tran_locks L
	JOIN sys.partitions P ON (P.hobt_id = L.resource_associated_entity_id)
	JOIN sys.objects O ON (O.object_id = P.object_id)
	JOIN sys.dm_exec_sessions ES ON (ES.session_id = L.request_session_id)
	JOIN sys.dm_tran_session_transactions TST ON (ES.session_id = TST.session_id)
	JOIN sys.dm_tran_active_transactions AT ON (TST.transaction_id = AT.transaction_id)
	JOIN sys.dm_exec_connections CN ON (CN.session_id = ES.session_id)
	CROSS APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) AS ST
WHERE 
	resource_database_id = db_id()
ORDER BY 
	L.request_session_id


