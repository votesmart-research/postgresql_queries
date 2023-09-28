/*
Author: Johanan Tai
Description: Queries candidates running for an election of a certain year, office, and state.
*/


SELECT
    candidate.candidate_id,
    candidate.firstname,
    candidate.nickname,
    candidate.middlename,
    candidate.lastname,
    candidate.suffix,
    office.name AS office,
    state.name AS state_name,
    state.state_id AS state_id,
    districtname.name AS district,
    party.name AS party

FROM election_candidate

JOIN candidate USING (candidate_id)
JOIN election USING (election_id)

/*left join to assume data entry error*/
LEFT JOIN office USING (office_id)
LEFT JOIN state ON election.state_id = state.state_id
LEFT JOIN districtname USING (districtname_id)
LEFT JOIN electionstage_candidate USING (election_candidate_id)
LEFT JOIN election_electionstage ON electionstage_candidate.election_electionstage_id =
                                    election_electionstage.election_electionstage_id
LEFT JOIN electionstage_candidate_party ON electionstage_candidate.electionstage_candidate_id = 
                                           electionstage_candidate_party.electionstage_candidate_id
LEFT JOIN party ON electionstage_candidate_party.party_id = party.party_id


WHERE 
    election.electionyear IN (2023)

    AND election_electionstage.electionstage_id IN ('G','P')

    AND (office.office_id IN (5,6)
        OR office.officetype_id IN (''))
    
    -- AND election_candidate.state_id IN ('')