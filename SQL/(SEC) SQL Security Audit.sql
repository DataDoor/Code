/*Check for orphan users in databases*/


CREATE TABLE #User
(
DatabaseName NVARCHAR(100)
,LoginTypeDesc NVARCHAR(15)
,LoginSID UNIQUEIDENTIFIER
,LoginName NVARCHAR(100)
,DisableUserSQL NVARCHAR(100)
,ReEnableUserSQL NVARCHAR(100)
,DropUserSQL NVARCHAR(100)
)

EXEC sys.sp_MSforeachdb
'
USE [?]


INSERT INTO #User
(
DatabaseName 
,LoginTypeDesc 
,LoginSID 
,LoginName 
,DisableUserSQL 
,ReEnableUserSQL 
,DropUserSQL
)


SELECT 
	DB_NAME() AS [DatabaseName]
	,dp.type_desc
    ,dp.sid
	,dp.name 
	,''REVOKE CONNECT TO ''+QUOTENAME(dp.name)  AS [DisableUserSQL]
	,''GRANT CONNECT TO ''+QUOTENAME(dp.name)  AS [Re-EnableUserSQL]
	,''DROP USER ''+QUOTENAME(dp.name)  AS [DropUserSQL]
FROM 
	sys.database_principals dp
	LEFT JOIN sys.server_principals sp 
		ON dp.sid = sp.sid 
WHERE 
	dp.principal_id > 4 --Removes dbo etc
	AND dp.type IN (''U'',''S'') --limits to Windows and SQL Logins
	AND sp.sid IS NULL '

SELECT * FROM #User

--UNCOMMENT IF REQUIRED
DROP TABLE #User


/*The system stored procedure sp_validatelogins returns a list of logins in an SQL Server instance that no longer exists in the windows environment, 
for instance in the AD or on the local computer.*/
		
EXEC sp_MSforeachdb 'USE [?] EXEC [sys].[sp_validatelogins]'


/*Sysadmin check*/
SELECT 
	loginname
	,hasaccess
	,isntname
	,isntgroup
	,isntuser
	,sysadmin
	,securityadmin
	,serveradmin
	,setupadmin
	,processadmin
	,diskadmin
	,dbcreator
	,bulkadmin
FROM sys.syslogins sp
WHERE sp.sysadmin = 1

/*Check for excessive server credentials other than
sysadmin which is checked above*/

SELECT 
	loginname
	,hasaccess
	,isntname
	,isntgroup
	,isntuser
	,sysadmin
	,securityadmin
	,serveradmin
	,setupadmin
	,processadmin
	,diskadmin
	,dbcreator
	,bulkadmin
FROM sys.syslogins sp
WHERE 
	 securityadmin = 1
	OR serveradmin = 1
	OR setupadmin = 1
	OR processadmin = 1
	OR diskadmin = 1
	OR dbcreator = 1
	OR sp.bulkadmin = 1


/*Checks SQL logins for blank for poor passwords*/

WITH [PasswordChk] AS
(SELECT 
	name AS [LoginName]
	,CASE 
		WHEN PWDCOMPARE('', password_hash) = 1 THEN 'Blank password being used'
		WHEN PWDCOMPARE('sa', password_hash) = 1 THEN 'sa password being used'
		WHEN PWDCOMPARE('Password123', password_hash) = 1 THEN 'Password123 password being used'
		WHEN PWDCOMPARE(name, password_hash) = 1 THEN 'login name password being used'
		ELSE 'N/A'
	END [Result]
FROM sys.sql_logins sl)
SELECT *
FROM PasswordChk pc
WHERE Result <> 'N/A'

