/*DATABASE DETAILS - These scripts show details of the database, schema and how to remove database files with percentage growth

This file includes scripts for:

Database size
Database file locations
Schema Details
Tables
Full Table information
Tables - Constraints - PK's, FK's, Unique
Referential constraints Fk's
Stored Procedures 
Functions
Triggers
Indexes
Row Count Information 
REMOVE PERCENTAGE GROWTH
Columns with different columns datatypes or sizes

*/



/*Database size -  KB,MB,GB*/

SELECT 
	D.name [DatabaseName]
	,df.name [Filename]
	,CASE WHEN df.type = 0 THEN 'Data' ELSE 'LOG' END [FileType]	
	,SUM((size*8)) TotalSizeKB
	,SUM((size*8)/1024) TotalSizeMB
    ,SUM((size*8)/1024/1024) TotalSizeGB
FROM 
	Sys.databases D
INNER JOIN sys.master_files df
ON D.Database_ID = df.Database_ID  
WHERE D.database_id > 4
GROUP BY D.name, df.type, df.name

/* Database files location details*/
	
SELECT
	D.name [DatabaseName],
	CASE WHEN d.Database_id <= 4 THEN 'SYSTEM' ELSE 'USER' END [Type],
	Recovery_model_desc [RecoveryModel],
	Collation_name [Collation], 
	Compatibility_Level [CompatabilityLevel],
	df.Name [DataFileName],
	df.Physical_name [DataFileLocation],
	df.Size [DataFileSize],
	df.Growth [DataFileGrowth],
	dl.Name [LogFileName],
	dl.Physical_name [LogFileLocation],
	dl.Size [LogFileSize],
	dl.Growth [LogFileGrowth]
FROM 
	Sys.databases D
INNER JOIN
	(
	SELECT *
	FROM sys.master_files 
	WHERE 
		Type = 0
	) DF ON D.Database_ID = DF.Database_ID  
INNER JOIN
	(
	SELECT *
	FROM sys.master_files 
	WHERE 
		Type = 1
	) DL ON D.Database_ID = Dl.Database_ID


/*Schema Details*/ 


/*Table size*/

SELECT 
    t.NAME AS TableName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    (SUM(a.total_pages) * 8)/1024 AS TotalSpaceUsedMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
/*Uncommented if needed*/    
--    AND t.NAME LIKE '%Staging%' 
GROUP BY 
    t.Name, p.Rows
ORDER BY 
    t.Name

/*Full Table information */

SET NOCOUNT ON

SELECT 
    a.Table_Schema+'.'+a.Table_Name [Table Name],
    b.Column_Name [Column Name],  
    b.Data_type [Data Type],
    b.Character_Maximum_Length [Character length],
    b.is_nullable [Is Nullable],
    b.Column_Default
FROM 
    INFORMATION_SCHEMA.Tables a 
	INNER JOIN INFORMATION_SCHEMA.Columns b ON (a.Table_Name = b.Table_Name)
	LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c ON (a.Table_Name = c.Table_Name 
																AND b.Column_Name = c.Column_Name    
																AND c.Constraint_Name not like 'repl_identity_%')
WHERE	
    a.Table_Type = 'Base Table'
ORDER BY
    a.Table_Name,
    b.Ordinal_Position


/*Tables - Constraints - PK's, FK's, Unique*/

SELECT 
    a.Table_Name [Table],
    a.Column_Name [Column],
    b.Constraint_Name [Constraint Name],
    c.Constraint_Type [Constraint Type]
    
FROM 
    INFORMATION_SCHEMA.COLUMNS a
	INNER JOIN  INFORMATION_SCHEMA.KEY_COLUMN_USAGE b ON (a.TABLE_NAME = b.TABLE_NAME AND a.Ordinal_Position = b.Ordinal_Position)
	INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS c ON (b.Constraint_name = c.Constraint_Name)
ORDER BY    
    a.Table_Name,
    a.Column_Name,
    b.Constraint_Name,
    c.Constraint_Type

        
/* Referential constraints Fk's*/

SET NOCOUNT ON

SELECT 
    a.Table_Name [ForeignKey Table],
    a.Column_Name [Foreign Key Column],
    a.Constraint_Name [Foreign Key Constraint Name],
    c.Table_Name [Foreign Key Referanced Table],
    c.Column_Name [Foreign Key Referanced Column]
FROM
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE a 
    INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS b ON (a.Constraint_Name = b.Constraint_Name)
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c ON (b.Unique_Constraint_Name = c.Constraint_Name)


/*View Information*/
SET NOCOUNT ON

SELECT 
    View_Schema+'.'+View_Name [View Name], 
    a.Table_Name [Tables Included], 
    Column_Name [Columns Included] 
FROM 
    INFORMATION_SCHEMA.VIEW_COLUMN_USAGE a
	INNER JOIN INFORMATION_SCHEMA.Tables b ON (a.Table_Name = b.Table_Name)
GROUP BY
    View_Schema,View_Name, 
    a.Table_Name, 
    Column_Name 

/*Stored Procedures */
SET NOCOUNT ON

SELECT 
    Name [Stored Procedure Name] 
FROM 
    sysobjects 
WHERE 
    Type = 'P'


/*Functions*/
SET NOCOUNT ON

SELECT 
    Name 
FROM 
    Sysobjects 
WHERE 
    Type = 'FN'

/*Triggers*/

SET NOCOUNT ON

SELECT 
    a.Name [TriggerName],
    b.Name [Associated Table]
FROM 
    Sysobjects a 
	INNER JOIN sysobjects b ON (a.Parent_obj = b.id) 
WHERE 
    a.Type = 'TR'


/*Indexes*/

SET NOCOUNT ON

