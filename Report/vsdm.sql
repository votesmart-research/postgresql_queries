/*
Author: Johanan Tai
Description: These are the general queries for the creation of 2024 VSDM and beyond
Date: 2024-06-17
*/


/*Obtain a list of active incumbents, with some restrictions*/
SELECT *
-- Subquery due to DISTINCT not being able to be applied 
FROM (

SELECT
	-- Due to a cartesian product from cross join, distinct is needed to prevent duplicates
	DISTINCT ON (candidate.candidate_id)
	candidate.candidate_id,
	(CASE 
		WHEN candidate.candidatepreferredname_id = 'F' THEN candidate.firstname
		WHEN candidate.candidatepreferredname_id = 'N' THEN candidate.nickname
		WHEN candidate.candidatepreferredname_id = 'M' THEN candidate.middlename
	END) as "firstname",
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
	-- Show only Active Incumbents and an incumbent that is marked inactive
	(officecandidatestatus_id = 1 OR candidate_id=171843)
	AND
	office_candidate.office_id IN (5,6)
	AND
	-- Some candidate are in office for more than one parties, these are the following:
	party.name NOT IN ('Conservative', 'Working Families')
	AND 
	-- Exclude delegates
	office_candidate.state_id NOT IN ('AS','DC','GU','MP','VI','PR')
	AND
	-- Exclude recently added incumbent, to be marked as vacant
	candidate_id != 169357

) A

ORDER BY A.office DESC, A.state, A.lastname;