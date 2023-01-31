/*
Author: Johanan Tai
Description: Shows endorsed candidates by sig_id, year and office. This is typically
			 used to check congressional endorsements.
*/


SELECT
	candidate_info.candidate_id,
	candidate_info.candidate_name,
	CASE
		WHEN election.special IS True
		THEN CONCAT_WS(' ', state.name, '(Special)')
		ELSE state.name
	END AS state_election,
	candidate_info.office,
	candidate_info.district,
	endorse_id
	

FROM endorse_candidate
JOIN endorse USING (endorse_id)

/*left join a subquery for a cleaner code arrangement,
the subquery gets candidate info*/
LEFT JOIN (
	SELECT
		candidate_id,
		election_candidate_id,
		CONCAT_WS(', ',
		  	candidate.lastname,
			candidate.firstname
		) AS candidate_name,
		office.name AS office,
		districtname.name AS district
	
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
	endorse.sig_id = 1034
	AND 
	election.electionyear = 2022
	AND
	officetype.name LIKE '%Congressional%'
	
ORDER BY
	state.name,
	candidate_info.office,
	NULLIF(REGEXP_REPLACE(candidate_info.district, '\D', '', 'g'), '')::INT