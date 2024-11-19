/*
Author: Johanan Tai
Description: Queries the number of candidates rated by year, from the month before and to the day and month of the current date.
*/


SELECT 
    CAST(EXTRACT(year from created) AS INTEGER) AS year, 
    COUNT(rating_candidate_id) AS candidates_rated

FROM rating_candidate
JOIN rating USING (rating_id)

WHERE 
    /*exclude ratings from certain sigs, especially ones that are for testing, 
      you may add to the array if needed*/
    rating.sig_id <> ANY('{2571}')
    AND
    /*tracks all the candidates rated from before the month of the current date*/
    EXTRACT(MONTH FROM rating.created) < EXTRACT(MONTH FROM CURRENT_DATE)
        OR (
            /*tracks all the candidates rated from day starting from the month of the current date*/
            EXTRACT(MONTH FROM rating.created) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND 
            EXTRACT(DAY FROM rating.created) <= EXTRACT(DAY FROM CURRENT_DATE)
        )

GROUP BY EXTRACT(year from created)

ORDER BY Year DESC