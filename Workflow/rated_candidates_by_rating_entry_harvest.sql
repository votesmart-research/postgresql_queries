/*
Author: Johanan Tai
Description: Pull ratings in the harvest format
*/


SELECT
	rating_candidate.candidate_id,
	rating_candidate.sig_rating,
	CASE 
		WHEN NOT(rating_candidate.our_rating IS NULL) THEN rating_candidate.sig_rating
		ELSE rating_candidate.our_rating
	END as our_rating,
    rating.span,
	CASE
		WHEN rating.usesigrating THEN 'f'
		ELSE 'f'
	END as usesigrating,
    rating.sig_id,
    rating.ratingsession_id as ratingsession,
    rating.ratingformat_id
    
FROM rating
JOIN rating_candidate USING (rating_id)

WHERE rating_id = 1234