SELECT
    /*Due to a cartesian product from cross join, distinct is needed to prevent duplicates*/
    DISTINCT ON (candidate.candidate_id)
    congstatus_candidate_id,
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

WHERE 
    congstatus_candidate.congstatus_id = 102130
    