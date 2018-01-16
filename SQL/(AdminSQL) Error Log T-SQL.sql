/*
Parameters

1. 0 = current, change to 1 last error log
2. 1 = SQL Server log, 2= SQL Server agent
3. Search 1
4. Search 2
*/


CREATE TABLE #ErrorLogCheck
(
Logdate Datetime
,ProcessInfo NVarchar(10)
,Text Nvarchar(MAX)
)

INSERT INTO #ErrorLogCheck
EXEC xp_ReadErrorLog 0, 1, N'login',N'Fail'

SELECT *
FROM #ErrorLogCheck
ORDER BY Logdate DESC

DROP TABLE #ErrorLogCheck


Test MERGE





