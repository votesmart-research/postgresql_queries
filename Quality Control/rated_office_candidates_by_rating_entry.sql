/*
Author: Johanan Tai
Description: Queries candidate ratings during the year(s) when they were in office.
*/


/*change 'selected_rating_id' to the appropriate rating_id*/
WITH local_var AS (
	SELECT 12345 AS selected_rating_id
	)

SELECT
	candidate.candidate_id,
	office_candidate.state_id,
	candidate.firstname,
	candidate.lastname,
	rating_candidate.sig_rating,
	rating_candidate.our_rating,
	office.name AS office,
	districtname.name AS district
	
FROM (

	SELECT
		rating_info.candidate_id,
		/*gets the oldest election*/
		MIN(office_candidate_id) AS office_candidate_id

	FROM office_candidate

	/*join with this subquery in order to get the span of ratings*/
	FULL OUTER JOIN (
		SELECT
			candidate_id,
			rating.span

		FROM rating_candidate
		JOIN rating USING (rating_id)
		CROSS JOIN local_var
		WHERE rating_id = local_var.selected_rating_id
        ) rating_info USING (candidate_id)

	WHERE
		(
			termstart IS NOT NULL
			AND
			/*sometimes the rating is within a span of a few years,
			this case expression allows the office terms to be 
			in between the span of multiple years */
			(
			CASE
			WHEN LENGTH(rating_info.span) > 4
				THEN
				(
					EXTRACT(YEAR FROM to_date(termend, 'mm/dd/yyyy')) >= 
						CAST(SPLIT_PART(rating_info.span,'-',1) AS INT)

					OR EXTRACT(YEAR FROM to_date(termend, 'mm/yyyy')) >= 
						CAST(SPLIT_PART(rating_info.span,'-',1) AS INT)

					OR EXTRACT(YEAR FROM to_date(termend, 'yyyy')) >= 
						CAST(SPLIT_PART(rating_info.span,'-',1) AS INT)

					OR CASE 
						WHEN termend IS NULL 
							THEN EXTRACT(YEAR FROM NOW()) >= 
							CAST(SPLIT_PART(rating_info.span,'-',1) AS INT)
						END
				)
				AND
				(
					EXTRACT(YEAR FROM to_date(termstart, 'mm/dd/yyyy')) <=
						CAST(SPLIT_PART(rating_info.span,'-',2) AS INT)

					/* converting a full date ('mm/dd/yyyy') by partial match ('mm/yyyy' or 'yyyy') 
					would turn it into a smaller date, so the smaller date has to be larger than the
					termstart*/
					OR(EXTRACT(YEAR FROM to_date(termstart, 'mm/yyyy')) <=
							CAST(SPLIT_PART(rating_info.span,'-',2) AS INT)
						AND EXTRACT(YEAR FROM to_date(termstart, 'mm/yyyy')) > 1000)

					OR(EXTRACT(YEAR FROM to_date(termstart, 'yyyy')) <=
							CAST(SPLIT_PART(rating_info.span,'-',2) AS INT)
						AND EXTRACT(YEAR FROM to_date(termstart, 'yyyy')) > 1000)
				)
				ELSE
				(
					EXTRACT(YEAR FROM to_date(termend, 'mm/dd/yyyy')) >= 
						CAST(rating_info.span AS INT)

					OR EXTRACT(YEAR FROM to_date(termend, 'mm/yyyy')) >= 
						CAST(rating_info.span AS INT)

					OR EXTRACT(YEAR FROM to_date(termend, 'yyyy')) >= 
						CAST(rating_info.span AS INT)

					OR CASE 
						WHEN termend IS NULL 
							THEN EXTRACT(YEAR FROM NOW()) >= 
							CAST(rating_info.span AS INT)
						END
				)
				AND
				(
					EXTRACT(YEAR FROM to_date(termstart, 'mm/dd/yyyy')) <=
						CAST(rating_info.span AS INT)

					OR(EXTRACT(YEAR FROM to_date(termstart, 'mm/yyyy')) <=
							CAST(rating_info.span AS INT)
						AND EXTRACT(YEAR FROM to_date(termstart, 'mm/yyyy')) > 1000)

					OR(EXTRACT(YEAR FROM to_date(termstart, 'yyyy')) <=
							CAST(rating_info.span AS INT)
						AND EXTRACT(YEAR FROM to_date(termstart, 'yyyy')) > 1000)
				)
			END
			)
		)
		OR
		/*to include candidates that are not in the office candidate table*/
		office_candidate.candidate_id IS NULL
		OR
		/*to include candidates that are not in the current selected rating entry*/
		rating_info.candidate_id IS NULL

	GROUP BY rating_info.candidate_id
	
	) rated_office_candidate

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
	
	ON rated_office_candidate.candidate_id =
		rating_candidate.candidate_id

LEFT JOIN candidate ON rating_candidate.candidate_id =
						candidate.candidate_id
LEFT JOIN office_candidate ON rated_office_candidate.office_candidate_id = 
								office_candidate.office_candidate_id
LEFT JOIN office ON office_candidate.office_id = office.office_id
LEFT JOIN districtname ON office_candidate.districtname_id = 
							districtname.districtname_id

/*Directional join creates null values, comment this out if you want only candidates 
with office, district, and state information*/
WHERE rated_office_candidate.office_candidate_id IS NOT NULL

ORDER BY
	office,
	state_id,
	district,
	candidate.lastname