/*
Author: Johanan Tai
Description: Queries office candidates (incumbents) by the start to the end of their terms
*/


WITH local_var AS (
    SELECT '2021-01-03'::DATE AS termstarts,
		   '2024-12-31'::DATE AS termends
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
    party.name AS party,
    CASE WHEN termstart IS NULL THEN 'yes' ELSE 'no' END

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
		(
			(
				to_date(termend, 'mm/dd/yyyy') > local_var.termstarts
				OR to_date(termend, 'mm/yyyy') > local_var.termstarts
				OR to_date(termend, 'yyyy') > local_var.termstarts
				OR CASE WHEN termend IS NULL THEN now() END > local_var.termstarts
			)
			AND 
			(
				to_date(termstart, 'mm/dd/yyyy') < local_var.termends
				/* converting a full date ('mm/dd/yyyy') by partial match ('mm/yyyy' or 'yyyy') 
				would turn it into a smaller date, so the smaller date has to be larger than the
				termstart*/
				OR (to_date(termstart, 'mm/yyyy') < local_var.termends
					AND to_date(termstart, 'mm/yyyy') > local_var.termstarts)
				OR (to_date(termstart, 'yyyy') < local_var.termends
					AND to_date(termstart, 'yyyy') > local_var.termstarts)
				OR (termstart IS NULL AND termend IS NOT NULL)
			)
		)
		OR
			termstart IS NULL AND termend IS NULL
			AND officecandidatestatus_id = 1 
			AND now() < local_var.termends
	)
	/*change this to the appropriate office_id(s) or office type(s)*/
	AND (
		office.office_id = ANY('{7,8,9}')
		OR office.officetype_id = ANY('{}')
	);
	
	/*comment this out if the candidates are not state specific, 
    eg. Presidential, or all of congress*/
--	AND office_candidate.state_id = ANY('{AL}');
	

SELECT *,
	CASE WHEN termend ISNULL THEN now() END > '2023-01-01',
	CASE WHEN termstart ISNULL THEN 
	CASE WHEN officecandidatestatus_id = 1 THEN now() END < '2024-12-31'
	END

FROM office_candidate

WHERE office_candidate.state_id = 'AL'
AND office_candidate.office_id = 8;
