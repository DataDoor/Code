/*BASELINE CREATION SQL*/


USE Admin_DBA


/*CHECK FOR BASELINE SCHEMA*/
IF NOT EXISTS (SELECT 1 FROM sys.schemas s WHERE s.name = 'SQLInstance_Baseline') 

EXEC('CREATE SCHEMA [SQLInstance_Baseline]')



/*CREATE REQUIRED TABLES*/
IF NOT EXISTS (SELECT 1 FROM sys.tables t WHERE name = 'DatabaseFileInfo' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')

BEGIN

    CREATE TABLE [SQLInstance_Baseline].[DatabaseFileInfo](
	    [DatabaseName] [sysname] NOT NULL,
	    [FileID] [int] NOT NULL,
	    [TypeDesc] [char](10) NOT NULL,
	    [DriveLetter] [nvarchar](1) NULL,
	    [LogicalFileName] [sysname] NOT NULL,
	    [PhysicalFileName] [nvarchar](260) NOT NULL,
	    [SizeMB] [decimal](38, 2) NULL,
	    [SpaceUsedMB] [decimal](38, 2) NULL,
	    [FreeSpaceMB] [decimal](38, 2) NULL,
	    [MaxSize] [decimal](38, 2) NULL,
	    [IsPercentGrowthSetting] [bit] NULL,
	    [GrowthSettingMB] [decimal](38, 2) NULL,
	    [CaptureDate] [datetime] NOT NULL
    ) ON [PRIMARY]

ALTER TABLE [SQLInstance_Baseline].[DatabaseFileInfo] ADD CONSTRAINT DF_DatabaseFileInfo_CaptureDate DEFAULT  GETDATE() FOR CaptureDate;

END


IF NOT EXISTS (SELECT 1 FROM sys.tables t WHERE name = 'ConfigData' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')


BEGIN

    CREATE TABLE [SQLInstance_Baseline].[ConfigData](
	    [ConfigurationID] [int] NOT NULL,
	    [Name] [nvarchar](35) NOT NULL,
	    [Value] [sql_variant] NULL,
	    [ValueInUse] [sql_variant] NULL,
	    [CaptureDate] [datetime] NULL
    ) ON [PRIMARY]

ALTER TABLE [SQLInstance_Baseline].[ConfigData] ADD CONSTRAINT DF_ConfigData_CaptureDate DEFAULT  GETDATE() FOR CaptureDate;

END


IF NOT EXISTS (SELECT 1 FROM sys.tables t WHERE name = 'PerfMonData' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')

BEGIN

    CREATE TABLE [SQLInstance_Baseline].[PerfMonData](
	    [Counter] [nvarchar](770) NULL,
	    [Value] [decimal](38, 2) NULL,
	    [CaptureDate] [datetime] NULL
    ) ON [PRIMARY]

END

ALTER TABLE [SQLInstance_Baseline].[PerfMonData] ADD CONSTRAINT DF_PerfMonData_CaptureDate DEFAULT  GETDATE() FOR CaptureDate;


IF NOT EXISTS (SELECT 1 FROM sys.tables t WHERE name = 'ServerConfig' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')


BEGIN

    CREATE TABLE [SQLInstance_Baseline].[ServerConfig](
	    [Property] [nvarchar](128) NULL,
	    [Value] [sql_variant] NULL,
	    [CaptureDate] [datetime] NULL
    ) ON [PRIMARY]

ALTER TABLE [SQLInstance_Baseline].[ServerConfig] ADD CONSTRAINT DF_ServerConfig_CaptureDate DEFAULT  GETDATE() FOR CaptureDate;

END



/*CREATE PROCEDURES*/



IF EXISTS (SELECT 1 FROM sys.procedures p WHERE name = 'usp_DBFileData' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')
DROP PROCEDURE [SQLInstance_Baseline].[usp_DBFileData]
GO

CREATE PROCEDURE [SQLInstance_Baseline].[usp_DBFileData]
AS

DECLARE @Databases TABLE (ID INT IDENTITY(1,1),DbName VARCHAR(100))
DECLARE @ID INT, @MaxID INT,@DB VARCHAR(100),@SQL VARCHAR(MAX)

INSERT INTO @Databases
SELECT name FROM sys.databases d WHERE state = 0

SET @ID = 1
SELECT @MaxID = MAX(ID) FROM @Databases d

WHILE @ID <= @MaxID

BEGIN 

SET NOCOUNT ON

    SELECT @DB = Dbname FROM @Databases WHERE ID = @ID

	   SET @SQL = N'USE ' + @DB + '
	   INSERT INTO [Admin_DBA].[SQLInstance_Baseline].[DatabaseFileInfo]
					   (
						  [DatabaseName]
						 ,[FileID] 
						 ,[TypeDesc] 
						 ,[DriveLetter]
						 ,[LogicalFileName] 
						 ,[PhysicalFileName] 
						 ,[SizeMB] 
						 ,[SpaceUsedMB] 
						 ,[FreeSpaceMB] 
						 ,[MaxSize] 
						 ,[IsPercentGrowthSetting] 
						 ,[GrowthSettingMB]
						 ,[CaptureDate] 
					   )

		 SELECT 
		    DB_NAME(DB_ID()) [Databasename]
		  ,[File_ID]
		  ,[Type_Desc]
		  ,substring([physical_name],1,1) AS [DriveLetter]
		  ,[name] AS [LogicalFileName]
		  ,[Physical_Name] AS [PhysicalFileName]
		  ,CONVERT(DECIMAL(38,2),size/128.) AS [SizeMB]
		  ,CONVERT(DECIMAL(38,2),FILEPROPERTY([name],''SpaceUsed'')/128.) AS [SpaceUsedMB]
		  ,CONVERT(DECIMAL(38,2),size/128.) - CONVERT(DECIMAL(38,2),FILEPROPERTY([name],''SpaceUsed'')/128.) AS [FreeSpaceMB]
		  ,[max_size] AS [MaxSize]
		  ,[is_percent_growth] AS [IsPercentGrowthSetting]
		  ,[growth] AS [GrowthInMB]
		  ,GETDATE() AS [CaptureDate]
		    FROM ' + @DB + '.[sys].[database_files];'
	   EXEC (@SQL)

    SET @ID = @ID +1

END


GO



IF EXISTS (SELECT 1 FROM sys.procedures p WHERE name = 'usp_PurgeBaselineData' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')
DROP PROCEDURE [SQLInstance_Baseline].[usp_PurgeBaselineData]
GO
CREATE PROCEDURE [SQLInstance_Baseline].[usp_PurgeBaselineData]
    (
      @PurgeDateDays SMALLINT
	 )
AS 
        IF @PurgeDateDays IS NULL
            BEGIN;
                RAISERROR(N'Input parameters cannot be NULL', 16, 1);
                RETURN;
            END;
        DELETE  FROM [SQLInstance_Baseline].[ConfigData]
        WHERE   [CaptureDate] < GETDATE() - @PurgeDateDays;

        DELETE  FROM [SQLInstance_Baseline].[ServerConfig]
        WHERE   [CaptureDate] < GETDATE() - @PurgeDateDays;

        DELETE  FROM [SQLInstance_Baseline].[PerfMonData]
        WHERE   [CaptureDate] < GETDATE() - @PurgeDateDays;

	   DELETE  FROM [SQLInstance_Baseline].[DatabaseFileInfo]
        WHERE   [CaptureDate] < GETDATE() - @PurgeDateDays;

GO



IF EXISTS (SELECT 1 FROM sys.procedures p WHERE name = 'usp_PerfMonReport' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')
DROP PROCEDURE [SQLInstance_Baseline].[usp_PerfMonReport]
GO

    CREATE PROCEDURE [SQLInstance_Baseline].[usp_PerfMonReport]
	   (
		@Counter NVARCHAR(128) = N'%'
	   )
    AS 
	   BEGIN;
		  SELECT  *
		  FROM    [SQLInstance_Baseline].[PerfMonData]
		  WHERE   [Counter] LIKE @Counter
		  ORDER BY [Counter] ,
				[CaptureDate]
	   END;

GO


IF EXISTS (SELECT 1 FROM sys.procedures p WHERE name = 'usp_ServerConfigReport' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')
DROP PROCEDURE [SQLInstance_Baseline].[usp_ServerConfigReport]
GO

CREATE PROCEDURE [SQLInstance_Baseline].[usp_ServerConfigReport]
    (
      @Property NVARCHAR(128) = NULL
    )
AS 
    BEGIN;
        IF @Property NOT IN ( N'ComputerNamePhysicalNetBios',
                              N'DBCC_TRACESTATUS', N'Edition',
                              N'InstanceName',
                              N'IsClustered', N'MachineName',
                              N'ProcessorNameString', N'ProductLevel',
                              N'ProductVersion', N'ServerName' ) 
            BEGIN;
                RAISERROR(N'Valid values for @Property are:
                            ComputerNamePhysicalNetBios, DBCC_TRACESTATUS,
                            Edition, InstanceName, IsClustered,
                            MachineName, ProcessorNameString,
                            ProductLevel, ProductVersion, or ServerName',
                         16, 1);
                RETURN;
            END;

        SELECT  *
        FROM    [SQLInstance_Baseline].[ServerConfig]
        WHERE   [Property] = ISNULL(@Property, Property)
        ORDER BY [Property] ,
                [CaptureDate]
    END;

GO


 IF EXISTS (SELECT 1 FROM sys.procedures p WHERE name = 'usp_SysConfigReport' AND SCHEMA_NAME(schema_id) = 'SQLInstance_Baseline')
 DROP PROCEDURE [SQLInstance_Baseline].[usp_SysConfigReport]
 GO

CREATE PROCEDURE [SQLInstance_Baseline].[usp_SysConfigReport]
    (
      @OlderDate DATETIME ,
      @RecentDate DATETIME
    )
AS 
    BEGIN;

        IF @RecentDate IS NULL
            OR @OlderDate IS NULL 
            BEGIN;
                RAISERROR(N'Input parameters cannot be NULL', 16, 1);
                RETURN;
            END;

        SELECT  [O].[Name] ,
                [O].[Value] AS "OlderValue" ,
                [O].[ValueInUse] AS "OlderValueInUse" ,
                [R].[Value] AS "RecentValue" ,
                [R].[ValueInUse] AS "RecentValueInUse"
        FROM    [SQLInstance_Baseline].[ConfigData] O
                JOIN ( SELECT   [ConfigurationID] ,
                                [Value] ,
                                [ValueInUse]
                       FROM     [SQLInstance_Baseline].[ConfigData]
                       WHERE    [CaptureDate] = @RecentDate
                     ) R ON [O].[ConfigurationID] = [R].[ConfigurationID]
        WHERE   [O].[CaptureDate] = @OlderDate
                AND ( ( [R].[Value] <> [O].[Value] )
                      OR ( [R].[ValueInUse] <> [O].[ValueInUse] )
                    )
    END;
GO




/*ADD SQL AGENT JOBS AND SCHEDULE*/



/*CREATE DBA_ADMIN_BaselineDataLoad_Daily JOB*/

USE [msdb]
GO


IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs s WHERE name = N'DBA_ADMIN_BaselineDataLoad_Daily')
EXEC sp_delete_job @job_name = N'DBA_ADMIN_BaselineDataLoad_Daily' ;
BEGIN


    DECLARE @jobId BINARY(16)
    EXEC msdb.dbo.sp_add_job @job_name=N'DBA_ADMIN_BaselineDataLoad_Daily', 
		    @enabled=1, 
		    @notify_level_eventlog=0, 
		    @notify_level_email=0, 
		    @notify_level_netsend=0, 
		    @notify_level_page=0, 
		    @delete_level=0, 
		    @description=N'This job is used to load new data and purge old data for the SQL instance baseline data on a daily basis.', 
		    @category_name=N'Database Maintenance', 
		    @owner_login_name=N'sa', @job_id = @jobId OUTPUT

    /* Step [Instance configuration baseline data]*/
    EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Instance configuration baseline data', 
		    @step_id=1, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'/*INSERT CONFIGURATION BASE LINE DATA*/

    INSERT  INTO [SQLInstance_Baseline].[ConfigData]
		  ( [ConfigurationID] ,
		    [Name] ,
		    [Value] ,
		    [ValueInUse] ,
		    [CaptureDate]
		  )
    SELECT  [configuration_id] ,
		  [name] ,
		  [value] ,
		  [value_in_use] ,
		  GETDATE()
    FROM    [sys].[configurations];', 
		    @database_name=N'Admin_DBA', 
		    @flags=0

    /*Step [Server configuration baseline data]*/
    EXEC  msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Server configuration baseline data', 
		    @step_id=2, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'SET NOCOUNT ON;

    BEGIN TRANSACTION;
    INSERT  INTO [SQLInstance_Baseline].[ServerConfig]
		  ( [Property] ,
		    [Value]
		  )
		  EXEC xp_instance_regread N''HKEY_LOCAL_MACHINE'',
			 N''HARDWARE\DESCRIPTION\System\CentralProcessor\0'',
			 N''ProcessorNameString'';
    UPDATE  [SQLInstance_Baseline].[ServerConfig]
    SET     [CaptureDate] = GETDATE()
    WHERE   [Property] = N''ProcessorNameString''
		  AND [CaptureDate] IS NULL;
    COMMIT;

    INSERT  INTO [SQLInstance_Baseline].[ServerConfig]
		  ( [Property] ,
		    [Value] ,
		    [CaptureDate]
		  )
    SELECT  N''MachineName'', SERVERPROPERTY(''MachineName'') ,GETDATE() UNION
    SELECT  N''ServerName'', SERVERPROPERTY(''ServerName'') , GETDATE() UNION
    SELECT  N''InstanceName'', @@SERVERNAME, GETDATE() UNION
    SELECT  N''IsClustered'',SERVERPROPERTY(''IsClustered''),GETDATE() UNION
    SELECT  N''ComputerNamePhysicalNetBios'', SERVERPROPERTY(''ComputerNamePhysicalNetBIOS''), GETDATE() UNION
    SELECT  N''Edition'', SERVERPROPERTY(''Edition''), GETDATE() UNION
    SELECT  N''ProductLevel'', SERVERPROPERTY(''ProductLevel''), GETDATE() UNION
    SELECT  N''ProductVersion'', SERVERPROPERTY(''ProductVersion''), GETDATE()

    DECLARE @TRACESTATUS TABLE
	   (
		[TraceFlag] SMALLINT ,
		[Status] BIT ,
		[Global] BIT ,
		[Session] BIT
	   );

    INSERT  INTO @TRACESTATUS
		  EXEC ( ''DBCC TRACESTATUS (-1)''
			 );

    IF ( SELECT COUNT(*)
	    FROM   @TRACESTATUS
	  ) > 0 
	   BEGIN;
		  INSERT  INTO [SQLInstance_Baseline].[ServerConfig]
				( [Property] ,
				  [Value] ,
				  [CaptureDate]
				)
				SELECT  N''DBCC_TRACESTATUS'' ,
					   ''TF '' + CAST([TraceFlag] AS VARCHAR(5))
					   + '': Status = '' + CAST([Status] AS VARCHAR(1))
					   + '', Global = '' + CAST([Global] AS VARCHAR(1))
					   + '', Session = '' + CAST([Session] AS VARCHAR(1)) ,
					   GETDATE()
				FROM    @TRACESTATUS
				ORDER BY [TraceFlag];
	   END;
    ELSE 
	   BEGIN;
		  INSERT  INTO [SQLInstance_Baseline].[ServerConfig] ([Property], [Value], [CaptureDate])
				SELECT  N''DBCC_TRACESTATUS'' ,''No trace flags enabled'', GETDATE()
	   END;

    ', 
		    @database_name=N'Admin_DBA', 
		    @flags=0


    /*Step [Database file baseline data]*/
    EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database file baseline data', 
		    @step_id=3, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'EXEC SQLInstance_Baseline.usp_DBFileData', 
		    @database_name=N'Admin_DBA', 
		    @flags=0

    /*Step [Purge old data from baseline data tables] */
    EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge old data from baseline data tables', 
		    @step_id=4, 
		    @cmdexec_success_code=0, 
		    @on_success_action=1, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'EXEC [SQLInstance_Baseline].[usp_PurgeBaselineData] @PurgeDateDays = 31', 
		    @database_name=N'Admin_DBA', 
		    @flags=0


    EXEC  msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1


    EXEC  msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'


    /*ADD DB_ADMIN_DailySchedule SCHEDULE*/

    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules s WHERE name = N'DB_ADMIN_DailySchedule')

    BEGIN

	   EXEC sp_add_schedule
		  @schedule_name = N'DB_ADMIN_DailySchedule',
			   @enabled=1, 
			   @freq_type=4, 
			   @freq_interval=1, 
			   @freq_subday_type=1, 
			   @freq_subday_interval=0, 
			   @freq_relative_interval=0, 
			   @freq_recurrence_factor=0, 
			   @active_start_date=20130213, 
			   @active_end_date=99991231, 
			   @active_start_time=3000, 
			   @active_end_time=235959;

    END

/*ATTACH SCHEDULE*/

    EXEC sp_attach_schedule
	  @job_name = N'DBA_ADMIN_BaselineDataLoad_Daily',
	  @schedule_name = N'DB_ADMIN_DailySchedule';


 

END

GO


/*CREATE DBA_ADMIN_BaselineDataLoad_Hourly JOB*/

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs s WHERE name = N'DBA_ADMIN_BaselineDataLoad_Hourly')
EXEC sp_delete_job @job_name = N'DBA_ADMIN_BaselineDataLoad_Hourly' ;


BEGIN


DECLARE @jobId BINARY(16)
EXEC msdb.dbo.sp_add_job @job_name=N'DBA_ADMIN_BaselineDataLoad_Hourly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is used to load new data and purge old data for the SQL instance baseline data on a hourly schedule.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT

/*Step [Performance counter baseline data]*/
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Performance counter baseline data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*Populate performance data*/ 
		
SET NOCOUNT ON;

DECLARE @PerfCounters TABLE
    (
      [Counter] NVARCHAR(770) ,
      [CounterType] INT ,
      [FirstValue] DECIMAL(38, 2) ,
      [FirstDateTime] DATETIME ,
      [SecondValue] DECIMAL(38, 2) ,
      [SecondDateTime] DATETIME ,
      [ValueDiff] AS ( [SecondValue] - [FirstValue] ) ,
      [TimeDiff] AS ( DATEDIFF(SS, FirstDateTime, SecondDateTime) ) ,
      [CounterValue] DECIMAL(38, 2)
    );

INSERT  INTO @PerfCounters
        ( [Counter] ,
          [CounterType] ,
          [FirstValue] ,
          [FirstDateTime]
        )
        SELECT  RTRIM([object_name]) + N'':'' + RTRIM([counter_name]) + N'':''
                + RTRIM([instance_name]) ,
                [cntr_type] ,
                [cntr_value] ,
                GETDATE()
        FROM    sys.dm_os_performance_counters
        WHERE   [counter_name] IN ( N''Page life expectancy'',
                                    N''Lazy writes/sec'', N''Page reads/sec'',
                                    N''Page writes/sec'', N''Free Pages'',
                                    N''Free list stalls/sec'',
                                    N''User Connections'',
                                    N''Lock Waits/sec'',
                                    N''Number of Deadlocks/sec'',
                                    N''Transactions/sec'',
                                    N''Forwarded Records/sec'',
                                    N''Index Searches/sec'',
                                    N''Full Scans/sec'',
                                    N''Batch Requests/sec'',
                                    N''SQL Compilations/sec'',
                                    N''SQL Re-Compilations/sec'',
                                    N''Total Server Memory (KB)'',
                                    N''Target Server Memory (KB)'',
                                    N''Latch Waits/sec'' )
        ORDER BY [object_name] + N'':'' + [counter_name] + N'':''
                + [instance_name];

WAITFOR DELAY ''00:00:10'';

UPDATE  @PerfCounters
SET     [SecondValue] = [cntr_value] ,
        [SecondDateTime] = GETDATE()
FROM    sys.dm_os_performance_counters
WHERE   [Counter] = RTRIM([object_name]) + N'':'' + RTRIM([counter_name])
                                                                  + N'':''
        + RTRIM([instance_name])
        AND [counter_name] IN ( N''Page life expectancy'', 
                                N''Lazy writes/sec'',
                                N''Page reads/sec'', N''Page writes/sec'',
                                N''Free Pages'', N''Free list stalls/sec'',
                                N''User Connections'', N''Lock Waits/sec'',
                                N''Number of Deadlocks/sec'',
                                N''Transactions/sec'',
                                N''Forwarded Records/sec'',
                                N''Index Searches/sec'', N''Full Scans/sec'',
                                N''Batch Requests/sec'',
                                N''SQL Compilations/sec'',
                                N''SQL Re-Compilations/sec'',
                                N''Total Server Memory (KB)'',
                                N''Target Server Memory (KB)'',
                                N''Latch Waits/sec'' );

UPDATE  @PerfCounters
SET     [CounterValue] = [ValueDiff] / [TimeDiff]
WHERE   [CounterType] = 272696576;

UPDATE  @PerfCounters
SET     [CounterValue] = [SecondValue]
WHERE   [CounterType] <> 272696576;

INSERT  INTO [SQLInstance_Baseline].[PerfMonData]
        ( [Counter] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  [Counter] ,
                [CounterValue] ,
                [SecondDateTime]
        FROM    @PerfCounters;', 
		@database_name=N'Admin_DBA', 
		@flags=0

EXEC  msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1


/*ATTACH SCHEDULE*/

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules s WHERE name = N'DBA_ADMIN_HourlySchedule')


BEGIN

EXEC sp_add_schedule
    @schedule_name = N'DBA_ADMIN_HourlySchedule', 
    @enabled=1, 
    @freq_type=4, 
    @freq_interval=1, 
    @freq_subday_type=8, 
    @freq_subday_interval=1, 
    @freq_relative_interval=0, 
    @freq_recurrence_factor=0, 
    @active_start_date=20140603, 
    @active_end_date=99991231, 
    @active_start_time=0, 
    @active_end_time=235959
 
END

EXEC sp_attach_schedule
   @job_name = N'DBA_ADMIN_BaselineDataLoad_Hourly',
   @schedule_name = N'DBA_ADMIN_HourlySchedule';


EXEC  msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'

 

END