SELECT 
    a.name [Table],
    b.name [Index Column],
    d.name [Index Name],
    case when 
		d.indid = 1 Then 
				'Clustered' 
				else 
				'NON - Clustered' 
	  end [Index Type]
FROM 
    sysobjects a
	INNER JOIN syscolumns b ON (a.id = b.id)
	INNER JOIN sysindexkeys c ON (a.id = c.id AND b.colid = c.colid)
	INNER JOIN sysindexes d ON (a.id = d.id AND c.indid = d.indid)
WHERE 
    a.type = 'u'
ORDER BY
    [Table],
    [Index Type]

/*Row Count Information */

SELECT 
    Table_Schema+'.'+OBJECT_NAME(id),
    rowcnt
FROM 
    SYSINDEXES A
	INNER JOIN Information_Schema.Tables B ON (object_name(a.id) = b.Table_Name)
WHERE 
    OBJECTPROPERTY(id,'isUserTable')=1 
	AND indid < 2
ORDER BY 
    rowcnt desc




/*REMOVE PERCENTAGE GROWTH*/

--DECLARE @SQLGrowth NVARCHAR(MAX);




--WITH [FileSizeChk] AS
--(
--	SELECT 
--		database_id, 
--		DB_NAME(database_id) AS DatabaseName,
--		Name AS Logical_Name,
--		Physical_Name, 
--		(SUM(Size) OVER (PARTITION BY database_id )*8)/1024 SizeMB,
--		growth,
--		is_percent_growth,
--		type_desc
--	FROM sys.master_files
--	WHERE 
--		database_id > 4
--		AND type_desc != 'FULLTEXT'
--      AND is_percent_growth = 1 
--) 


SELECT 
'ALTER DATABASE '+DatabaseName+' MODIFY FILE (NAME = '+ QUOTENAME(Logical_Name)+',  FILEGROWTH = '+
CASE 
	WHEN [FileCheck].type_desc = 'Rows' AND [FileCheck].Sizemb <= 150 THEN '50 MB'
	WHEN [FileCheck].type_desc = 'Rows' AND [FileCheck].Sizemb BETWEEN 151 AND 512 THEN '150 MB'
	WHEN [FileCheck].type_desc = 'Rows' AND [FileCheck].Sizemb BETWEEN 512 AND 10240 THEN '250 MB'
	WHEN [FileCheck].type_desc = 'Rows' AND [FileCheck].Sizemb BETWEEN 10241 AND 40960 THEN '512 MB'
	WHEN [FileCheck].type_desc = 'Rows' AND [FileCheck].Sizemb > 40961 THEN '1024 MB' 
	WHEN [FileCheck].type_desc = 'Log' AND  [FileCheck].Sizemb <= 150 THEN '10MB'
	WHEN [FileCheck].type_desc = 'Log' AND  [FileCheck].Sizemb BETWEEN 151 AND 512 THEN  '10MB'
	WHEN [FileCheck].type_desc = 'Log' AND  [FileCheck].Sizemb BETWEEN 512 AND 10240 THEN  '50MB'
	WHEN [FileCheck].type_desc = 'Log' AND [FileCheck].Sizemb BETWEEN 10241 AND 40960 THEN  '150MB'
	WHEN [FileCheck].type_desc = 'Log' AND  [FileCheck].Sizemb > 40961 THEN '250MB'
END +
');'
FROM 
		(SELECT 
		database_id, 
		DB_NAME(database_id) AS DatabaseName,
		Name AS Logical_Name,
		Physical_Name, 
		(SUM(Size) OVER (PARTITION BY database_id )*8)/1024 SizeMB,
		growth,
		is_percent_growth,
		type_desc
	FROM sys.master_files
	WHERE 
		type_desc != 'FULLTEXT'
		AND is_percent_growth = 1  ) AS [FileCheck]




/* Columns with different columns datatypes or sizes
Purpose: Identify columns having different datatypes, for the same column name.
         Sorted by the prevalance of the mismatched column.*/ 

-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Calculate prevalence of column name
SELECT 
	COLUMN_NAME
	,[%] = CONVERT(DECIMAL(12,2), COUNT(COLUMN_NAME) * 100.0 / COUNT(*) OVER())
INTO #Prevalence
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY COLUMN_NAME

-- Do the columns differ on datatype across the schemas and tables? 
SELECT  DISTINCT
	  C1.COLUMN_NAME
	, C1.TABLE_SCHEMA 
	, C1.TABLE_NAME
	, C1.DATA_TYPE
	, [%]
FROM INFORMATION_SCHEMA.COLUMNS C1 
INNER JOIN INFORMATION_SCHEMA.COLUMNS C2 ON C1.COLUMN_NAME = C2.COLUMN_NAME
INNER JOIN #Prevalence p ON p.COLUMN_NAME = C1.COLUMN_NAME
WHERE C1.DATA_TYPE != C2.DATA_TYPE
ORDER BY [%] DESC, C1.COLUMN_NAME, C1.TABLE_SCHEMA, C1.TABLE_NAME 

-- Tidy up.
DROP TABLE #Prevalence


		
		

		
		
/*		
SELECT 
	database_id, 
	DB_NAME(database_id) AS DatabaseName,
	Name AS Logical_Name,
	Physical_Name, 
	(SUM(Size) OVER (PARTITION BY database_id )*8)/1024 [SizeMB],
	(Size*8)/1024 [FileSizeMB],
	(growth*8/1024) [GrowthMB],
	is_percent_growth,
	type_desc
FROM sys.master_files
WHERE 
	database_id > 4
	AND type_desc != 'FULLTEXT'
*/


/*
File Sizes
10mb - 1300
50mb - 6400
150mb - 19200
250mb - 32000
512mb - 65550
1024mb - 131100
*/
























