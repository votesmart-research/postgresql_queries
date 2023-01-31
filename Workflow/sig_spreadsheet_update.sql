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
	E.recent_endorsement

FROM sig
JOIN release USING (release_id)


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
	) E

	USING (sig_id)
	)
	
USING (sig_id)