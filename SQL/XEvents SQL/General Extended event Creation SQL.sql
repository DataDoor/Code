---------------------------------
/*LOGIN CHECK XE*/
---------------------------------

CREATE EVENT SESSION [Login_Checks] ON SERVER 
ADD EVENT sqlserver.login(
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.session_nt_username,sqlserver.username))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

---------------------------------
/*QUERY XE*/
---------------------------------


CREATE EVENT SESSION [QueryLog] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_data_stream=(1)
    ACTION(sqlos.scheduler_id,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlos.scheduler_id,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.sql_text))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
GO

