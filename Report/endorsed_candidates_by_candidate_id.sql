SELECT 
	electionyear, 
	sig.sig_id, 
	sig.name, 
	endorse.created,
	endorse.modified
	
FROM endorse_candidate

JOIN endorse USING (endorse_id)
JOIN sig USING (sig_id)
JOIN election_candidate USING (election_candidate_id)
JOIN election ON election.election_id = election_candidate.election_id

WHERE 
	electionyear = 2024
	AND
	-- Kamala = 120012
	candidate_id = 15723

ORDER BY endorse.modified DESC;
