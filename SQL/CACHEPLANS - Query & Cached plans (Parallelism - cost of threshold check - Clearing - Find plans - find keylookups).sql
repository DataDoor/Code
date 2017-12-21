/*

THE BELOW SET OF SQL CAN BE USED TO: 

INVESTIGATE
USAGE
PARALLELISM (Good for setting cost threshold for parrallelism)
CLEAR

QUERY PLANS ON ANY GIVEN SQL SERVER INSTANCE

*/


/*INVESTIGATE QUERY PLANS*/

/*CACHED QUERY PLANS*/

SELECT 
	[cp].[refcounts] ,
	[cp].[usecounts] ,
	[cp].[objtype] ,
	[st].[dbid] ,
	[st].[objectid] ,
	[st].[text] ,
	[qp].[query_plan]
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE [st].[text] LIKE N'%SearchType_RowNum%';

/*FULL - PLAN DETAILS*/

SELECT  
	deqp.dbid ,         
	deqp.objectid ,         
	CAST(detqp.query_plan AS XML) AS singleStatementPlan ,         
	deqp.query_plan AS batch_query_plan ,         --this won't actually work in all cases because nominal plans aren't         -- cached, so you won't see a plan for waitfor if you uncomment it         
	ROW_NUMBER() OVER ( ORDER BY Statement_Start_offset )AS query_position ,         
	CASE WHEN deqs.statement_start_offset = 0 AND deqs.statement_end_offset = -1 THEN '-- see objectText column--'              
	ELSE '-- query --' + CHAR(13) + CHAR(10)+ SUBSTRING(execText.text, deqs.statement_start_offset / 2, 
	( ( CASE WHEN deqs.statement_end_offset = -1 THEN DATALENGTH(execText.text) ELSE deqs.statement_end_offset END ) - deqs.statement_start_offset ) / 2) END AS queryText 
FROM    
	sys.dm_exec_query_stats deqs         
	CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle,  deqs.statement_start_offset, deqs.statement_end_offset) AS detqp         
	CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp         
	CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText 
--WHERE   deqp.objectid = OBJECT_ID('ShowQueryText', 'p') ;


/*FIND CACHE PLANS WITH KEY LOOKUPS*/

;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

