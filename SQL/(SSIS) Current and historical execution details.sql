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
FROM (
SELECT em.*
FROM SSISDB.CATALOG.event_messages em(NOLOCK)
--WHERE em.operation_id = (SELECT MAX(execution_id) FROM SSISDB.catalog.executions) --Find currently executing details
WHERE em.operation_id = (SELECT MAX(execution_id) FROM SSISDB.CATALOG.executions WHERE folder_name = 'GDPR') --Find last execution at folder level
--WHERE em.operation_id = (SELECT MAX(execution_id) FROM SSISDB.CATALOG.executions WHERE folder_name = 'SSIS Catalog folder name' AND project_name = 'Project name') --Find last execution at project level
) q
/* Put in whatever WHERE predicates you might like*/
--WHERE event_name NOT LIKE '%Validate%'
--WHERE event_name = 'OnError'
--WHERE package_name = 'packagename.dtsx'
--WHERE execution_path LIKE '%<some executable>%'
ORDER BY message_time DESC



