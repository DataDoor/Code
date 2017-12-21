--use tempdb
--go
--sp_helpfile
--go

USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb.mdf>',   
SIZE = 2048MB,
FILEGROWTH = 0)
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = N'<TempDB_LogFile2,sysname,H:\MSSQL\Logs\tempdb.ldf>')  
GO

--uncomment if the tempdb needs additional data files  



ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev2,
FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb2.mdf>',
SIZE = 2048mb,
FILEGROWTH = 0
)
GO

ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev3,
FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb3.mdf>',
SIZE = 2048mb,
FILEGROWTH = 0
)
GO


ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev4,
FILENAME = N'<TempDB_DateFile1,sysname,G:\MSSQL\Data\tempdb4.mdf>',
SIZE = 2048mb,
FILEGROWTH = 0
)