SELECT *
FROM
(
SELECT
	query_plan AS QueryPlan
	,qt.text
	--,operators.value('@PhysicalOp','nvarchar(50)') AS PhysicalOperator 
   ,operators.value('@LogicalOp','nvarchar(50)') AS LogicalOp 
   -- ,operators.value('@AvgRowSize','nvarchar(50)') AS AvgRowSize 
   -- ,operators.value('@EstimateCPU','nvarchar(50)') AS EstimateCPU
   -- ,operators.value('@EstimateIO','nvarchar(50)') AS EstimateIO 
   -- ,operators.value('@EstimateRebinds','nvarchar(50)') AS EstimateRebinds
   -- ,operators.value('@EstimateRewinds','nvarchar(50)') AS EstimateRewinds
   -- ,operators.value('@EstimateRows','nvarchar(50)') AS EstimateRows
   -- ,operators.value('@Parallel','nvarchar(50)') AS Parallel 
   --,operators.value('@NodeId','nvarchar(50)') AS NodeId
   -- ,operators.value('@EstimatedTotalSubtreeCost','nvarchar(50)') AS EstimatedTotalSubtreeCost
	,qt.dbid
FROM sys.dm_exec_query_stats cp
CROSS APPLY sys.dm_exec_sql_text(sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY query_plan.nodes('//RelOp') rel(operators)
) [CachePlan]
WHERE 
	dbid = DB_ID() --Remember this will limit the results to the currect select database
	 AND (LogicalOp = 'Table Scan'
	OR LogicalOp = 'Index Scan'
	OR LogicalOp = 'Clustered Index Scan'
	OR LogicalOp LIKE '%Lookup%')



/*USAGE OF PLANS DETAILS*/


/*CACHED PLANS USAGE*/

SELECT 
	refcounts, 
	usecounts ,         
	size_in_bytes ,         
	cacheobjtype ,         
	objtype 
FROM    
	sys.dm_exec_cached_plans 
WHERE   
	objtype IN ( 'proc', 'prepared' ) ;
	


/*MOST REUSED PLANS*/

SELECT TOP 2 WITH TIES 
	decp.usecounts ,         
	decp.cacheobjtype ,         
	decp.objtype ,         
	deqp.query_plan ,         
	dest.text 
FROM    
	sys.dm_exec_cached_plans decp         
	CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp         
	CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest 
ORDER BY 
	usecounts DESC
	
	
/*TOP SINGLE USED PLANS*/

SELECT TOP 100
	[text] ,         
	cp.size_in_bytes 
FROM    
	sys.dm_exec_cached_plans AS cp         
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE   
	cp.cacheobjtype = 'Compiled Plan'         
	AND cp.objtype = 'Adhoc'         
	AND cp.usecounts = 1 
ORDER BY cp.size_in_bytes DESC ;



/*CACHED PLANS WHICH HAVE ONLY BEEN USED ONCE*/

SELECT TEXT
	,cp.objtype
	,cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = N'Compiled Plan'
	AND cp.objtype IN (N'Adhoc',N'Prepared')
	AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC
OPTION (RECOMPILE);

/*TOTAL AMOUNT OF CACHE BEING USED BY PLANS*/

SELECT objtype AS [CacheType]
        , count_big(*) AS [Total Plans]
        , sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [Total MBs]
        , avg(usecounts) AS [Avg Use Count]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [Total MBs - USE Count 1]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC
GO

/*PARALLELISM*/

/*This shows plans where the query has gone parallel*/
 
SELECT p.dbid
	,p.objectid
	,p.query_plan
	,q.encrypted
	,q.TEXT
	,cp.usecounts
	,cp.size_in_bytes
	,cp.plan_handle
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS p
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS q
WHERE cp.cacheobjtype = 'Compiled Plan'
	AND p.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan"; max(//p:RelOp/@Parallel)', 'float') > 0


/*This shows where the amount of time spent by the workers are more than the query execution time which is a sign of parrallelism*/

SELECT qs.sql_handle
	,qs.statement_start_offset
	,qs.statement_end_offset
	,q.dbid
	,q.objectid
	,q.number
	,q.encrypted
	,q.TEXT
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS q
WHERE qs.total_worker_time > qs.total_elapsed_time


/*COST THRESHOLD  FOR PARALLELISM

This query is good for checking what plan on your system are parallelizing and can be used
to ensure the cost threshold for parallelsm is set adequately

*/

USE master;
GO
-- Create table
IF NOT EXISTS ( SELECT  1
                FROM    sys.objects
                WHERE   [object_id] = OBJECT_ID('dbo.PlanCacheForMaxDop')
                        AND [type] = 'U' )
    CREATE TABLE master.dbo.PlanCacheForMaxDop
        (
          CompleteQueryPlan XML ,
          StatementText VARCHAR(4000) ,
          StatementOptimizationLevel VARCHAR(25) ,
          StatementSubTreeCost FLOAT ,
          ParallelSubTreeXML XML ,
          UseCounts INT ,
          PlanSizeInBytes INT
        );
ELSE
      -- If table exists truncate it before population
    TRUNCATE TABLE  master.dbo.PlanCacheForMaxDop;     
GO   

-- Collect parallel plan information
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES  
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
INSERT INTO master.dbo.PlanCacheForMaxDop
SELECT 
     query_plan AS CompleteQueryPlan,
     n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText,
     n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS StatementOptimizationLevel,
     n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost,
     n.query('.') AS ParallelSubTreeXML, 
     ecp.usecounts,
     ecp.size_in_bytes 
FROM sys.dm_exec_cached_plans AS ecp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n)
WHERE  n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1;
GO

-- Return parallel plan information
SELECT  CompleteQueryPlan ,
        StatementText ,
        StatementOptimizationLevel ,
        StatementSubTreeCost ,
        ParallelSubTreeXML ,
        UseCounts ,
        PlanSizeInBytes
FROM    master.dbo.PlanCacheForMaxDop;
GO

