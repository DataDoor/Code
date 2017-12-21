/*
USE TEMPDB
GO
EXEC SP_HELPFILE
GO
*/

USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = N'F:\MSSQL\DATA\tempdb.mdf',   
SIZE = 5000MB,
FILEGROWTH = 0)
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = N'G:\MSSQL\LOG\tempdb.ldf',
SIZE = 250MB,
FILEGROWTH = 250MB)  
GO

/*uncomment if the tempdb needs additional data files  */



ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev2,
FILENAME = N'F:\MSSQL\Data\tempdb2.mdf',
SIZE = 5000MB,
FILEGROWTH = 0
)
GO

ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev3,
FILENAME = N'F:\MSSQL\Data\tempdb3.mdf',
SIZE = 5000MB,
FILEGROWTH = 0
)
GO


ALTER DATABASE tempdb
ADD FILE 
(
NAME = tempdev4,
FILENAME = N'F:\MSSQL\Data\tempdb4.mdf',
SIZE = 5000MB,
FILEGROWTH = 0
)

