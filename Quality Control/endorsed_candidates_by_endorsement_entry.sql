/*
Author: Johanan Tai
Description: Shows endorsed candidates by endorse_id
*/


SELECT
	election_candidate.candidate_id,
	election_candidate.election_candidate_id,
	election.electionyear,
	endorse_candidate.endorse_candidate_id,
	CONCAT_WS(', ',
		candidate.lastname,
		candidate.firstname
	) AS candidate_name,
	state.name AS state,
	office.name AS office,
	districtname.name AS district,
	election_candidate.created
	
FROM endorse_candidate

JOIN election_candidate USING (election_candidate_id)
LEFT JOIN election ON election.election_id = election_candidate.election_id
LEFT JOIN state ON election_candidate.state_id = state.state_id
LEFT JOIN office ON election_candidate.office_id = office.office_id
LEFT JOIN districtname ON election_candidate.districtname_id =
							districtname.districtname_id
LEFT JOIN candidate ON election_candidate.candidate_id =
						candidate.candidate_id

/*change to the appropriate endorse_id*/
WHERE endorse_candidate.endorse_id = 45159
ORDER BY
	office.name,
	endorse_candidate.endorse_candidate_id;
	/* Numbers as strings orders by the first digits */
--	NULLIF(REGEXP_REPLACE(districtname.name, '\D', '', 'g'), '')::INT;
	

SELECT * FROM endorse WHERE endorse_id = 38677;


