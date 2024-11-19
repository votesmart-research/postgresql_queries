SELECT 
	speechtype.name, 
	COUNT(*) AS number_of_speech

FROM speech
JOIN speechtype USING (speechtype_id)

GROUP BY speechtype_id, speechtype.name

ORDER BY number_of_speech DESC;



SELECT *
FROM speechtype
ORDER BY speechtype_id; 


SELECT *

FROM speech
WHERE speechtype_id = 6

ORDER BY created
LIMIT 5;
