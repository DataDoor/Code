/*QUERY PERFOMANCE  - This Scripts details the performance of various aspect of queries

Scripts included:

Most frequent used queries  - These are queries with high excutions rates
HIGH CPU - Queries used high CPU 
HIGH IO - Queries using high I/O

No index (heap)  -Plan cache 
Index & Clustered Index Scans -Plan cache 
Bookmark or RID Lookups -Plan cache 
Implicit Conversions -Plan cache 


*/

/*Most frequent used queries*/

;with FREQUENT_QUERIES as
(
    select top 20 
        query_hash, 
        sum(execution_count) executions
    from sys.dm_exec_query_stats qs
    	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) 
    where query_hash <> 0x0
	AND DB_NAME(dbid) LIKE '%' --Change this to the name desired database if you require database specific results
    group by query_hash
    order by sum(execution_count) desc
)
select @@servername as server_name,
    coalesce(db_name(st.dbid), db_name(cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    coalesce(object_name(ST.objectid, ST.dbid), '<none>') as [object_name],
    qs.query_hash,
    qs.execution_count,
    executions as total_executions_for_query,
    SUBSTRING(ST.TEXT,(QS.statement_start_offset + 2) / 2,
        (CASE 
            WHEN QS.statement_end_offset = -1  THEN LEN(CONVERT(NVARCHAR(MAX),ST.text)) * 2
            ELSE QS.statement_end_offset
            END - QS.statement_start_offset) / 2) as sql_text,
    qp.query_plan
	,qs.plan_handle
from sys.dm_exec_query_stats qs
join frequent_queries fq
    on fq.query_hash = qs.query_hash
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
where pa.attribute = 'dbid'
order by fq.executions desc,
    fq.query_hash,
    qs.execution_count desc
option (recompile)



/*High IO*/


/*Logical*/

WITH HIGH_LOGICAL_IO_QUERIES AS
(
    SELECT TOP 20 
        query_hash, 
        sum(total_logical_reads + total_logical_writes) AS [io]
		FROM sys.dm_exec_query_stats qs
    	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) 
    WHERE query_hash <> 0x0
	AND DB_NAME(dbid) LIKE '%' --Change this to the name desired database if you require database specific results
    GROUP BY query_hash
    ORDER BY [io] desc
)
select @@servername as servername,
    coalesce(db_name(st.dbid), db_name(cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    coalesce(object_name(ST.objectid, ST.dbid), '<none>') as [object_name],
    qs.query_hash,
    qs.total_logical_reads + total_logical_writes as total_io,
    qs.execution_count,
    cast((total_logical_reads + total_logical_writes) / (execution_count + 0.0) as money) as average_io,
    io as total_io_for_query,
    SUBSTRING(ST.TEXT,(QS.statement_start_offset + 2) / 2,
        (CASE 
            WHEN QS.statement_end_offset = -1  THEN LEN(CONVERT(NVARCHAR(MAX),ST.text)) * 2
            ELSE QS.statement_end_offset
            END - QS.statement_start_offset) / 2) as sql_text,
    qp.query_plan
	,qs.plan_handle
from sys.dm_exec_query_stats qs
join HIGH_LOGICAL_IO_QUERIES fq
    on fq.query_hash = qs.query_hash
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
where pa.attribute = 'dbid'
order by fq.io desc,
    fq.query_hash,
    qs.total_logical_reads + total_logical_writes desc
option (recompile)



/*Physical*/

WITH HIGH_PHYSICAL_IO_QUERIES AS
(
    SELECT TOP 20 
        query_hash, 
        total_physical_reads AS [io]
		FROM sys.dm_exec_query_stats qs
    	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) 
    WHERE query_hash <> 0x0
	AND DB_NAME(dbid) LIKE '%' --Change this to the name desired database if you require database specific results
    GROUP BY query_hash,total_physical_reads
    ORDER BY total_physical_reads desc
)
select @@servername as servername,
    coalesce(db_name(st.dbid), db_name(cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    coalesce(object_name(ST.objectid, ST.dbid), '<none>') as [object_name],
    qs.query_hash,
    qs.total_physical_reads as physical_reads,
    qs.execution_count,
    SUBSTRING(ST.TEXT,(QS.statement_start_offset + 2) / 2,
        (CASE 
            WHEN QS.statement_end_offset = -1  THEN LEN(CONVERT(NVARCHAR(MAX),ST.text)) * 2
            ELSE QS.statement_end_offset
            END - QS.statement_start_offset) / 2) as sql_text,
    qp.query_plan
	,qs.plan_handle
from sys.dm_exec_query_stats qs
join HIGH_PHYSICAL_IO_QUERIES fq
    on fq.query_hash = qs.query_hash
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
where pa.attribute = 'dbid'
order by physical_reads desc,
    fq.query_hash
option (recompile)

/*HIGH Cpu*/

;WITH HIGH_CPU_QUERIES AS
(
    SELECT TOP 20 
        query_hash, 
        sum(total_worker_time) cpuTime
    from sys.dm_exec_query_stats  qs
    	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) 
    where query_hash <> 0x0
	AND DB_NAME(dbid) LIKE '%' --Change this to the name desired database if you require database specific results
    group by query_hash
    order by sum(total_worker_time) desc
)
select @@servername as server_name,
    coalesce(db_name(st.dbid), db_name(cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    coalesce(object_name(ST.objectid, ST.dbid), '<none>') as [object_name],
    qs.query_hash,
    qs.total_worker_time as cpu_time,
    qs.execution_count,
    cast(total_worker_time / (execution_count + 0.0) as money) as average_CPU_in_microseconds,
    cpuTime as total_cpu_for_query,
    SUBSTRING(ST.TEXT,(QS.statement_start_offset + 2) / 2,
        (CASE 
            WHEN QS.statement_end_offset = -1  THEN LEN(CONVERT(NVARCHAR(MAX),ST.text)) * 2
            ELSE QS.statement_end_offset
            END - QS.statement_start_offset) / 2) as sql_text,
    qp.query_plan
	,qs.plan_handle
from sys.dm_exec_query_stats qs
join high_cpu_queries hcq
    on hcq.query_hash = qs.query_hash
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
where pa.attribute = 'dbid'
order by hcq.cpuTime desc,
    hcq.query_hash,
    qs.total_worker_time desc
option (recompile)

/*Index Scans, Heaps or Lookups*/

/*This query will indicate which databases are experiencing high Index scans
this can indicate there could be problems with some indexes or queries*/

SELECT 
	DB_NAME(database_id)
	,MAX(user_scans) bigger
	,AVG(user_scans) average
FROM sys.dm_db_index_usage_stats
GROUP BY db_name(database_id)
ORDER BY average DESC


/*
Using this query which ustilises the query plan cache you can get and indication (if avalible) of 
queries which have

No index (heap)
Index & Clustered Index Scans
Bookmark or RID Lookups
*/

SELECT TOP 20 
        st.text AS [SQLQuery] 
		,CASE 
			WHEN qp.query_plan.exist('declare namespace qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";//qplan:IndexScan[@Lookup]') = 1 THEN 'LOOKUP'
			WHEN qp.query_plan.exist('declare namespace qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //qplan:RelOp[@LogicalOp="Index Scan"]') = 1 THEN 'INDEX SCAN'
			WHEN  qp.query_plan.exist('declare namespace qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //qplan:RelOp[@LogicalOp="Clustered Index Scan"]') = 1 THEN 'CLUSTERED INDEX SCAN'
            WHEN  qp.query_plan.exist('declare namespace qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //qplan:RelOp[@LogicalOp="Table Scan"]') = 1 THEN 'TABLE/HEAP SCAN'
			ELSE 'N/A'
		END AS [PerfDegrading_LogicalOperationFound]
		,QP.Query_plan
FROM sys.dm_exec_query_stats qs
    	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
		CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
WHERE (qs.query_hash <> 0x0 AND DB_NAME(st.dbid) LIKE '%') ---Alter this to a specific database if required.
AND (qp.query_plan.exist('declare namespace 
AWMI="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
//AWMI:IndexScan[@Lookup]')=1
OR qp.query_plan.exist('declare namespace 
qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
            //qplan:RelOp[@LogicalOp="Index Scan"
            or @LogicalOp="Clustered Index Scan"
            or @LogicalOp="Table Scan"]')=1)


/*Implicit Conversions

This query will look for implicit conversion within the plan cache 
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

DECLARE @dbname SYSNAME 
SET @dbname = QUOTENAME(DB_NAME()); 

WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT 
   stmt.value('(@StatementText)[1]', 'varchar(max)'), 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)'), 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)'), 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)'), 
   ic.DATA_TYPE AS ConvertFrom, 
   ic.CHARACTER_MAXIMUM_LENGTH AS ConvertFromLength, 
   t.value('(@DataType)[1]', 'varchar(128)') AS ConvertTo, 
   t.value('(@Length)[1]', 'int') AS ConvertToLength, 
   query_plan 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t) 
JOIN INFORMATION_SCHEMA.COLUMNS AS ic 
   ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)') 
   AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)') 
   AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') 
WHERE t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1