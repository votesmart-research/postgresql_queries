/*
Author: Johanan Tai
Description: Queries office candidates (incumbents) by their legislative session.
*/


WITH local_var AS (
    SELECT '2023-01-03'::DATE AS termstarts,
		   '2025-01-03'::DATE AS termends
)

SELECT
    /*Due to a cartesian product from cross join, distinct is needed to prevent duplicates*/
    DISTINCT ON (candidate.candidate_id)
    candidate.candidate_id,
    candidate.firstname,
    candidate.nickname,
    candidate.middlename,
    candidate.lastname,
    candidate.suffix,
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

JOIN congstatus_candidate USING (office_candidate_id)
JOIN congstatus ON congstatus_candidate.congstatus_id = congstatus.congstatus_id

CROSS JOIN local_var

WHERE 
    congstatus.statusdate BETWEEN local_var.termstarts and local_var.termends
    
    /* =ANY() is IN() */
    /*change this to the appropriate office_id(s) or office_type_id(s)*/
    AND (
        office_candidate.office_id = ANY('{5,6}')
        OR office.officetype_id = ANY('{P,L}')
    )

    /*comment this out if the candidates are not state specific, 
    eg. Presidential, or all of congress*/
    AND office_candidate.state_id = ANY('{AL,IA,NA,WY}')
