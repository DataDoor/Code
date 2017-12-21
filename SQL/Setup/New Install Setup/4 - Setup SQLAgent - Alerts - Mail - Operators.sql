USE [msdb]
GO

/*SQL Agent Setup Scripts*/


/* Create a Database Mail profile*/ 

DECLARE @Mail_Profile_Name NVARCHAR(100)
DECLARE @Mail_Profile_Description  NVARCHAR(100)
DECLARE @Mail_Account_Name NVARCHAR(100)
DECLARE @Mail_Account_Description NVARCHAR(100)
DECLARE @Mail_Account_Email NVARCHAR(100)
DECLARE @Mail_Account_ReplyToEmail NVARCHAR(100)
DECLARE @Mail_Account_DisplayName NVARCHAR(100)
DECLARE @Mail_Account_MailServerName NVARCHAR(100)

/*Profile*/
SET @Mail_Profile_Name = @@servername+N' - DB Admin Mail Profile'
SET @Mail_Profile_Description = N'Database mail profile for '+@@Servername

/*Main DBA email account*/
SET @Mail_Account_Name  = @@servername+N' - DBAdminMailAccount'
SET @Mail_Account_Description = N'DB Admin Default Mail Account'
SET @Mail_Account_Email  = N'DBAAdmin@emeraldinsight.com'
SET @Mail_Account_DisplayName = @@servername+N' - DBAdmin'
SET @Mail_Account_MailServerName =N'EXCHANGE'


EXECUTE msdb.dbo.sysmail_add_profile_sp 
@profile_name = @Mail_Profile_Name, 
@description = @Mail_Profile_Description ; 

-- Create a Database Mail account 
EXECUTE msdb.dbo.sysmail_add_account_sp 
@account_name = @Mail_Account_Name, 
@description = @Mail_Account_Description , 
@email_address =@Mail_Account_Email, 
@display_name = @Mail_Account_DisplayName, 
@mailserver_name = @Mail_Account_MailServerName ; 

-- Add the account to the profile 
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
@profile_name = @Mail_Profile_Name, 
@account_name = @Mail_Account_Name, 
@sequence_number =1 ; 

-- Grant access to the profile to the DBMailUsers role 
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp 
@profile_name = @Mail_Profile_Name, 
@principal_id = 0, 
@is_default = 1 ; 

GO


/*Add operators*/
DECLARE @OperatorName NVARCHAR(100)
SET @OperatorName = SUBSTRING(@@Servername,CHARINDEX('-',@@SERVERNAME)+1,LEN(@@Servername))+N'_DBAdmin'

EXEC msdb.dbo.sp_add_operator 
	@name=@OperatorName, 
	@enabled=1, 
	@weekday_pager_start_time=0, 
	@weekday_pager_end_time=235959, 
	@saturday_pager_start_time=0, 
	@saturday_pager_end_time=235959, 
	@sunday_pager_start_time=0, 
	@sunday_pager_end_time=235959, 
	@pager_days=127, 
	@email_address=N'DBAAdmin@EmeraldInsight.com'
GO

EXEC msdb.dbo.sp_add_operator 
	@name= N'DBA_Neil', 
	@enabled=1, 
	@weekday_pager_start_time=0, 
	@weekday_pager_end_time=235959, 
	@saturday_pager_start_time=0, 
	@saturday_pager_end_time=235959, 
	@sunday_pager_start_time=0, 
	@sunday_pager_end_time=235959, 
	@pager_days=127, 
	@email_address=N'ngelder@EmeraldInsight.com'
GO


/*Set SQL Agent Properties*/
DECLARE @DBMailProfile NVARCHAR(100)
SET @DBMailProfile = @@servername+N' - DB Admin Mail Profile'

EXEC msdb.dbo.sp_set_sqlagent_properties 
	@databasemail_profile = @DBMailProfile
	,@sqlserver_restart = 1
	,@monitor_autostart =1
	,@job_shutdown_timeout = 15
	,@jobhistory_max_rows = 1000
	,@jobhistory_max_rows_per_job = 100
GO

/*Find SQL Profile Default operator for dba admin email address*/

DECLARE @Operator NVarchar(100)
SET @Operator = (SELECT [Name] FROM [msdb].[dbo].[sysoperators] WHERE email_address = 'dbaadmin@emeraldinsight.com');


/*CREATE ALERTS*/

EXEC msdb.dbo.sp_add_alert 
	@name=N'Data Full Disk Alert 1 (1101)', 
	@message_id = 1101, 
	@severity = 0, 
	@enabled = 1, 
	@delay_between_responses = 3600, 
	@include_event_description_in = 1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Data Full Disk Alert 2 (1105)', 
		@message_id=1105, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'T-Log Full Disk Alert (9002)', 
		@message_id=9002, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Error In Resourse Alert (19)', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Error In Current Process Alert (20)', 
		@message_id=0, 
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Error In Database Process Alert (21)', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Error: Table Integrity Suspect Alert (22)', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;


EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Error: Database Integrity Suspect Alert (23)', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;


EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Hardware Error Alert (24)', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Fatal Error Alert (25)', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'Hardware problems/System problems in SQL Server (823)', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert 
		@name=N'I/O error torn page (824)', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;


EXEC msdb.dbo.sp_add_alert 
		@name=N'I/O error disk read error (825)', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;


/*Alter alerts to send notifications to operator*/

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Data Full Disk Alert 1 (1101)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Data Full Disk Alert 2 (1105)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'T-Log Full Disk Alert (9002)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Error In Resourse Alert (19)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Error In Current Process Alert (20)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Error In Database Process Alert (21)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Error: Table Integrity Suspect Alert (22)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Error: Database Integrity Suspect Alert (23)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Hardware Error Alert (24)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Fatal Error Alert (25)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'Hardware problems/System problems in SQL Server (823)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'I/O error torn page (824)', 
	@operator_name = @Operator,
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name = N'I/O error disk read error (825)', 
	@operator_name = @Operator,
	@notification_method = 1;