/*

PLEASE NOTE REMEMBER TO CHANGE TEMPLATE VALUE BEFORE RUNNING

THIS WILL ENTER THIS VALUE AS THE NAME OF THE SERVER IN THE DESCRIPTION FOR THE SQL AGENT JOB

*/


USE [msdb]
GO

/*DAILY & WEEKLY JOBS AND SCHEDULES*/

/*CHECK IF THE SQL AGENT CATEGORY IS AVALIABLE*/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'

END

/*DAILY MAINTENANCE JOB & SCHEDULE*/

BEGIN TRAN CreateDailyMaintenanceJob

IF NOT EXISTS (SELECT name, sysjobs.job_id from msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_DailyMaintenance')

BEGIN 

DECLARE @descriptionDaily NVARCHAR(100) 
SET @descriptionDaily = N'This job is used to run daily maintenance scripts on various databases held on '+@@servername
DECLARE @jobId BINARY(16)
EXEC msdb.dbo.sp_add_job @job_name=N'DB_ADMIN_DailyMaintenance', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description= @descriptionDaily, 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Neil', 
		@job_id = @jobId OUTPUT

/*STEP [PURGE MAINTENANCE HISTORY TABLES]*/
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge maintenance history tables', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @dt datetime 
SET @dt = DATEADD(wk,-6,GETDATE())


EXEC msdb.dbo.sp_delete_backuphistory @dt
EXEC msdb.dbo.sp_purge_jobhistory  @oldest_date =@dt;
EXEC msdb..sp_maintplan_delete_log null,null,@dt;
DELETE FROM [Admin_DBA].[dbo].[CommandLog] WHERE DATEDIFF(dd,StartTime,GETDATE()) > 30;', 
		@database_name=N'master', 
		@flags=0

/*STEP [PURGE MAINTENANCE SCRIPT LOG]*/

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge maintenance script log', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'cmd /q /c "For /F "tokens=1 delims=" %v In (''ForFiles /P "C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG" /m *_*_*_*.txt /d -30 2^>^&1'') do if EXIST "C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG"\%v echo del "C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG"\%v& del "C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG"\%v"', 
		@flags=0

/*STEP [DATABASE INTEGRITY CHECK]*/

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database integrity check', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Admin_DBA -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''ALL_DATABASES'', @CheckCommands = ''CHECKDB'',@LogToTable = ''Y''" -b', 
		@flags=0

EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DB_ADMIN_Daily Maintenance Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130213, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

END 

COMMIT TRAN CreateDailyMaintenanceJob

GO



/*WEEKLY MAINTENANCE JOB & SCHEDULE*/

BEGIN TRAN CreateWeeklyMaintenanceJob

IF NOT EXISTS (SELECT name from msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_WeeklyMaintenance')

BEGIN 

DECLARE @DescriptionWeekly NVARCHAR(100)
SET @DescriptionWeekly = N'This job is used to run weekly maintenance scripts on various databases held on '+@@servername
DECLARE @jobId BINARY(16)
EXEC msdb.dbo.sp_add_job @job_name=N'DB_ADMIN_WeeklyMaintenance', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=@DescriptionWeekly, 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@job_id = @jobId OUTPUT

/*STEP [CYCLE SQL SERVER ERROR LOG]*/
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cycle SQL Server Error Log', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*This Procedure re-cycles the error log */

DBCC ERRORLOG
', 
		@database_name=N'master', 
		@flags=0

/*STEP [INDEX OPTIMIZE/DEFRAG]*/
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index optimize/defrag', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Admin_DBA -Q "EXECUTE [dbo].[IndexOptimize] @Databases = ''USER_DATABASES, -UsageLogs'', @FragmentationMedium = ''INDEX_REBUILD_OFFLINE'',@FragmentationHigh = ''INDEX_REBUILD_OFFLINE'',@FragmentationLevel1 = 5,@FragmentationLevel2 = 30,@UpdateStatistics = ''ALL'',@SortInTempdb = ''Y'',@LogToTable = ''Y''" -b', 
		@flags=0

EXEC msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DB_ADMIN_Weekly Maintenance Schedule', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130213, 
		@active_end_date=99991231, 
		@active_start_time=130000, 
		@active_end_time=235959


EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1



END 

COMMIT TRAN CreateWeeklyMaintenanceJob

GO


/*DB_ADMIN_EMERGENCYTRANLOGBACKUP*/

BEGIN TRAN CreateEmergencyTranLogBackup

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_EmergencyTranLogBackup')

BEGIN 

DECLARE @DescriptionEmerTranLog NVARCHAR(100)
SET @DescriptionEmerTranLog = N'This job is activated when an alert is reported for a transaction log being full for any of the database on '+@@servername
DECLARE @jobId BINARY(16)
EXEC msdb.dbo.sp_add_job 
		@job_name=N'DB_ADMIN_EmergencyTranLogBackup', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=@DescriptionEmerTranLog,
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Neil', 
		@job_id = @jobId OUTPUT

EXEC msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=N'Execute Stored Procedure USP_EmergencyTranLogBackup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC USP_EmergencyTranLogBackup @Operator = ''DBA_Neil'',@BKPath = ''<Emergency backup location,sysname,>''', 
		@database_name=N'Admin_DBA', 
		@flags=0

EXEC msdb.dbo.sp_update_alert @name=N'T-Log Full Disk Alert (9002)', 
		@message_id=9002, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1, 
		@database_name=N'', 
		@notification_message=N'', 
		@event_description_keyword=N'', 
		@performance_condition=N'', 
		@wmi_namespace=N'', 
		@wmi_query=N'', 
		@job_id=@jobid

DECLARE @Operator NVARCHAR(20)
SET @Operator = (SELECT name FROM msdb.dbo.sysoperators WHERE email_address = N'dbaadmin@emeraldinsight.com')


EXEC msdb.dbo.sp_update_notification @alert_name=N'T-Log Full Disk Alert (9002)', @operator_name=@Operator, @notification_method = 1

END


COMMIT TRAN CreateEmergencyTranLogBackup

GO


