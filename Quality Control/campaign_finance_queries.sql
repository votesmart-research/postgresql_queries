SELECT * FROM finsource;

-- Find all OpenSecrets code
SELECT COUNT(*) FROM finsource_candidate WHERE finsource_id = 1;


-- Find OpenSecrets code that is shared by than more than one candidate
SELECT 
	code, 
	array_agg(candidate_id)
FROM 
	finsource_candidate
WHERE 
	finsource_id = 1
GROUP BY 
	code
HAVING 
	COUNT(candidate_id) > 1;


-- Find count of candidates that have more than one OpenSecrets code;
SELECT 
	candidate_id
FROM 
	finsource_candidate
WHERE 
	finsource_id = 1
GROUP BY 
	candidate_id
HAVING COUNT(code) > 1;


-- Find count of candidates that have more than one distinct OpenSecrets code;
SELECT 
    candidate_id
FROM 
    finsource_candidate
WHERE 
    finsource_id = 1
GROUP BY 
    candidate_id
HAVING 
    COUNT(DISTINCT code) > 1;



-- Get the list of all candidates and their finsource associations that have more than one Open Secrets code;
SELECT 
	candidate_id, 
	finsource_candidate_id, 
	code, 
	created, 
	modified, 
	updated
FROM 
	finsource_candidate
WHERE 
	candidate_id IN (
		SELECT candidate_id
		FROM finsource_candidate
		WHERE finsource_id = 1
		GROUP BY candidate_id
		HAVING COUNT(code) > 1
	)
AND
	finsource_id = 1
ORDER BY 
	code, 
	finsource_candidate_id DESC;


SELECT *

FROM finsource_candidate

WHERE candidate_id = 769;



-- Enumerate the candidates that has more than one OpenSecrets
SELECT 
    candidate_id, 
    finsource_candidate_id,
    code,
    created,
    updated,
    modified,
    ROW_NUMBER() OVER (PARTITION BY candidate_id ORDER BY finsource_candidate_id ASC) AS row_number
FROM 
    finsource_candidate
WHERE    
    finsource_id = 4
    
ORDER BY candidate_id;


-- Select all the older finsource_candidate entries for candidate who has more than one OpenSecrets code
WITH CandWMoreThanOneCode AS (
    SELECT 
        candidate_id
    FROM 
        finsource_candidate
    WHERE 
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
	    finsource_id = 1
)

SELECT 
    candidate_id, 
    finsource_candidate_id,
    code
FROM 
    EnumeratedCandidates
WHERE 
    row_number = 1
AND 
    candidate_id IN (SELECT candidate_id FROM CandWMoreThanOneCode)
ORDER BY 
    candidate_id;



WITH CandWMoreThanOneCode AS (
    SELECT 
        candidate_id
    FROM 
        finsource_candidate
    WHERE
    	-- May change according to each finsource institution (1=CRP, 2=FEC, 4=NIMSP)
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
		-- May change according to each finsource institution (1=CRP, 2=FEC, 4=NIMSP)
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

SELECT *

FROM finsource;