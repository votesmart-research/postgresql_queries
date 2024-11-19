/*
Author: Johanan Tai
Description: Shows all ratings entries of a SIG
*/


SELECT 
	rating_id,
	span,
	rating.name AS rating_name,
	rating_candidates.count AS candidates_rated,
	ratingformat.name AS format,
	ratingsession.name AS session,
	release.name AS release_status,
	created,
	modified

FROM rating

/*subquery gets number of candidates per rating entry*/
LEFT JOIN (
	SELECT
		rating_id,
		COUNT(*)
	FROM rating_candidate
	GROUP BY rating_id
	) rating_candidates

	USING (rating_id)

LEFT JOIN ratingformat USING (ratingformat_id)
LEFT JOIN ratingsession USING (ratingsession_id)
LEFT JOIN release USING (release_id)

/*change to the appropriate sig_id*/
WHERE sig_id = 1734J

ORDER BY 
	span DESC,
	rating_id DESC