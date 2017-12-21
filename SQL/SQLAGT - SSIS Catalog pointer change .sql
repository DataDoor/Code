/*THIS SQL IS USED TO MOVE PACAKGES BETWEEN CATALOGS QUICKER*/

UPDATE [sJSTP]
SET [sJSTP].[command] = REPLACE([sJSTP].[command],'EMERALD_DW_BUILD_NEW','EMERALD_DW_BUILD_LIVE')
FROM
    [msdb].[dbo].[sysjobsteps] AS [sJSTP]
    INNER JOIN [msdb].[dbo].[sysjobs] AS [sJOB]
        ON [sJSTP].[job_id] = [sJOB].[job_id]
WHERE [sJOB].[name] LIKE '%(2016_Ver)' AND [sJSTP].[subsystem] = 'SSIS'






