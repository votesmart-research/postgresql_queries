/*
Author: Johanan Tai
Description: Queries candidate ratings during the year(s) when they ran for election.
*/


/*change 'selected_rating_id' to the appropriate rating_id*/
WITH local_var AS (
	SELECT 12345 AS selected_rating_id
	)

SELECT
	candidate.candidate_id,
	election_candidate.state_id,
	candidate.firstname,
	candidate.lastname,
	rating_candidate.sig_rating,
	rating_candidate.our_rating,
	office.name AS office,
	districtname.name AS district

FROM (
	SELECT
		rating_info.candidate_id,
		/*gets the latest election*/
		MAX(election_candidate.election_candidate_id) AS election_candidate_id

	FROM election_candidate
	JOIN election USING (election_id)
	
	/*join with this subquery to get the span of ratings*/
	FULL OUTER JOIN (
		SELECT
			candidate_id,
			rating.span
		FROM rating_candidate
		JOIN rating USING (rating_id)
		CROSS JOIN local_var
		WHERE rating_id = local_var.selected_rating_id
		) rating_info
		ON rating_info.candidate_id = 
			election_candidate.candidate_id
	WHERE
		/*sometimes the rating is within a span of a few years,
		this case expression allows the selection of multiple election years */
		CASE
			WHEN LENGTH(rating_info.span) > 4
				THEN
				election.electionyear IN (
					SELECT *
					FROM
						GENERATE_SERIES(
							CAST(SPLIT_PART(rating_info.span,'-',1) AS INT),
							CAST(SPLIT_PART(rating_info.span,'-',2) AS INT)
							)
					)
				ELSE
				election.electionyear = CAST(rating_info.span AS INTEGER)
		END
		OR
		/*to include candidates that are not in the election candidate table*/
		election_candidate.candidate_id IS NULL
		OR
		/*to include candidates that are not in the current selected rating entry*/
		rating_info.candidate_id IS NULL

	GROUP BY rating_info.candidate_id
	) rated_election_candidate

/*join with this subquery to get rating info specific to the candidate*/
RIGHT JOIN (
	SELECT
		candidate_id,
		sig_rating,
		our_rating
	FROM rating_candidate
	CROSS JOIN local_var
	WHERE rating_id = local_var.selected_rating_id
	) rating_candidate 
	ON rated_election_candidate.candidate_id =
		rating_candidate.candidate_id

LEFT JOIN candidate ON rating_candidate.candidate_id = 
						candidate.candidate_id
						
LEFT JOIN election_candidate ON rated_election_candidate.election_candidate_id =
								election_candidate.election_candidate_id
								
LEFT JOIN office ON election_candidate.office_id = office.office_id
LEFT JOIN districtname ON election_candidate.districtname_id = 
							districtname.districtname_id

/*Directional join creates null values, comment this out if you want only candidates 
with office, district, and state information*/
WHERE rated_election_candidate.election_candidate_id IS NOT NULL

ORDER BY
	office,
	state_id,
	district,
	candidate.lastname