/*
	Purpose of the Script
	This script cleans up objects created by DTA client on the target server 
	(server being tuned). DTA creates support tables and stored procedures on the target server. 
	The schema of the DTA tables and the DTA SP interfaces changed from Beta 2. 
	
	When to use it
	If a Beta 2 DTA client was used to tune/evaluate against the target server then
	this script needs to be executed (against the target server) for later versions 
	of DTA to function properly.
	
	Impact
	Previous session details are lost.

*/
go
use msdb
go
-- Drop DTA msdb Tables
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_indexcolumn') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_indexcolumn
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_querycolumn') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_querycolumn
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_querytable') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_querytable
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_tableview') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_tableview
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_querydatabase') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_querydatabase
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_queryindex') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_queryindex
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_column') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_column
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_index') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_index
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_table') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_table
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_query') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_query
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_partitionscheme') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_partitionscheme
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_partitionfunction') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_partitionfunction
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_tuninglog') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_tuninglog
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_reports_database') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_reports_database
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_progress') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_progress
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_output')and (type = 'U')and (uid = user_id('dbo'))))
	drop table dbo.DTA_output
if (exists (select * from msdb.dbo.sysobjects where (name = N'DTA_input') and (type = 'U') and (uid = user_id('dbo'))))
	drop table dbo.DTA_input
	
-- Drop DTA msdb SP's
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_check_permission' and type = 'P') 
	drop procedure dbo.sp_DTA_check_permission 
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_add_session' and type = 'P') 
	drop procedure dbo.sp_DTA_add_session 
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_delete_session' and type = 'P')
	drop procedure dbo.sp_DTA_delete_session 
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_session_tuning_results' and type = 'P')
	drop procedure dbo.sp_DTA_get_session_tuning_results
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_set_interactivestatus' and type = 'P')
	drop procedure dbo.sp_DTA_set_interactivestatus
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_help_session' and type = 'P')
	drop procedure dbo.sp_DTA_help_session
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_update_session' and type = 'P')
	drop procedure dbo.sp_DTA_update_session
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_tuninglog' and type = 'P')
	drop procedure dbo.sp_DTA_get_tuninglog
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_index_usage_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_index_usage_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_index_usage_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_index_usage_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_database_access_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_database_access_helper_xml
if exists (select name from msdb.dbo.sysobjects where name = 'sp_DTA_database_access_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_database_access_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_table_access_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_table_access_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_table_access_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_table_access_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_column_access_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_column_access_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_column_access_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_column_access_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_costrange_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_query_costrange_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_costrange_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_query_costrange_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_cost_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_query_cost_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_cost_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_query_cost_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_event_weight_helper_xml' and type = 'P') 
	drop procedure dbo.sp_DTA_event_weight_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_event_weight_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_event_weight_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_detail_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_query_detail_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_detail_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_query_detail_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_indexrelations_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_query_indexrelations_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_query_indexrelations_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_query_indexrelations_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_index_current_detail_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_index_current_detail_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_index_recommended_detail_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_index_recommended_detail_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_index_detail_current_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_index_detail_current_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_index_detail_recommended_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_index_detail_recommended_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_view_table_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_view_table_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_view_table_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_view_table_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_wkld_analysis_helper_xml' and type = 'P')
	drop procedure dbo.sp_DTA_wkld_analysis_helper_xml
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_wkld_analysis_helper_relational' and type = 'P')
	drop procedure dbo.sp_DTA_wkld_analysis_helper_relational
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_session_report' and type = 'P')
	drop procedure dbo.sp_DTA_get_session_report
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_set_tuninglogtablename' and type = 'P')
	drop procedure dbo.sp_DTA_set_tuninglogtablename
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_tuningoptions' and type = 'P')
	drop procedure dbo.sp_DTA_get_tuningoptions
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_interactivestatus' and type = 'P')
	drop procedure dbo.sp_DTA_get_interactivestatus
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_progressinformation' and type = 'P')
	drop procedure dbo.sp_DTA_insert_progressinformation
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_set_progressinformation' and type = 'P')
	drop procedure dbo.sp_DTA_set_progressinformation
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_set_outputinformation' and type = 'P')
	drop procedure dbo.sp_DTA_set_outputinformation
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_database' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_database
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_partitionscheme' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_partitionscheme
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_partitionfunction' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_partitionfunction
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_column' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_column
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_tableview' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_tableview
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_query' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_query
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_index' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_index
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_table' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_table
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_queryindex' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_queryindex
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_indexcolumn' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_indexcolumn
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_querytable' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_querytable
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_querydatabase' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_querydatabase
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_reports_querycolumn' and type = 'P')
	drop procedure dbo.sp_DTA_insert_reports_querycolumn
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_insert_DTA_tuninglog' and type = 'P')
	drop procedure dbo.sp_DTA_insert_DTA_tuninglog
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_databasetableids' and type = 'P')
	drop procedure dbo.sp_DTA_get_databasetableids
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_pftableids' and type = 'P')
	drop procedure dbo.sp_DTA_get_pftableids
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_pstableids' and type = 'P')
	drop procedure dbo.sp_DTA_get_pstableids
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_tableids' and type = 'P')
	drop procedure dbo.sp_DTA_get_tableids
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_columntableids' and type = 'P')
	drop procedure dbo.sp_DTA_get_columntableids
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_get_indexableids' and type = 'P')
	drop procedure dbo.sp_DTA_get_indexableids
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_update_tuninglog_errorfrequency' and type = 'P')
	drop procedure dbo.sp_DTA_update_tuninglog_errorfrequency
	
-- Drop unused SP's if they exist.		
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_columnaccesshelper' and type = 'P')
	drop procedure dbo.sp_DTA_columnaccesshelper
if exists (select name from msdb.dbo.sysobjects where name = 'sp_DTA_databaseaccesshelper' and type = 'P')
	drop procedure dbo.sp_DTA_databaseaccesshelper
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_indexusagehelper' and type = 'P')
	drop procedure dbo.sp_DTA_indexusagehelper
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_queryCRhelper' and type = 'P')
	drop procedure dbo.sp_DTA_queryCRhelper
if exists (select name from msdb.dbo.sysobjects	where name = 'sp_DTA_tableaccesshelper' and type = 'P')
	drop procedure dbo.sp_DTA_tableaccesshelper