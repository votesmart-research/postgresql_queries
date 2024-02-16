/*
Author: Johanan Tai
Description: Shows endorsed candidates by endorse_id
*/


SELECT
	election_candidate.candidate_id,
	CONCAT_WS(', ',
		candidate.lastname,
		candidate.firstname
	) AS candidate_name,
	state.name AS state,
	office.name AS office,
	districtname.name AS district

FROM endorse_candidate

JOIN election_candidate USING (election_candidate_id)
LEFT JOIN state ON election_candidate.state_id = state.state_id
LEFT JOIN office ON election_candidate.office_id = office.office_id
LEFT JOIN districtname ON election_candidate.districtname_id =
							districtname.districtname_id
LEFT JOIN candidate ON election_candidate.candidate_id =
						candidate.candidate_id

/*change to the appropriate endorse_id*/
WHERE endorse_candidate.endorse_id = 1234

ORDER BY
	office.name,
	/* Numbers as strings orders by the first digits */
	NULLIF(REGEXP_REPLACE(districtname.name, '\D', '', 'g'), '')::INT