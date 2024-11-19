/*
Author: Johanan Tai
Description: Shows endorsed candidates by sig_id, year and office. This is typically
			 used to check for congressional endorsements.
*/


SELECT
	DISTINCT ON (election.electionyear, state.name, candidate_info.office, candidate_info.candidate_id)
	endorse_candidate.endorse_candidate_id,
	candidate_info.candidate_id,
	candidate_info.firstname,
	candidate_info.lastname,
	election.electionyear,
	CASE
		WHEN election.special IS True
		THEN CONCAT_WS(' ', state.name, '(Special)')
		ELSE state.name
	END AS state_election,
	state.state_id,
	candidate_info.office,
	candidate_info.district,
	candidate_info.created,
	endorse_id
	
	

FROM endorse_candidate
JOIN endorse USING (endorse_id)

/*left join a subquery for a cleaner code arrangement,
the subquery gets candidate info*/
LEFT JOIN (
	SELECT
		candidate_id,
		election_candidate_id,
		candidate.lastname,
		candidate.firstname,
		office.name AS office,
		districtname.name AS district,
		election_candidate.created
	
	FROM election_candidate
	LEFT JOIN candidate USING (candidate_id)
	LEFT JOIN office ON election_candidate.office_id = office.office_id
	LEFT JOIN districtname ON election_candidate.districtname_id =
							  districtname.districtname_id
	) candidate_info
	
	ON endorse_candidate.election_candidate_id = 
	   candidate_info.election_candidate_id

JOIN election ON endorse.election_id = election.election_id
LEFT JOIN officetype ON election.officetype_id = officetype.officetype_id
LEFT JOIN state ON election.state_id = state.state_id

WHERE
	/*change to the appropriate sig_idy*/
	endorse.sig_id IN (3021)
	/*change to the appropriate election year(s)*/
	AND election.electionyear = ANY('{2024}')
--	AND
	/*change to appropriate office types*/
--	officetype.name SIMILAR TO('%Congressional%|%Legislative%')
	
ORDER BY
	election.electionyear DESC,
	state.name,
	candidate_info.office;
	/* Numbers as strings orders by the first digits */
--	NULLIF(REGEXP_REPLACE(candidate_info.district, '\D', '', 'g'), '')::INT