/* This set of SQL Scripts can be used to investigate Indexes on a database

Scripts Included:

Index details - This SQL will show what indexes are on tables in a given database, this will show you what columns are used in that database
Usage Stats - Check if the Index is actually being used.
Index fragmentation - Looks for fragmention on the indexes
Unused indexes - This script finds any unused indexes which could be causing perfornance problems
Missing Indexes -  This Script finds the top 25 missing indexes on an database
Find Plans with Missing Indexes - This script will look into the Cached plans and find suggested missing indexes
Duplicate indexes - This script will find duplicated indexes
Tables without Clusted indexes - This two scripts show both active and noactive tables which don't have clusted indexes avalaible.
Statistics update - This shows when the last time when stats were last updated.

*/

/*
Indexes Details
*/
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.index_column_id 

/*Index Usage*/ 

SELECT 
	OBJECT_NAME(ddius.[object_id],ddius.database_id) AS Objectname,
	ddius.index_id ,
	si.name,        
	ddius.user_seeks ,         
	ddius.user_scans ,         
	ddius.user_lookups ,         
	ddius.user_seeks + ddius.user_scans + ddius.user_lookups  AS user_reads ,         
	ddius.user_updates AS user_writes ,         
	ddius.last_user_scan ,         
	ddius.last_user_update,
	CASE WHEN si.is_disabled = 1 THEN 'Y' ELSE 'N' END [Disabled]
FROM    
		sys.dm_db_index_usage_stats ddius 
		INNER JOIN sys.indexes si
			ON (ddius.index_id = si.index_id and ddius.object_id = si.object_id)
WHERE   
	ddius.database_id > 4 -- filter out system tables         
	AND OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1         
	AND ddius.index_id > 0  -- filter out heaps 
ORDER BY ddius.user_scans DESC


/*Index fragmentation*/

/*Remember to alter limited to detailed or sampled as required*/
SELECT 
	DB_NAME(db_id()) [Database]
	,OBJECT_NAME(ddips.[object_id]) [Object]
	,i.[name] AS [index_name]
	,ddips.[index_type_desc]
	,ddips.[partition_number]
	,ddips.[alloc_unit_type_desc]
	,ddips.[index_depth]
	,ddips.[index_level]
	,CAST(ddips.[avg_fragmentation_in_percent] AS SMALLINT) AS [avg_frag_%]
	,CAST(ddips.[avg_fragment_size_in_pages] AS SMALLINT) AS [avg_frag_size_in_pages]
	,ddips.[fragment_count]
	,ddips.[page_count]
	,'ALTER INDEX '+ISNULL(i.[name],'ALL')+' ON '+OBJECT_NAME(ddips.[object_id])+' REBUILD;' AS [RebuildStatement]
FROM 
	sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'limited') ddips 
	INNER JOIN sys.[indexes] i 
		ON ddips.[object_id] = i.[object_id]
		AND ddips.[index_id] = i.[index_id] 
WHERE
	ddips.index_type_desc != 'HEAP' 
	AND (ddips.[avg_fragmentation_in_percent] > 10
	AND ddips.[page_count] > 500)
ORDER BY ddips.[avg_fragmentation_in_percent],
OBJECT_NAME(ddips.[object_id], DB_ID()) ,
i.[name]



/*Unsued Indexes*/

SELECT 
DB_NAME(dm_ius.database_id) [DbName]
,o.name AS ObjectName
, i.name AS IndexName
, i.index_id AS IndexID  
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
, p.TableRows
, 'DROP INDEX ' + QUOTENAME(i.name) 
+ ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.object_id)) as 'Drop statement'
FROM sys.dm_db_index_usage_stats dm_ius  
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.object_id = i.object_id   
INNER JOIN sys.objects o on dm_ius.object_id = o.object_id
INNER JOIN sys.schemas s on o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.object_id 
				FROM sys.partitions p GROUP BY p.index_id, p.object_id) p 
		ON p.index_id = dm_ius.index_id AND dm_ius.object_id = p.object_id
WHERE OBJECTPROPERTY(dm_ius.object_id,'IsUserTable') = 1
AND dm_ius.database_id = DB_ID()   
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC
GO


/*Missing Indexes*/

/*
******Please note before applying any of these onto production or test check they don't already exist*****
*/


SELECT TOP 25
dm_mid.database_id AS DatabaseID, 
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
object_name(dm_mid.object_id,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + object_name(dm_mid.object_id,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') +
CASE
	WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN '_'
	ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY Avg_Estimated_Impact DESC 
GO


/*Find Plans with Missing Indexes*/

;WITH XMLNAMESPACES(DEFAULT
N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT dec.usecounts, dec.refcounts, dec.objtype
, dec.cacheobjtype, des.dbid, des.text,deq.query_plan
FROM sys.dm_exec_cached_plans AS dec
CROSS APPLY sys.dm_exec_sql_text(dec.plan_handle) AS des
CROSS APPLY sys.dm_exec_query_plan(dec.plan_handle) AS deq
WHERE
deq.query_plan.exist
(N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple
/QueryPlan/MissingIndexes/MissingIndexGroup') <> 0
ORDER BY dec.usecounts DESC


/*Duplicate indexes*/

WITH MyDuplicate AS (SELECT 
	Sch.[name] AS SchemaName,
	Obj.[name] AS TableName,
	Idx.[name] AS IndexName,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 1) AS Col1,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 2) AS Col2,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 3) AS Col3,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 4) AS Col4,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 5) AS Col5,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 6) AS Col6,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 7) AS Col7,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 8) AS Col8,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 9) AS Col9,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 10) AS Col10,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 11) AS Col11,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 12) AS Col12,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 13) AS Col13,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 14) AS Col14,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 15) AS Col15,
	INDEX_Col(Sch.[name] + '.' + Obj.[name], Idx.index_id, 16) AS Col16
