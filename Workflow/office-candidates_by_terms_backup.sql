/*
Author: Johanan Tai
Description: Queries office candidates (incumbents) by the start to the end of their terms, 
			 this serves as a backup to another query that does practically the same thing
*/


WITH local_var AS (
    SELECT 2022 AS active_year,
           1789 AS where_it_begins
)

SELECT
	/*Due to a cartesian product from cross join, distinct is needed to prevent duplicates*/
	DISTINCT
	candidate.candidate_id,
	candidate.firstname,
	candidate.nickname,
	candidate.middlename,
	candidate.lastname,
	candidate.suffix,
	office.name AS office,
	state.name AS state,
	state.state_id AS state_id,
	districtname.name AS district,
	party.name AS party

FROM office_candidate
JOIN candidate USING (candidate_id)

LEFT JOIN office USING (office_id)
LEFT JOIN state ON office_candidate.state_id = state.state_id
LEFT JOIN districtname USING (districtname_id)
LEFT JOIN office_candidate_party USING (office_candidate_id)
LEFT JOIN party ON office_candidate_party.party_id = party.party_id

CROSS JOIN local_var

WHERE 
	(
		(local_var.active_year BETWEEN EXTRACT(year FROM to_date(termstart,'mm/dd/yyyy'))
								AND EXTRACT(year FROM to_date(termend, 'mm/dd/yyyy'))            
			AND EXTRACT(year FROM to_date(termstart, 'mm/dd/yyyy')) >= local_var.where_it_begins)

		OR (local_var.active_year BETWEEN EXTRACT(year FROM to_date(termstart,'mm/yyyy'))
									AND EXTRACT(year FROM to_date(termend, 'mm/yyyy'))
				AND EXTRACT(year FROM to_date(termstart, 'mm/yyyy')) >= local_var.where_it_begins)

		OR (local_var.active_year BETWEEN EXTRACT(year FROM to_date(termstart,'yyyy'))
									AND EXTRACT(year FROM to_date(termend, 'yyyy'))
				AND EXTRACT(year FROM to_date(termstart, 'yyyy')) >= local_var.where_it_begins)

		OR (local_var.active_year BETWEEN EXTRACT(year FROM to_date(termstart,'mm/dd/yyyy'))
									AND EXTRACT(year FROM CASE WHEN termend ISNULL THEN now() END)
				AND EXTRACT(year FROM to_date(termstart, 'mm/dd/yyyy')) >= local_var.where_it_begins)

		OR (local_var.active_year BETWEEN EXTRACT(year FROM to_date(termstart,'mm/yyyy'))
									AND EXTRACT(year FROM CASE WHEN termend ISNULL THEN now() END)
				AND EXTRACT(year FROM to_date(termstart, 'mm/yyyy')) >= local_var.where_it_begins)

		OR (local_var.active_year BETWEEN EXTRACT(year FROM to_date(termstart,'yyyy'))
									AND EXTRACT(year FROM CASE WHEN termend ISNULL THEN now() END)
				AND EXTRACT(year FROM to_date(termstart, 'yyyy')) >= local_var.where_it_begins)
	)

	/*
	Other than termstart/termend, office id(s), office type(s) and state(s) 
	are also considered for futher refinement.
	*/
	AND (office.office_id IN (5,6)
			OR office.officetype_id IN (''))

	-- AND office_candidate.state_id IN ('')
