SELECT 
	d.name AS [DatabaseName]
	,l.name AS [LoginName]
	,'ALTER AUTHORIZATION ON DATABASE ::'+d.name+' TO sa;' AS [SQLCommand] 
FROM 
	sys.databases d
	INNER JOIN sys.syslogins l
		ON (d.owner_sid = l.sid)
WHERE 
	l.name NOT IN ('SA','DYNSA') --AND @@SERVERNAME = HOST_NAME()



