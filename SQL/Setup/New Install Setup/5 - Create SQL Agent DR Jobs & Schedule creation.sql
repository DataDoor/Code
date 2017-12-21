/*
PLEASE NOTE CHANGE THE TEMPLATE VALUE BEFORE RUNNING
THIS WILL CHANGE THE PATH FOR THE BACKUPS
*/


USE [MSDB]

/*CHECK FOR MAINTENANCE CATEGORY*/

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN

    EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'

END


/*CREATE DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL*/

IF NOT EXISTS (SELECT name from msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL')

BEGIN 


DECLARE @jobId BINARY(16)
DECLARE @JobDescription NVARCHAR(200)
SET @JobDescription =  N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL - '+@@Servername

EXEC msdb.dbo.sp_add_job 
		@job_name=N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description = @JobDescription, 
		@category_name=N'Database Maintenance', 
		@notify_email_operator_name=N'DBA_Neil', 
		@job_id = @jobId OUTPUT

/*  Step [DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL] */
EXEC msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Admin_DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'',  @Directory = N''<Backup_Path,sysname,\\EM-APPL018\SQLBackups>'', @BackupType = ''FULL'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y'', @LogToTable = ''Y''" -b', 
		@output_file_name=N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\LOG\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
		@flags=0

EXEC  msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1


IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules s WHERE name = N'DB_ADMIN_User_DB - FULL Backup Schedule')

BEGIN 

EXEC msdb.dbo.sp_add_schedule
		@Schedule_Name=N'DB_ADMIN_User_DB - FULL Backup Schedule', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20130215, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959;

END 


EXEC sp_attach_schedule
   @job_name = N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - FULL',
   @schedule_name = N'DB_ADMIN_User_DB - FULL Backup Schedule';


EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@Servername

END


GO


/*DB_ADMIN_DATABASEBACKUP  - USER_DATABASES - DIFF*/


IF NOT EXISTS (SELECT name from msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - DIFF')

BEGIN 

DECLARE @jobId BINARY(16)
DECLARE @JobDescription NVARCHAR(200)
SET @JobDescription =  N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - DIFF - '+@@Servername

EXEC msdb.dbo.sp_add_job @job_name=N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - DIFF', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=@JobDescription, 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Neil', @job_id = @jobId OUTPUT


/*Step [DB_ADMIN_DatabaseBackup  - USER_DATABASES - DIFF]   */
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - DIFF', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Admin_DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'',  @Directory = N''<Backup_Path,sysname,\\EM-APPL018\SQLBackups>'', @BackupType = ''DIFF'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y'', @LogToTable = ''Y''" -b', 
		@output_file_name=N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\LOG\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
		@flags=0

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1



IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules s WHERE name = N'DB_ADMIN_User_DB - DIFF Backup Schedule')

BEGIN 

EXEC msdb.dbo.sp_add_schedule
        @schedule_name=N'DB_ADMIN_User_DB - DIFF Backup Schedule', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20121016, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959;

END 


EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - DIFF',
   @schedule_name = N'DB_ADMIN_User_DB - DIFF Backup Schedule';



EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@Servername
		
END 

GO

/*[DB_ADMIN_DATABASEBACKUP  - USER_DATABASES - LOG] */

IF NOT EXISTS (SELECT name from msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - LOG ')
BEGIN 

DECLARE @jobId BINARY(16)
DECLARE @JobDescription NVARCHAR(200)
SET @JobDescription =  N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - LOG - '+@@Servername

EXEC msdb.dbo.sp_add_job @job_name=N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - LOG', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description = @JobDescription, 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Neil', 
		@job_id = @jobId OUTPUT

/*Step [DB_ADMIN_DatabaseBackup  - USER_DATABASES - LOG] */
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - LOG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Admin_DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'',  @Directory = N''<Backup_Path,sysname,\\EM-APPL018\SQLBackups>'', @BackupType = ''LOG'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y'', @LogToTable = ''Y''" -b', 
		@output_file_name=N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\LOG\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
		@flags=0

EXEC  msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules s WHERE name = N'DB_ADMIN_User_DB - TLOG Backup Schedule')

BEGIN 

EXEC msdb.dbo.sp_add_schedule
        @schedule_name=N'DB_ADMIN_User_DB - TLOG Backup Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@active_start_date=20120611, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959


END 

EXEC  msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@servername

EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'DB_ADMIN_DatabaseBackup  - USER_DATABASES - LOG',
   @schedule_name = N'DB_ADMIN_User_DB - TLOG Backup Schedule';

END

GO


 /*[DB_ADMIN_DATABASEBACKUP - SYSTEM_DATABASES - FULL]*/

IF NOT EXISTS (SELECT name from msdb.dbo.sysjobs WHERE name = N'DB_ADMIN_DatabaseBackup - SYSTEM_DATABASES - FULL')

BEGIN 

DECLARE @jobId BINARY(16)
DECLARE @JobDescription NVARCHAR(200)
SET @JobDescription =  N'DB_ADMIN_DatabaseBackup  - SYSTEM_DATABASES - FULL - '+@@Servername

EXEC  msdb.dbo.sp_add_job @job_name=N'DB_ADMIN_DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description = @JobDescription, 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Neil', 
		@job_id = @jobId OUTPUT

/*Step [DB_ADMIN_DatabaseBackup - SYSTEM_DATABASES - FULL]*/
EXEC  msdb.dbo.sp_add_jobstep 
		@job_id=@jobId, 
		@step_name=N'DB_ADMIN_DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Admin_DBA -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''SYSTEM_DATABASES'',   @Directory = N''<Backup_Path,sysname,\\EM-APPL018\SQLBackups>'', @BackupType = ''FULL'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y'', @LogToTable = ''Y''" -b', 
		@output_file_name=N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\LOG\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
		@flags=0

EXEC  msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysschedules s WHERE name = N'DB_ADMIN_System_DB - Full Backup Schedule')

BEGIN

EXEC msdb.dbo.sp_add_schedule
        @schedule_name=N'DB_ADMIN_System_DB - Full Backup Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120415, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959

END

EXEC  msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @@servername

EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'DB_ADMIN_DatabaseBackup - SYSTEM_DATABASES - FULL',
   @schedule_name = N'DB_ADMIN_System_DB - Full Backup Schedule';


END 


