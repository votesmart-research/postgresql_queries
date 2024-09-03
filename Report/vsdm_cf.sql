/*
Author: Johanan Tai
Description: These are the queries for the purpose of getting Campaign Finance (CF) data for 2024 VSDM and beyond
Date: 2024-06-17
*/

SELECT code, candidate_id

FROM finsource_candidate

WHERE candidate_id IN (
	SELECT 
		candidate_id 
	FROM 
		office_candidate
	WHERE 
		-- Shows only active candidates
		(officecandidatestatus_id = 1 OR candidate_id = 171843)
	AND
		office_candidate.office_id IN (5,6)
)
AND finsource_id = 1;