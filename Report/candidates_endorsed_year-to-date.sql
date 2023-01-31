/*
Author: Johanan Tai
Description: Queries the number of candidates endorsed by year, from the month before and to the day and month of the current date.
*/


SELECT 
    CAST(EXTRACT(year from created) AS INTEGER) AS year, 
    COUNT(endorse_candidate_id) AS candidates_endorsed

FROM endorse_candidate
JOIN endorse USING (endorse_id)

WHERE 
    /*tracks all the candidates endorsed from before the month of the current date*/
    EXTRACT(MONTH FROM endorse.created) < EXTRACT(MONTH FROM CURRENT_DATE)
    OR (
        /*tracks all the candidates endorsed from day starting from the month of the current date*/
        EXTRACT(MONTH FROM endorse.created) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND 
        EXTRACT(DAY FROM endorse.created) <= EXTRACT(DAY FROM CURRENT_DATE)
    )

GROUP BY EXTRACT(year from created)

ORDER BY Year DESC