/*
Author: Johanan Tai
Description: Reports the number of rating entries made within a certain date range 
*/


WITH local_var AS (
	SELECT 
		'2023-01-01'::DATE AS start_date,
		'2023-01-31'::DATE AS end_date
)

SELECT 
	COUNT(A.*) AS "Rating Entries", 
	SUM(A.candidates_rated) AS "Total Candidates Rated"

FROM (
	SELECT 
		rating.rating_id, 
		COUNT(rating_candidate.rating_candidate_id) AS candidates_rated,
		rating.created,
		rating.modified

	FROM rating
	LEFT JOIN rating_candidate USING (rating_id)
	
	WHERE rating_candidate_id IS NOT NULL
	
	GROUP BY rating_id
	) A
	
CROSS JOIN local_var
WHERE A.created BETWEEN local_var.start_date AND local_var.end_date