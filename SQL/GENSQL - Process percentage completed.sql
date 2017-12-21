SELECT 
	Session_Id,
	percent_complete,
	DB_NAME(database_id) DatabaseName,  
	start_time, 
	status, 
	command, 
	estimated_completion_time/1000/60 AS 'Minutes to Completion', 
	total_elapsed_time/1000/60 AS 'Minutes Elapsed', 
	wait_type, last_wait_type
FROM 
	sys.dm_exec_requests
ORDER BY 
	'Minutes to Completion' DESC,
	start_time DESC


