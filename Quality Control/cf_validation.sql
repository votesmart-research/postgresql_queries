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
		WHERE finsource_id = 2
		GROUP BY candidate_id
		HAVING COUNT(code) > 1
	)
AND
	finsource_id = 2
ORDER BY 
	code, 
	finsource_candidate_id DESC;


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


SELECT * FROM finsource_candidate WHERE code LIKE ' %';

-- Remove leading space from the code column
UPDATE finsource_candidate
SET code = TRIM(LEADING ' ' FROM code)
WHERE code LIKE ' %';