-- Return grouped parallel plan information
SELECT  MAX(CASE WHEN StatementSubTreeCost BETWEEN 1 AND 5 THEN '1-5'
                 WHEN StatementSubTreeCost BETWEEN 5 AND 6 THEN '5-6'
                 WHEN StatementSubTreeCost BETWEEN 6 AND 7 THEN '6-7'
                 WHEN StatementSubTreeCost BETWEEN 7 AND 8 THEN '7-8'
                 WHEN StatementSubTreeCost BETWEEN 8 AND 9 THEN '8-9'
                 WHEN StatementSubTreeCost BETWEEN 9 AND 10 THEN '9-10'
                 WHEN StatementSubTreeCost BETWEEN 10 AND 11 THEN '10-11'
                 WHEN StatementSubTreeCost BETWEEN 11 AND 12 THEN '11-12'
                 WHEN StatementSubTreeCost BETWEEN 12 AND 13 THEN '12-13'
                 WHEN StatementSubTreeCost BETWEEN 13 AND 14 THEN '13-14'
                 WHEN StatementSubTreeCost BETWEEN 14 AND 15 THEN '14-15'
                 WHEN StatementSubTreeCost BETWEEN 15 AND 16 THEN '15-16'
                 WHEN StatementSubTreeCost BETWEEN 16 AND 17 THEN '16-17'
                 WHEN StatementSubTreeCost BETWEEN 17 AND 18 THEN '17-18'
                 WHEN StatementSubTreeCost BETWEEN 18 AND 19 THEN '18-19'
                 WHEN StatementSubTreeCost BETWEEN 19 AND 20 THEN '19-20'
                 WHEN StatementSubTreeCost BETWEEN 20 AND 25 THEN '20-25'
                 WHEN StatementSubTreeCost BETWEEN 25 AND 30 THEN '25-30'
                 WHEN StatementSubTreeCost BETWEEN 30 AND 35 THEN '30-35'
                 WHEN StatementSubTreeCost BETWEEN 35 AND 40 THEN '35-40'
                 WHEN StatementSubTreeCost BETWEEN 40 AND 45 THEN '40-45'
                 WHEN StatementSubTreeCost BETWEEN 45 AND 50 THEN '45-50'
                 WHEN StatementSubTreeCost > 50 THEN '>50'
                 ELSE CAST(StatementSubTreeCost AS VARCHAR(100))
            END) AS StatementSubTreeCost ,
        COUNT(*) AS countInstance
FROM    master.dbo.PlanCacheForMaxDop
GROUP BY CASE WHEN StatementSubTreeCost BETWEEN 1 AND 5 THEN 2.5
              WHEN StatementSubTreeCost BETWEEN 5 AND 6 THEN 5.5
              WHEN StatementSubTreeCost BETWEEN 6 AND 7 THEN 6.5
              WHEN StatementSubTreeCost BETWEEN 7 AND 8 THEN 7.5
              WHEN StatementSubTreeCost BETWEEN 8 AND 9 THEN 8.5
              WHEN StatementSubTreeCost BETWEEN 9 AND 10 THEN 9.5
              WHEN StatementSubTreeCost BETWEEN 10 AND 11 THEN 10.5
              WHEN StatementSubTreeCost BETWEEN 11 AND 12 THEN 11.5
              WHEN StatementSubTreeCost BETWEEN 12 AND 13 THEN 12.5
              WHEN StatementSubTreeCost BETWEEN 13 AND 14 THEN 13.5
              WHEN StatementSubTreeCost BETWEEN 14 AND 15 THEN 14.5
              WHEN StatementSubTreeCost BETWEEN 15 AND 16 THEN 15.5
              WHEN StatementSubTreeCost BETWEEN 16 AND 17 THEN 16.5
              WHEN StatementSubTreeCost BETWEEN 17 AND 18 THEN 17.5
              WHEN StatementSubTreeCost BETWEEN 18 AND 19 THEN 18.5
              WHEN StatementSubTreeCost BETWEEN 19 AND 20 THEN 19.5
              WHEN StatementSubTreeCost BETWEEN 10 AND 15 THEN 12.5
              WHEN StatementSubTreeCost BETWEEN 15 AND 20 THEN 17.5
              WHEN StatementSubTreeCost BETWEEN 20 AND 25 THEN 22.5
              WHEN StatementSubTreeCost BETWEEN 25 AND 30 THEN 27.5
              WHEN StatementSubTreeCost BETWEEN 30 AND 35 THEN 32.5
              WHEN StatementSubTreeCost BETWEEN 35 AND 40 THEN 37.5
              WHEN StatementSubTreeCost BETWEEN 40 AND 45 THEN 42.5
              WHEN StatementSubTreeCost BETWEEN 45 AND 50 THEN 47.5
              WHEN StatementSubTreeCost > 50 THEN 100
              ELSE StatementSubTreeCost
         END;
