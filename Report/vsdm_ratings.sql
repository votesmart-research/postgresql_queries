/*
Author: Johanan Tai
Description: These are the queries for the purpose of getting Special Interest Group (SIGS) data for 2024 VSDM and beyond
Date: 2024-06-17
*/


WITH EnumeratedRatings AS (
	SELECT
		rating_id,
		rating.name,
		-- Here, the ratings are ordered by the latest ratings first, and enumerates it as such
		ROW_NUMBER() OVER (PARTITION BY sig_id ORDER BY CAST(REGEXP_REPLACE(rating.span, '^.*(\d{4})$', '\1') AS INTEGER) DESC) AS enumerated
	
	FROM rating
	WHERE
		-- Shows all ratings from these SIG by sig_id except for the NRA
		sig_id IN (252,1578,2167,1015,1985,2061,1744,1378,164,2526,310,599,2407,1012,1161,959)
		AND NOT (rating.name LIKE 'Lifetime%') 
		AND NOT (rating.name LIKE 'Candidate%')
		
), NRARatings AS (
	SELECT 
		rating_id,
		rating.span
	FROM rating
	WHERE
		sig_id = 1034
		AND
		-- Get all ratings from NRA 2018 onwards
		CAST(REGEXP_REPLACE(rating.span, '(\d{4}).*$', '\1') AS INTEGER) >= 2018
		
	ORDER BY CAST(REGEXP_REPLACE(rating.span, '(\d{4}).*$', '\1') AS INTEGER) DESC
)



SELECT
	candidate_id,
	rating.sig_id,
	VSDMRatingCandidates.rating_id,
	VSDMRatingCandidates."Year(s) of Ratings",
	VSDMRatingCandidates.our_rating AS "Rated (%)",
	candidate.firstname AS "First Name",
	candidate.lastname AS "Last Name",
	office.name AS "Office",
	state.name AS "State",
	districtname.name AS "District",
	party.name as "Party"

FROM office_candidate

JOIN (
	SELECT 
		rating_candidate.candidate_id,
		rating_candidate_id,
		rating_id,
		rating.span AS "Year(s) of Ratings",
		rating_candidate.our_rating
	
	FROM rating_candidate
	JOIN rating USING (rating_id)
	
	WHERE rating_id IN (
			-- Only select the rating_id that were mentioned above
	        SELECT rating_id FROM EnumeratedRatings WHERE enumerated <= 1
	        UNION ALL
	    	SELECT rating_id FROM NRARatings
		)

	) VSDMRatingCandidates USING (candidate_id)

-- Left join to prevent unintended omission of candidates due to not being found on these tables*/
LEFT JOIN rating ON VSDMRatingCandidates.rating_id = rating.rating_id
LEFT JOIN candidate USING (candidate_id)
LEFT JOIN office ON office_candidate.office_id = office.office_id
LEFT JOIN office_candidate_party ON office_candidate.office_candidate_id = office_candidate_party.office_candidate_id
LEFT JOIN districtname ON office_candidate.districtname_id = 
							districtname.districtname_id
LEFT JOIN party ON office_candidate_party.party_id = party.party_id
LEFT JOIN state ON office_candidate.state_id = state.state_id


WHERE
	-- Narrow down the results as some SIG have a larger coverage
	office_candidate.office_id IN (5,6)

-- Arrange by rating.span to show the latest rating first, VLOOKUP always takes the first one it finds
ORDER BY 
	office.name, 
	state.name, 
	NULLIF(REGEXP_REPLACE(districtname.name, '\D', '', 'g'), '')::INT,
	candidate_id,
	sig_id, 
	CAST(REGEXP_REPLACE(rating.span, '(\d{4}).*$', '\1') AS INTEGER) DESC,
	CAST(REGEXP_REPLACE(rating.span, '^.*(\d{4})$', '\1') AS INTEGER) DESC;



/* Sanity check: Check the order of rating.span*/
SELECT CAST(REGEXP_REPLACE(columns, '^.*(\d{4})$', '\1') AS INTEGER) AS columns FROM unnest(ARRAY['2022', '2018-2024', '2023']) AS columns ORDER BY columns DESC;

SELECT * FROM rating_candidate JOIN rating USING (rating_id) WHERE candidate_id=2572 AND sig_id=1744 AND rating.name NOT LIKE 'Lifetime%' ORDER BY span DESC; 
