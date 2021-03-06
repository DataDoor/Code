/* Sql Script to load all required alerts onto new servers. 

Created by: Neil Gelder - 06/03/2012
Modified: 
Neil Gelder - Added alerts for 823,824,825 -10/04/2014
Neil Gelder - Added alerts for 34050,34051,34052,34053 - 25/09/2014

*/




USE [msdb]

/*Find SQL Profile Default operator for dba admin email address*/

DECLARE @Operator NVarchar(100)
SET @Operator = (SELECT [Name] FROM [msdb].[dbo].[sysoperators] WHERE email_address = 'dbaadmin@emeraldinsight.com');


/*Create Alerts */

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

EXEC msdb.dbo.sp_add_alert @name=N'Policy Based Management - On change auto (34050)', 
		@message_id=34050, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert @name=N'Policy Based Management - On change demand (34051)', 
		@message_id=34051, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;


EXEC msdb.dbo.sp_add_alert @name=N'Policy Based Management - On schedule (34052)', 
		@message_id=34052, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;

EXEC msdb.dbo.sp_add_alert @name=N'Policy Based Management - On change (34053)', 
		@message_id=34053, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;


EXEC msdb.dbo.sp_add_alert @name=N'Deadlock (1205)',
		@message_id=1205, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;

EXEC master..sp_altermessage 1205, 'WITH_LOG', TRUE;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Deadlock (3928)', 
		@message_id=3928, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;

EXEC master..sp_altermessage 3928, 'WITH_LOG', TRUE;
GO


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

EXEC msdb.dbo.sp_add_notification 
		@alert_name=N'Policy Based Management - On change auto (34050)', 
		@operator_name= @Operator,
		@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'Policy Based Management - On change demand (34051)', 
	@operator_name=@Operator, 
	@notification_method = 1;
	
EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'Policy Based Management - On schedule (34052)', 
	@operator_name=@Operator, 
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'Policy Based Management - On change (34053)', 
	@operator_name=@Operator, 
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'Deadlock (1205)', 
	@operator_name=@Operator, 
	@notification_method = 1;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'Deadlock (3928)', 
	@operator_name=@Operator, 
	@notification_method = 1;

