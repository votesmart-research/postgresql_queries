/*
Author: Johanan Tai
Description: Queries office candidates (incumbents) by the start to the end of their terms
*/


WITH local_var AS (
    SELECT '2022-01-03'::DATE AS termstarts,
		   '2023-01-03'::DATE AS termends
)

SELECT
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

	/*
	Other than termstart/termend, office id(s), office type(s) and state(s) 
	are also considered for futher refinement.
	*/
	AND (office.office_id IN (5,6)
		OR office.officetype_id IN (''))
		
	-- AND office_candidate.state_id IN ('')
