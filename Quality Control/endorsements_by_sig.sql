/*
Author: Johanan Tai
Description: Shows all endorsement entries of a SIG
*/


SELECT
	endorse.sig_id,
	endorse.endorse_id, 
	election_info.election_name,
	endorse_candidate.count AS candidates_endorsed,
	release.name AS release_status,
	created,
	modified

FROM endorse

/*counts the number of candidates in an endorsement entry*/
LEFT JOIN (
	SELECT
        endorse_id, 
		COUNT(*)
	FROM endorse_candidate
	GROUP BY endorse_id
	) endorse_candidate

	ON endorse.endorse_id = endorse_candidate.endorse_id

/*left join a subquery for a cleaner code arrangement,
the subquery gets election info*/
LEFT JOIN (
	SELECT 	
        election_id,
        CONCAT_WS(' ',
            state.name,
            officetype.name,
            CASE 
                WHEN 
                election.special is True 
                AND district.districtname_id IS NOT NULL
                    THEN 'Special'
                ELSE NULL
            END,
            CASE 
                WHEN election.special is True THEN 
                    CONCAT('District ', district.districtname_id)
                ELSE NULL
            END,
            electionyear
        ) AS election_name,
        electionyear,
        election.officetype_id
	FROM election
	JOIN state USING (state_id)
	JOIN officetype USING (officetype_id)
	LEFT JOIN election_districtname district USING (election_id)
	) election_info

	ON endorse.election_id = election_info.election_id

LEFT JOIN release USING (release_id)
LEFT JOIN officetype ON officetype.officetype_id = election_info.officetype_id

/*change to the appropriate sig_idy*/
WHERE 
sig_id = 2473
/*change to the appropriate election year(s)*/
--AND electionyear = ANY('{2022}')
--AND officetype.name SIMILAR TO('%Statewide%')
/*change the dates of when the endorsements was created or modified */
--AND (endorse.created >= '2024-08-05' OR endorse.modified >= '2024-08-05')

ORDER BY 
    election_info.electionyear DESC, 
	election_info.officetype_id,
	election_info.election_name