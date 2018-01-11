/*SSIS CATALOG QUERIES*/

SELECT 
	event_message_id
	,[Message]
	,package_name
	,event_name
	,message_source_name
	,package_path
	,execution_path
	,message_type
	,message_source_type
FROM SSISDB.CATALOG.event_messages em(NOLOCK) 
INNER JOIN (SELECT MAX(execution_id)  AS execution_id, folder_name FROM SSISDB.catalog.executions GROUP BY folder_name) e
	ON em.operation_id = e.execution_id
/* Frequently used predicates*/
--WHERE folder_name = <Folder Name,1,'FolderName'> AND project_name = <Project Name,1,'Projectname'>
--WHERE	event_name = 'OnError'
--WHERE	package_name = 'ScopusCitation.dtsx'
--WHERE execution_path LIKE '%<some executable>%'



