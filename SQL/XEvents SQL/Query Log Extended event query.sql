SELECT CAST(target_data as xml) AS targetdata
INTO #capture_waits_data
FROM sys.dm_xe_session_targets xet
JOIN sys.dm_xe_sessions xes
    ON xes.address = xet.event_session_address
WHERE xes.name = 'QueryPerf'

;WITH [XEData] AS
(
SELECT  
	xed.event_data.value('@name','VARCHAR(30)') AS EventType
	,xed.event_data.value('(data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)') AS sqlStatement
	,xed.event_data.value('(action[@name="sql_text"]/value)[1]', 'NVARCHAR(MAX)') AS Sql_Text
	,xed.event_data.value('(data[@name="physical_reads"]/value)[1]', 'int') AS PhysicalReads
	,xed.event_data.value('(data[@name="logical_reads"]/value)[1]', 'int') AS LogicalReads
	,xed.event_data.value('(data[@name="writes"]/value)[1]', 'int') AS Writes
	,xed.event_data.value('(data[@name="cpu_time"]/value)[1]', 'int')/1000 AS [CpuTime(s)]
	,xed.event_data.value('(data[@name="duration"]/value)[1]', 'NUMERIC(10,2)')/1000 AS [Duration(s)]
	,xed.event_data.value('(data[@name="result"]/value)[1]', 'int') AS result
	,xed.event_data.value('(data[@name="row_count"]/value)[1]', 'int') AS [rowcount]
	,xed.event_data.value('(action[@name="plan_handle"]/value)[1]', 'NVARCHAR(MAX)') AS PlanHandle
	,xed.event_data.value('(action[@name="database_name"]/value)[1]', 'NVARCHAR(MAX)') AS DatabaseName
	,xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'NVARCHAR(MAX)') AS ClientHostName
	,xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'NVARCHAR(MAX)') AS ClientAppName
FROM    #capture_waits_data 
	CROSS APPLY targetdata.nodes('//RingBufferTarget/event') AS xed ( event_data )
)
SELECT 
	a.EventType
	,a.sqlStatement
	,a.Sql_Text
	,a.PhysicalReads
	,a.LogicalReads
	,a.Writes
	,a.[CpuTime(s)]
	,a.[Duration(s)]
	,a.result
	,a.[rowcount]
	,a.PlanHandle
	,a.DatabaseName
	,a.ClientHostName
	,a.ClientAppName
FROM XEData a
--WHERE a.sqlStatement LIKE '%Product%'
GROUP BY 	
a.EventType
	,a.sqlStatement
	,a.Sql_Text
	,a.PhysicalReads
	,a.LogicalReads
	,a.Writes
	,a.[CpuTime(s)]
	,a.[Duration(s)]
	,a.result
	,a.[rowcount]
	,a.PlanHandle
	,a.DatabaseName
	,a.ClientHostName
	,a.ClientAppName



DROP TABLE #capture_waits_data





