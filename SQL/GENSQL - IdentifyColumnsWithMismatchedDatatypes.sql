/*----------------------------------------------------------------------
 
Purpose: Identify columns having different datatypes, for the same column name.
         Sorted by the prevalance of the mismatched column.

------------------------------------------------------------------------

Revision History:
 		06/01/2008	Ian_Stirk@yahoo.com Initial version

-----------------------------------------------------------------------*/

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

