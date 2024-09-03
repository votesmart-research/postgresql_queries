WITH CandWMoreThanOneCode AS (
    SELECT 
        candidate_id
    FROM 
        finsource_candidate
    WHERE 
    -- IMPORTANT: Change this to 1 or 4 for OpenSecrets and NIMSP (followthemoney) respectively (ONE AT A TIME)
        finsource_id = 1
    GROUP BY 
        candidate_id
    HAVING 
        COUNT(code) > 1
),
EnumeratedCandidates AS (
	SELECT 
	    candidate_id, 
	    finsource_candidate_id,
	    code,
		-- The oldest finsource_candidate would be enumerated as the first row	    
	    ROW_NUMBER() OVER (PARTITION BY candidate_id ORDER BY finsource_candidate_id ASC) AS row_number
	FROM 
	    finsource_candidate
	WHERE 
    -- Change this to 1 or 4 for OpenSecrets and NIMSP (followthemoney) respectively, has to be the same as the above change
	    finsource_id = 1
)


DELETE FROM 
    finsource_candidate
WHERE 
    finsource_candidate_id IN (
        SELECT 
            finsource_candidate_id
        FROM 
            EnumeratedCandidates
        WHERE 
            row_number = 1
        AND 
            candidate_id IN (SELECT candidate_id FROM CandWMoreThanOneCode)
    );