GO




/*CLEARING OF PLANS*/

/*Remove all plan cache for the entire instance */

DBCC FREEPROCCACHE;

/* Flush the cache and suppress the regular completion message DBCC execution completed. If DBCC printed error messages, contact your system administrator." */

DBCC FREEPROCCACHE WITH NO_INFOMSGS;


/*  Remove all  plan cache for one database  
 Get DBID from one database name first*/

DECLARE @intDBID INT;
SET @intDBID = (SELECT [dbid] 
                FROM master.dbo.sysdatabases 
                WHERE name = 'AdventureWorks');

-- Flush the procedure cache for one database only
DBCC FLUSHPROCINDB (@intDBID);



 /*Remove one plan from the cache,  Get the plan handle for a cached plan*/
SELECT cp.plan_handle, st.[text]
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE [text] LIKE N'%/* GetOnlineSearchResultsMonday %';

/* Remove the specific plan from the cache using the plan handle*/
DBCC FREEPROCCACHE (0x05000800F7BA926C40C15055070000000000000000000000);



/*Clearing *JUST* the 'SQL Plans' based on *just* the amount of Adhoc/Prepared single-use plans (2005/2008):*/

DECLARE @MB decimal(19,3)
        , @Count bigint
        , @StrMB nvarchar(20)


SELECT @MB = sum(cast((CASE WHEN usecounts = 1 AND objtype IN ('Adhoc', 'Prepared') THEN size_in_bytes ELSE 0 END) as decimal(12,2)))/1024/1024 
        , @Count = sum(CASE WHEN usecounts = 1 AND objtype IN ('Adhoc', 'Prepared') THEN 1 ELSE 0 END)
        , @StrMB = convert(nvarchar(20), @MB)
FROM sys.dm_exec_cached_plans


IF @MB > 10
        BEGIN
                DBCC FREESYSTEMCACHE('SQL Plans') 
                RAISERROR ('%s MB was allocated to single-use plan cache. Single-use plans have been cleared.', 10, 1, @StrMB)
        END
ELSE
        BEGIN
                RAISERROR ('Only %s MB is allocated to single-use plan cache – no need to clear cache now.', 10, 1, @StrMB)
                – Note: this is only a warning message and not an actual error.
        END
go


/*Clearing *ALL* of your cache based on the total amount of wasted by single-use plans (2005/2008):*/

DECLARE @MB decimal(19,3)
        , @Count bigint
        , @StrMB nvarchar(20)


SELECT @MB = sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(12,2)))/1024/1024 
        , @Count = sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END)
        , @StrMB = convert(nvarchar(20), @MB)
FROM sys.dm_exec_cached_plans

IF @MB > 1000
        DBCC FREEPROCCACHE
ELSE
        RAISERROR ('Only %s MB is allocated to single-use plan cache – no need to clear cache now.', 10, 1, @StrMB)
GO


/*This query finds cached plans which have been created more than once, this could be due to queries where 
predicates have different values being passed.*/

SELECT COUNT(*) AS [Count]
	,query_stats.query_hash
	,query_stats.statement_text AS [Text]
FROM (
	SELECT QS.*
		,SUBSTRING(ST.TEXT, (QS.statement_start_offset / 2) + 1, (
				(
					CASE statement_end_offset
						WHEN - 1
							THEN DATALENGTH(ST.TEXT)
						ELSE QS.statement_end_offset
						END - QS.statement_start_offset
					) / 2
				) + 1) AS statement_text
	FROM sys.dm_exec_query_stats AS QS
	CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST
	) AS query_stats
GROUP BY query_stats.query_hash
	,query_stats.statement_text
ORDER BY 1 DESC

 


