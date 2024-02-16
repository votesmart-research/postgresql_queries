/*
Author: Johanan Tai
Description: List all SIGS to update spreadsheet for workflow purposes
*/


SELECT 
	sig.sig_id,
	sig.name AS sig_name,
	sig.state_id,
	sig.url, 
	release.name AS release_status,
	sig.ratinggroup,
	R.recent_rating,
	E.recent_endorsement,
	ARRAY_TO_STRING(C.cat_name,', ') AS "categories"

FROM sig
JOIN release ON sig.release_id = release.release_id

LEFT JOIN (
	/*this subquery gets the latest ratings*/
	(SELECT 
		sig_id, 
		MAX(rating.span) AS recent_rating
	FROM rating
	GROUP BY sig_id
	) R

	FULL OUTER JOIN (
		/*this subquery gets the latest endorsements*/
	SELECT 
		sig_id, 
		MAX(electionyear) AS recent_endorsement
	FROM endorse
	JOIN election USING (election_id)
	GROUP BY sig_id
	) E USING (sig_id)
	
) USING (sig_id)


LEFT JOIN (
	SELECT sig_id, 
		   ARRAY_AGG(category.name ORDER BY category.name) as cat_name

	FROM sig_category
	JOIN category USING (category_id)
	
	GROUP BY sig_id
	) C USING (sig_id)
