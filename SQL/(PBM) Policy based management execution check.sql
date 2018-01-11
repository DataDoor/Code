/*POLICY BASED MANAGMENT CHECK*/

;WITH last_pbm_execution
AS (
	SELECT policy_id
		,max(history_id) AS history_id
	FROM msdb.dbo.syspolicy_policy_execution_history
	WHERE end_date > GETDATE() - 1
	GROUP BY policy_id
	)
SELECT 
	p.NAME
	,h.end_date
	,CASE h.result
		WHEN 1
			THEN 'Success'
		ELSE 'Failure'
		END result
	,d.target_query_expression
	,d.exception
	,d.exception_message
	,d.result_detail
FROM 
	msdb.dbo.syspolicy_policies p
	JOIN msdb.dbo.syspolicy_policy_execution_history h ON (p.policy_id = h.policy_id)
	JOIN last_pbm_execution lpe ON (
			h.policy_id = lpe.policy_id
			AND h.history_id = lpe.history_id
			)
	LEFT JOIN msdb.dbo.syspolicy_policy_execution_history_details d ON (h.history_id = d.history_id)
ORDER BY p.NAME