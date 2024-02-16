/*
Author: Johanan Tai
Description: Reports the number of endorsement entries made within a certain date range 
*/


/*change to the appropriate date range*/
WITH local_var AS (
	SELECT 
		'2024-01-01'::DATE AS start_date,
		'2024-12-31'::DATE AS end_date
)

SELECT 
	COUNT(A.*) AS "Endorsement Entries", 
	SUM(A.candidates_endorsed) AS "Total Candidates Endorsed"

FROM (
	SELECT 
		endorse.endorse_id, 
		COUNT(endorse_candidate.endorse_candidate_id) AS candidates_endorsed,
		endorse.created,
		endorse.modified

	FROM endorse
	LEFT JOIN endorse_candidate USING (endorse_id)
	
	WHERE endorse_candidate_id IS NOT NULL
	
	GROUP BY endorse_id
	) A
	
CROSS JOIN local_var
WHERE A.created BETWEEN local_var.start_date AND local_var.end_date