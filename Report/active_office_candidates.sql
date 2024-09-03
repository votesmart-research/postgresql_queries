/*
Author: Johanan Tai
Description: Shows the currently active congress members
*/

SELECT *


-- Subquery due to DISTINCT not being able to be applied 
FROM (

SELECT
	/*Due to a cartesian product from cross join, distinct is needed to prevent duplicates*/
	DISTINCT ON (candidate.candidate_id)
	candidate.candidate_id,
	candidate.firstname,
	candidate.lastname,
	office.name AS office,
	state.name AS state,
	state.state_id AS state_id,
	districtname.name AS district,
	party.name AS party

FROM office_candidate
JOIN candidate USING (candidate_id)

LEFT JOIN office USING (office_id)
LEFT JOIN state ON office_candidate.state_id = state.state_id
LEFT JOIN districtname USING (districtname_id)
LEFT JOIN office_candidate_party USING (office_candidate_id)
LEFT JOIN party ON office_candidate_party.party_id = party.party_id

WHERE 
	/*shows when the candidate is active*/
	officecandidatestatus_id = 1
	AND
	office_candidate.office_id IN (12)
--	AND
--	party.name NOT IN ('Conservative', 'Working Families')

) A

ORDER BY A.office DESC, A.state, A.lastname;