/*MEMORY - This SQL scripts can be used to determine what is using memory on the SQL instance

Script include

Memory usage by Database
Memory usage by Database object
Page life expectancy details
System Memory details


*/



/* System Memory details  - This will indication the status of the memory on the instance*/
 

SELECT 
	total_physical_memory_kb/1024 AS Total_Physical_Memory_mb,
	available_physical_memory_kb/1024 AS available_physical_memory_mb,
	total_page_file_kb/1024 AS total_page_file_mb,
	available_page_file_kb/1024 AS available_page_file_mb,
	system_memory_state_desc 
FROM sys.dm_os_sys_memory


/*Memory usage by Database*/

DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
   FROM sys.dm_os_performance_counters 
   WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
   AND counter_name = 'Total Pages';

;WITH src AS
(
   SELECT 
       database_id, db_buffer_pages = COUNT_BIG(*)
       FROM sys.dm_os_buffer_descriptors
       --WHERE database_id BETWEEN 5 AND 32766
       GROUP BY database_id
)
SELECT
   [db_name] = CASE [database_id] WHEN 32767 
       THEN 'Resource DB' 
       ELSE DB_NAME([database_id]) END,
   db_buffer_pages,
   db_buffer_MB = db_buffer_pages / 128,
   db_buffer_percent = CONVERT(DECIMAL(6,3), 
       db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;


/*Memory usage by Database object*/

;WITH src AS
(
   SELECT
       [Object] = o.name,
       [Type] = o.type_desc,
       [Index] = COALESCE(i.name, ''),
       [Index_Type] = i.type_desc,
       p.[object_id],
       p.index_id,
       au.allocation_unit_id
   FROM
       sys.partitions AS p
   INNER JOIN
       sys.allocation_units AS au
       ON p.hobt_id = au.container_id
   INNER JOIN
       sys.objects AS o
       ON p.[object_id] = o.[object_id]
   INNER JOIN
       sys.indexes AS i
       ON o.[object_id] = i.[object_id]
       AND p.index_id = i.index_id
   WHERE
       au.[type] IN (1,2,3)
       AND o.is_ms_shipped = 0
)
SELECT
   src.[Object],
   src.[Type],
   src.[Index],
   src.Index_Type,
   buffer_pages = COUNT_BIG(b.page_id),
   buffer_mb = COUNT_BIG(b.page_id) / 128
FROM
   src
INNER JOIN
   sys.dm_os_buffer_descriptors AS b
   ON src.allocation_unit_id = b.allocation_unit_id
WHERE
   b.database_id = DB_ID()
GROUP BY
   src.[Object],
   src.[Type],
   src.[Index],
   src.Index_Type
ORDER BY
   buffer_pages DESC;


/*Page free space in Memory*/
SELECT COUNT(*)AS cached_pages_count 
    ,name AS [Object] 
	,index_id
	,CAST(COUNT(*)*8. /1024. AS NUMERIC(10,1)) AS [Cached_MB]
	,CAST(100. * SUM(free_space_in_bytes)/1024./1024. / (COUNT(*)*8./1024.) AS NUMERIC(3,1)) AS [Free_Space_%]
	,SUM(Row_count) AS Total_Rows
	,CAST(SUM(Row_count)/(1.*COUNT(*)) AS NUMERIC(10,1)) AS Avg_rows_per_Page
FROM sys.dm_os_buffer_descriptors AS bd 
    INNER JOIN 
    (
        SELECT object_name(object_id) AS name 
            ,index_id ,allocation_unit_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT object_name(object_id) AS name   
            ,index_id, allocation_unit_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.partition_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = DB_ID()
GROUP BY name, index_id WITH ROLLUP
ORDER BY cached_pages_count DESC;


/*Page life expectancy - This is good to see memory pressure is happening, the expectation is for more that 300s
before the data is flushed from the memory cache
*/

SELECT  @@servername AS INSTANCE
,[object_name]
,[counter_name]
, UPTIME_MIN = CASE WHEN[counter_name]= 'Page life expectancy'
          THEN (SELECT DATEDIFF(MI, MAX(login_time),GETDATE())
          FROM   master.sys.sysprocesses
          WHERE  cmd='LAZY WRITER')
      ELSE ''
END
, [cntr_value] AS PLE_SECS
,[cntr_value]/ 60 AS PLE_MINS
,[cntr_value]/ 3600 AS PLE_HOURS
,[cntr_value]/ 86400 AS PLE_DAYS
FROM  sys.dm_os_performance_counters
WHERE   [object_name] LIKE '%Manager%'
          AND[counter_name] = 'Page life expectancy'