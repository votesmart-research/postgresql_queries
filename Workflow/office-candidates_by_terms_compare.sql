/*
Author: Johanan Tai
Description: Comparing both incumbent queries to find differences in query results
*/


WITH local_var AS (
    SELECT '2022-01-03'::DATE AS termstarts,
           '2023-01-03'::DATE AS termends,
			2022 AS active_year,
            1789 AS where_it_begins
)

SELECT *

FROM 
	(SELECT
		/*Due to a cartesian product from cross join, distinct is needed to prevent duplicates*/
		DISTINCT
		office_candidate.office_candidate_id,
		termstart,
		termend,
		to_date(termstart, 'mm/dd/yyyy') AS termstart_trans,
		to_date(termend, 'mm/dd/yyyy') AS termend_trans,
		CASE WHEN termend IS NULL then now() END AS termend_now_case

	FROM office_candidate
	JOIN candidate USING (candidate_id)

	LEFT JOIN office USING (office_id)
	LEFT JOIN state ON office_candidate.state_id = state.state_id
	LEFT JOIN districtname USING (districtname_id)
	LEFT JOIN office_candidate_party USING (office_candidate_id)
	LEFT JOIN party ON office_candidate_party.party_id = party.party_id


	CROSS JOIN local_var

	WHERE
        NOT termstart ISNULL

		AND (to_date(termend, 'mm/dd/yyyy') > local_var.termstarts
			OR to_date(termend, 'mm/yyyy') > local_var.termstarts
			OR to_date(termend, 'yyyy') > local_var.termstarts
			OR CASE WHEN termend ISNULL THEN now() END > local_var.termstarts)

		AND (to_date(termstart, 'mm/dd/yyyy') < local_var.termends
			/* converting a full date ('mm/dd/yyyy') by partial match ('mm/yyyy' or 'yyyy') 
			would turn it into a smaller date, so the smaller date has to be larger than the
			termstart*/
			OR (to_date(termstart, 'mm/yyyy') < local_var.termends
				AND to_date(termstart, 'mm/yyyy') > local_var.termstarts)
			OR (to_date(termstart, 'yyyy') < local_var.termends
				AND to_date(termstart, 'yyyy') > local_var.termstarts))

		AND (office.office_id IN (5,6)
			 OR office.officetype_id IN (''))
	) a
	
	FULL OUTER JOIN

	(SELECT
		/*Due to a cartesian product from cross join, distinct is needed to prevent duplicates*/
		DISTINCT
		office_candidate.office_candidate_id,
	 	districtname.name AS district,
		termstart,
		termend,
		to_date(termstart, 'mm/dd/yyyy') AS termstart_trans,
		to_date(termend, 'mm/dd/yyyy') AS termend_trans,
		CASE WHEN termend IS NULL then now() END AS termend_now_case

	FROM office_candidate
	JOIN candidate USING (candidate_id)

	LEFT JOIN office USING (office_id)
	LEFT JOIN state ON office_candidate.state_id = state.state_id
	LEFT JOIN districtname USING (districtname_id)
	LEFT JOIN office_candidate_party USING (office_candidate_id)
	LEFT JOIN party ON office_candidate_party.party_id = party.party_id

	CROSS JOIN local_var

	WHERE (
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
		AND (office.office_id IN (5,6)
			OR office.officetype_id IN (''))
	) b
	
	ON a.office_candidate_id = b.office_candidate_id
	
	WHERE a.office_candidate_id ISNULL OR b.office_candidate_id ISNULL