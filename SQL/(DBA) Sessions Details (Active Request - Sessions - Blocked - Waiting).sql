/*SESSIONS DETAILS

Scripts include:

Current Requests
Current sessions
Blocked requests
Waiting Tasks details
Sessions older than 5 days old without activity
Idle sessions with orphaned transaction

*/

/*Current Requests*/

SELECT  
	DES.login_name AS [Login],
    DER.command AS [Command],
   SUBSTRING(dest.text, der.statement_start_offset / 2,                   
	(CASE WHEN der.statement_end_offset = -1 
	THEN DATALENGTH(dest.text) 
	ELSE der.statement_end_offset 
	END - der.statement_start_offset ) / 2) AS SQL_statement_Currently_executing , 
    DES.login_time AS [Login Time],
    DES.[host_name] AS [Hostname],
    DES.[program_name] AS [Program],
    DER.session_id AS [Session ID],
    DEC.client_net_address [Client Net Address],
    der.status AS [Status],
    DB_NAME(der.database_id) AS [Database Name]
	,des.*
FROM    sys.dm_exec_requests der
    INNER JOIN sys.dm_exec_connections dec
              ON der.session_id = dec.session_id
    INNER JOIN sys.dm_exec_sessions des
              ON des.session_id = der.session_id
    CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS dest
WHERE   
	des.is_user_process = 1
	AND der.session_id <> @@spid
	--AND DATEDIFF(mi,des.last_request_start_time,getdate()) > 5


/*Current sessions*/

SELECT 
	s.session_id
	,s.login_name
	,s.nt_domain
	,s.nt_user_name
	,(select db_name(dbid) from master.sys.dm_exec_sql_text(c.most_recent_sql_handle )) as databasename
	,(select object_id(objectid) from master.sys.dm_exec_sql_text(c.most_recent_sql_handle )) as objectname
	,s.host_name
	,s.program_name
	,s.client_interface_name
	,c.client_net_address
	,c.local_net_address
	,c.connection_id,
	c.parent_connection_id
	,c.most_recent_sql_handle
	,st.text as sqlscript
	,s.last_request_start_time
	,s.last_request_end_time
	,query_plan
	,plan_handle, last_execution_time, execution_count, total_physical_reads, total_logical_writes, total_logical_reads, last_elapsed_time, total_rows
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


/*Blocked requests*/
	
SELECT  
	db_name(DTL.[resource_database_id]) AS [Database]
	,DTL.[resource_type] AS [Resource Type] 
	,CASE WHEN DTL.[resource_type] IN ( 'DATABASE', 'FILE', 'METADATA' )
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
	END AS [Parent Object] 
	,DTL.[request_mode] AS [Lock Type] 
	,DTL.[request_status] AS [Request Status] 
	,DOWT.[wait_duration_ms] AS [Wait Duration (ms)] 
	,DOWT.[wait_type] AS [Wait Type] 
	,DOWT.[session_id] AS [Blocked Session ID] 
	,DES_Blocked.[login_name] AS [Blocked Login] 
	,SUBSTRING(DEST_Blocked.text, (DER.statement_start_offset / 2) + 1,
			  ( CASE WHEN DER.statement_end_offset = -1 
					 THEN DATALENGTH(DEST_Blocked.text) 
					 ELSE DER.statement_end_offset 
				END - DER.statement_start_offset ) / 2) 
										  AS [Blocked Command] 
	,DOWT.[blocking_session_id] AS [Blocking Session ID] 
	,DES_Blocking.[login_name] AS [Blocking Login] 
	,DEST_Blocking.[text] AS [Blocking Command] 
	,DOWT.resource_description AS [Blocking Resource Detail]
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

/*Waiting Tasks details*/


SELECT
    [owt].[session_id],
    [owt].[exec_context_id],
    [ot].[scheduler_id],
    [owt].[wait_duration_ms],
    [owt].[wait_type],
    [owt].[blocking_session_id],
    [owt].[resource_description],
    CASE [owt].[wait_type]
        WHEN N'CXPACKET' THEN
            RIGHT ([owt].[resource_description],
                CHARINDEX (N'=', REVERSE ([owt].[resource_description])) - 1)
        ELSE NULL
    END AS [Node ID],
    --[es].[program_name],
    [est].text,
    [er].[database_id],
    [eqp].[query_plan],
    [er].[cpu_time]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_os_tasks [ot] ON
    [owt].[waiting_task_address] = [ot].[task_address]
INNER JOIN sys.dm_exec_sessions [es] ON
    [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
    [es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE
    [es].[is_user_process] = 1
ORDER BY
    [owt].[session_id],
    [owt].[exec_context_id];
GO


/*Sessions older than 5 days old without activity*/

DECLARE @days_old SMALLINT 
SELECT  @days_old = 5 

SELECT  
	des.session_id ,         
	des.login_time ,         
	des.last_request_start_time ,         
	des.last_request_end_time ,         
	des.[status] ,         
	des.[program_name] ,         
	des.cpu_time ,         
	des.total_elapsed_time ,        
	des.memory_usage ,         
	des.total_scheduled_time ,         
	des.total_elapsed_time ,         
	des.reads ,         
	des.writes ,         
	des.logical_reads ,         
	des.row_count ,         
	des.is_user_process 
FROM    
	sys.dm_exec_sessions des         
	INNER JOIN sys.dm_tran_session_transactions dtst                        
		ON des.session_id = dtst.session_id 
WHERE   
	des.is_user_process = 1         
	AND DATEDIFF(dd, des.last_request_end_time, GETDATE()) > @days_old         
	AND des.status != 'Running' 
ORDER BY des.last_request_end_time	


/*Idle sessions with orphaned transactions*/


SELECT  
	des.session_id ,         
	des.login_time ,         
	des.last_request_start_time ,         
	des.last_request_end_time ,         
	des.host_name ,         
	des.login_name 
FROM    
	sys.dm_exec_sessions des         
	INNER JOIN sys.dm_tran_session_transactions dtst                        
		ON des.session_id = dtst.session_id         
	LEFT JOIN sys.dm_exec_requests der                        
		ON dtst.session_id = der.session_id 
WHERE   
	der.session_id IS NULL 
ORDER BY 
	des.session_id











