/*RESTORE DATABASE - This SQL Statements are various methods of restoring a database

Scripts included;

General Restore
Restore with move 
Restore with just MDF file
*/

/*GENERAL RESTORE*/

USE MASTER
GO


ALTER DATABASE N'<General Restore - Database_Name, sysname, >' SET SINGLE_USER  WITH ROLLBACK IMMEDIATE 

RESTORE DATABASE N'<General Restore - Database_Name, sysname, >'
FROM  DISK = N'<General Restore - Backup file path,sysname,\\EM-APPL018\SQLBackups\><General Restore - Backup filename,sysname,>' 



/*
RESTORE WITH MOVE 


Run the below command against the backup being used to find out logical filenames


RESTORE FILELISTONLY FROM DISK = 

*/

RESTORE DATABASE  N'<Move Restore - Database_Name, sysname, >' 
FROM DISK = N'<Move Restore - Backup file path,sysname,\\EM-APPL018\SQLBackups\><Move Restore - Backup filename,sysname,>'
WITH 
MOVE N'<Move Restore - Logical_DataFileName,sysname,>'  TO N'<Move Restore - Data file path,sysname,D:\MSSQL\DATA\>'N'<Move Restore - Data filename ,sysname,Database.mdf>') ,
MOVE N'<Move Restore - Logical_LogFileName,sysname,>'  TO '<Move Restore - Log file path,sysname,D:\MSSQL\DATA\>'N'<Move Restore - Log filename ,sysname,Database.ldf>' ,REPLACE





CREATE DATABASE N'<Data file only - Database_Name,sysname,>' ON
(FILENAME = N'<Data file only - Backup file path,sysname,D:\MSSQL\DATA\>'N'<Data file only - Data filename ,sysname,Database.mdf>')
FOR ATTACH_REBUILD_LOG