FROM sys.indexes Idx
INNER JOIN sys.objects Obj ON Idx.[object_id] = Obj.[object_id]
INNER JOIN sys.schemas Sch ON Sch.[schema_id] = Obj.[schema_id]
WHERE index_id > 0)
SELECT	MD1.SchemaName, MD1.TableName, MD1.IndexName, 
		MD2.IndexName AS OverLappingIndex,
		MD1.Col1, MD1.Col2, MD1.Col3, MD1.Col4, 
		MD1.Col5, MD1.Col6, MD1.Col7, MD1.Col8, 
		MD1.Col9, MD1.Col10, MD1.Col11, MD1.Col12, 
		MD1.Col13, MD1.Col14, MD1.Col15, MD1.Col16
FROM MyDuplicate MD1
INNER JOIN MyDuplicate MD2 ON MD1.tablename = MD2.tablename
	AND MD1.indexname <> MD2.indexname
	AND MD1.Col1 = MD2.Col1
	AND (MD1.Col2 IS NULL OR MD2.Col2 IS NULL OR MD1.Col2 = MD2.Col2)
	AND (MD1.Col3 IS NULL OR MD2.Col3 IS NULL OR MD1.Col3 = MD2.Col3)
	AND (MD1.Col4 IS NULL OR MD2.Col4 IS NULL OR MD1.Col4 = MD2.Col4)
	AND (MD1.Col5 IS NULL OR MD2.Col5 IS NULL OR MD1.Col5 = MD2.Col5)
	AND (MD1.Col6 IS NULL OR MD2.Col6 IS NULL OR MD1.Col6 = MD2.Col6)
	AND (MD1.Col7 IS NULL OR MD2.Col7 IS NULL OR MD1.Col7 = MD2.Col7)
	AND (MD1.Col8 IS NULL OR MD2.Col8 IS NULL OR MD1.Col8 = MD2.Col8)
	AND (MD1.Col9 IS NULL OR MD2.Col9 IS NULL OR MD1.Col9 = MD2.Col9)
	AND (MD1.Col10 IS NULL OR MD2.Col10 IS NULL OR MD1.Col10 = MD2.Col10)
	AND (MD1.Col11 IS NULL OR MD2.Col11 IS NULL OR MD1.Col11 = MD2.Col11)
	AND (MD1.Col12 IS NULL OR MD2.Col12 IS NULL OR MD1.Col12 = MD2.Col12)
	AND (MD1.Col13 IS NULL OR MD2.Col13 IS NULL OR MD1.Col13 = MD2.Col13)
	AND (MD1.Col14 IS NULL OR MD2.Col14 IS NULL OR MD1.Col14 = MD2.Col14)
	AND (MD1.Col15 IS NULL OR MD2.Col15 IS NULL OR MD1.Col15 = MD2.Col15)
	AND (MD1.Col16 IS NULL OR MD2.Col16 IS NULL OR MD1.Col16 = MD2.Col16)
ORDER BY
	MD1.SchemaName,MD1.TableName,MD1.IndexName


/*Tables without Clustered indexes */

/*Database heaps - tables without a clustered index - Actively being queries*/


SELECT DISTINCT ius.user_seeks
	,ius.user_scans
	,ius.user_lookups
	,ius.user_updates
	,OBJECT_NAME(o.object_id)
FROM sys.indexes i
INNER JOIN sys.objects o ON i.object_id = o.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id
	AND i.index_id = p.index_id
INNER JOIN sys.databases sd ON sd.NAME = DB_NAME()
LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id
	AND i.index_id = ius.index_id
	AND ius.database_id = sd.database_id
WHERE i.type_desc = 'HEAP'
	AND COALESCE(ius.user_seeks, ius.user_scans, ius.user_lookups, ius.user_updates) IS NOT NULL
	AND sd.NAME <> 'tempdb'
	AND o.is_ms_shipped = 0
	AND o.type <> 'S'


/*Database heaps - tables without a clustered index - Not actively being queried, could be staging for no longer requrie tables*/

SELECT DISTINCT ius.user_seeks
	,ius.user_scans
	,ius.user_lookups
	,ius.user_updates OBJECT_NAME(o.object_id)
FROM.sys.indexes i
INNER JOIN sys.objects o ON i.object_id = o.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id
	AND i.index_id = p.index_id
INNER JOIN sys.databases sd ON sd.NAME = db_Name()
LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id
	AND i.index_id = ius.index_id
	AND ius.database_id = sd.database_id
WHERE i.type_desc = 'HEAP'
	AND COALESCE(ius.user_seeks, ius.user_scans, ius.user_lookups, ius.user_updates) IS NULL
	AND sd.NAME <> 'tempdb'
	AND o.is_ms_shipped = 0
	AND o.type <> 'S'


/*Statistics Updated*/

SELECT 
	OBJECT_NAME(OBJECT_ID) [TableName],
	Name AS [IndexName],
	STATS_DATE(OBJECT_ID, index_id) AS StatsUpdated
FROM 
	sys.indexes
ORDER BY 
	STATS_DATE(OBJECT_ID, index_id) DESC