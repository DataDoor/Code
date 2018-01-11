SELECT 
sm.object_id, 
OBJECT_NAME(sm.object_id) AS object_name, 
o.type, o.type_desc, 
sm.definition, 
CAST(CASE WHEN sm.definition IS NULL THEN 1 ELSE 0 END AS bit) AS [IsEncrypted] 
FROM sys.sql_modules AS sm 
JOIN sys.objects AS o ON sm.object_id = o.object_id 
ORDER BY o.type;