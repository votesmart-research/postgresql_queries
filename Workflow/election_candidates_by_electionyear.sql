/*
Author: Johanan Tai
Description: Queries candidates running for an election of a certain year, office, and state.
*/


SELECT
	DISTINCT ON (candidate.candidate_id)
    candidate.candidate_id,
    candidate.firstname,
    candidate.nickname,
    candidate.middlename,
    candidate.lastname,
    candidate.suffix,
    election.electionyear,
    office.name AS office,
    state.name AS state_name,
    state.state_id AS state_id,
    districtname.name AS district,
    party.name AS party,
    election_electionstage.electionstage_id 

FROM election_candidate

JOIN candidate USING (candidate_id)
JOIN election USING (election_id)

/*left join to assume data entry error*/
LEFT JOIN office USING (office_id)
LEFT JOIN state ON election.state_id = state.state_id
LEFT JOIN districtname USING (districtname_id)

JOIN electionstage_candidate USING (election_candidate_id)
JOIN election_electionstage ON electionstage_candidate.election_electionstage_id =
                                    election_electionstage.election_electionstage_id
JOIN electionstage_candidate_party ON electionstage_candidate.electionstage_candidate_id = 
                                           electionstage_candidate_party.electionstage_candidate_id
LEFT JOIN party ON electionstage_candidate_party.party_id = party.party_id


WHERE 
    /* =ANY() is IN() */
    /*change to the appropriate election year(s)*/
    election.electionyear = 2024

    /*change to the appropriate election stages*/
    AND election_electionstage.electionstage_id = ANY('{G, P}')

    /*change this to the appropriate office_id(s) or office type(s)*/
    AND (
        office.office_id = ANY('{5,6}')
        OR office.officetype_id = ANY('{P,L}')
    )
    
    /*comment this out if the candidates are not state specific, 
    eg. Presidential, or all of congress*/
    AND election_candidate.state_id = ANY('{AL,IA,NA,WY}')