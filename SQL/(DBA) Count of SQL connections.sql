/*CONNECTIONS - This SQL Scripts show aspects of connection currently on the SQL Server instance


Scripts included:

Connections by IP address 
Logins with more than one session
Logins using context switching

*/




/* Connections by IP address */
 
 SELECT  
	 dec.client_net_address ,         
	des.program_name ,         
	des.host_name ,       
	--des.login_name ,         
	COUNT(dec.session_id) AS connection_count 
 FROM   
	sys.dm_exec_sessions AS des         
	INNER JOIN sys.dm_exec_connections AS dec                        
		ON des.session_id = dec.session_id -- 

GROUP BY 
	dec.client_net_address ,          
	des.program_name ,          
	des.host_name       
	-- des.login_name -- HAVING COUNT(dec.session_id) > 1 
ORDER BY 
	des.program_name,          
	dec.client_net_address ;


/*Logins with more than one session*/

SELECT  
	login_name ,         
	COUNT(session_id) AS session_count 
FROM    
	sys.dm_exec_sessions 
WHERE   
	is_user_process = 1
GROUP BY 
	login_name


/*Logins using context switching*/

SELECT  
	session_id ,         
	login_name ,         
	original_login_name 
FROM    
	sys.dm_exec_sessions 
WHERE   
	is_user_process = 1         
	AND login_name <> original_login_name

