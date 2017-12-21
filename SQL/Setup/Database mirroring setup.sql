/*This set of SQL Statements can be used to setup Database Mirroring between two servers


PLEASE NOTE - These scripts are easier to be executed in SQLCMD mode as it requires switching between servers

Use find and replace for Following 


*/

/*Check the principal database is currently in FULL recovery mode*/

SELECT Name, recovery_model_desc FROM sys.databases


/*If not set the database to full recovery*/

:connect Principal_DB_Instance
ALTER DATABASE MirrorPrincipal SET RECOVERY FULL WITH NO_WAIT;
GO
/*Take a FULL database backup and also a log backup*/

:connect Principal_DB_Instance

BACKUP DATABASE Principal_DB 
TO DISK = N'\\EM-APPL018\ITSQL\'
GO


/*PLEASE NOTE - This log backup is only require if the recovery model required changing**/
:connect Principal_DB_Instance

BACKUP LOG Principal_DB 
TO DISK = N'\\EM-APPL018\ITSQL\'

GO

/*Check Logical names of database from backup
This is only required if then database  doesn't exist on the target server and needs restoring first i.e. moving */

RESTORE FILELISTONLY 
FROM DISK = N'\\EM-APPL018\ITsql\EM-DBT01\SRMTest_MSCRM\FULL\EM-DBT01_SRMTest_MSCRM_FULL_20140831_025044.bak'

/*Restore the database but ensure that its left in a recovering state for mirroring*/

:connect Mirror

RESTORE DATABASE  Mirror_DB 
FROM DISK = N'\\EM-APPL018\itsql\SRMMirror.bak'
WITH 

/*Uncomment these if the database is new and need file placement*/
 --MOVE N'mscrm'  TO N'D:\MSSQL\DATA\SRMTest_MSCRM.mdf' , 
--MOVE N'mscrm_log'  TO N'E:\MSSQL\LOG\SRMTest_MSCRM_log.LDF' ,
REPLACE, NORECOVERY 

GO


:connect mirror
/*Restore log file if required*/ 
RESTORE DATABASE  Mirror_DB 
FROM DISK = N'\\EM-APPL018\itsql\SRMMirror.bak'
WITH NORECOVERY

GO

/*Uncomment these if the database is new and need file placement*/
 --MOVE N'mscrm'  TO N'D:\MSSQL\DATA\SRMTest_MSCRM.mdf' , 
--MOVE N'mscrm_log'  TO N'E:\MSSQL\LOG\SRMTest_MSCRM_log.LDF' ,
REPLACE, NORECOVERY 


GO

/*Check if Endpoints have been created on both the principal and mirror instances*/

:connect Principal_DB_Instance
SELECT * FROM sys.database_mirroring_endpoints 
GO

:connect Mirror
SELECT * FROM sys.database_mirroring_endpoints 
GO

/*If Endpoint's aren't present then create using the below*/

CREATE ENDPOINT [SQLInstancename_Mirroring_Endpoint]  --i.e. DBL01_Mirroring_Endpoint
STATE=STARTED 
AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL) 
FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE 
, ENCRYPTION = REQUIRED ALGORITHM RC4) 
GO 


/*Grant connection rights to database mirroring endpoint for the SQL Server service account on both principal and mirror*/
:connect Principal_DB_Instance
GRANT CONNECT ON ENDPOINT ::Principal_DB_Instance_Mirroring_Endpoint --I.e [DBL01_Mirroring_Endpoint ]
TO [MCB_BFD1\SQLServer service login] ---Mirror SQL Service login account i.e [MCB_BFD1\DBT01_SQLSRV] if mirroring from DBL01 to DBT01

:connect Mirror
GRANT CONNECT ON ENDPOINT ::Mirror_DB_Instance_Mirroring_Endpoint  --I.e [DBT01_Mirroring_Endpoint ]
TO [MCB_BFD1\SQLServer service login]  ---Principal SQL Service login account [MCB_BFD1\DBL01_SQLSRV] if mirroring from DBL01 to DBT01


/*Set partner and created SQL Agent monitoring job on mirror server

Example: ALTER DATABASE DBMirror SET PARTNER = /*This is the tcp for the principal*/ N'TCP://EM-DBL01.Emerald.Net:5022' 
This is to be run on the server were the mirrored database will be and links back to where the principal database is

*/

:connect Mirror

ALTER DATABASE DatabaseBeingMirrored SET PARTNER = N'TCP://Principal_DB_Instance.Emerald.Net:5022' --TCP for Principal i.e. TCP://DBL01.Emerald.Net:5022


EXEC sys.sp_dbmmonitoraddmonitoring --this create database mirroring SQL Agent job

GO

/*Set partner, set asynchronous mode, and setup job on principal server

Example: - ALTER DATABASE DBMirror SET PARTNER = N'TCP://DBT01_Instance.Emerald.Net:5022' 
This is to be run on the server were the principal database will link back to where the mirror database is
*/

:connect Principal_DB_Instance

ALTER DATABASE SRMDEV_MSCRM SET PARTNER = N'TCP://Mirror_DB_Instance.Emerald.Net:5022' ---TCP for Mirror Instance i.e. N'TCP://DBT01_Instance.Emerald.Net:5022' 

EXEC sys.sp_dbmmonitoraddmonitoring -- default is 1 minute 


/*Check the following DMV to ensure the mirroring is running */
 :connect Principal_DB_Instance
SELECT * FROM sys.dm_db_mirroring_connections 
SELECT * FROM sys.database_mirroring 
GO

 :connect Mirror
SELECT * FROM sys.dm_db_mirroring_connections 
SELECT * FROM sys.database_mirroring 
GO


/*FAILOVER - 
Once the mirroring is running there could be a need to failover and the need for these to swap roles.  
If you have a witness server then failover is automatic if not you can run the following commands on the Principal server, 
this will failover the connections etc to the mirrored database and they'll swap roles essentially. */

 
ALTER DATABASE Principal_DB SET PARTNER FAILOVER;



/*To stop the mirroring all together either do this through the Mirroring configuration in SSMS or T-SQL*/ 
 
ALTER DATABASE Principal_DB SET PARTNER OFF 
 
/*REMEMBER to recovery the mirrored database by issuing the 
RESTORE DATABASE [Database] WITH RECOVERY Command*/
