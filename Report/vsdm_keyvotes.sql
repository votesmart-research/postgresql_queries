
/*
Author: Johanan Tai
Description: These are the queries for the purpose of getting Key Votes data for 2024 VSDM and beyond
Date: 2024-06-17
*/


/*Main query here that runs and gets all keyvotes data pertaining to the selected bills that can be further re-model
using a spreadsheet.*/
WITH SelectedBillsAndCandidates AS (
	SELECT 
		congstatus_id, 
		congress_id,
		office_candidate_id,
		congress.billnumber,
		congtitle.title,
		congaction.code AS "Action Taken",
		CASE
		WHEN conglevel_id = 'H' THEN 'U.S. House'
		WHEN conglevel_id = 'S' THEN 'U.S. Senate'
		END AS "chamber"
		
	FROM 
		congstatus_candidate
	
	JOIN congstatus USING (congstatus_id)
	JOIN congress USING (congress_id)
	JOIN congtitle USING (congtitle_id)
	JOIN congaction USING (congaction_id)

	-- Bill selection starts
	WHERE congstatus_id IN (
		-- House Bills
		90338,
		90473,
		91184,
		91716,
		91855,
		92112,
		92114,
		92366,
		94919,
		95243,
		95273,
		96592,
		96799,
		97192,
		97347,

		-- Senate Bills
		84187,
		84822,
		85401,
		86183,
		87519,
		91319,
		92444,
		96788,
		99500,
		99560,
		99693,
		100190
	)
	-- Bill selection ends
)

SELECT 
	candidate_id,
	SelectedBillsAndCandidates.congstatus_id,
	SelectedBillsAndCandidates.congress_id,
	SelectedBillsAndCandidates.billnumber,
	SelectedBillsAndCandidates.chamber,
	SelectedBillsAndCandidates.title,
	SelectedBillsAndCandidates."Action Taken",
	candidate.firstname AS "First Name",
	candidate.lastname AS  "Last Name",
	office.name AS "Office",
	state.name AS "State",
	districtname.name as "District",
	party.name as "Party"

	
FROM office_candidate

JOIN SelectedBillsAndCandidates USING (office_candidate_id)
JOIN candidate USING (candidate_id)

LEFT JOIN office ON office_candidate.office_id = office.office_id
LEFT JOIN districtname ON office_candidate.districtname_id = districtname.districtname_id
LEFT JOIN state ON office_candidate.state_id = state.state_id
LEFT JOIN office_candidate_party ON office_candidate.office_candidate_id = office_candidate_party.office_candidate_id
LEFT JOIN party ON office_candidate_party.party_id = party.party_id

WHERE
	party.name NOT IN ('Conservative', 'Working Families');


-- Making a table of reference for the congstatus_id to the title, bill number and chamber.
SELECT 
	congstatus_id, 
	congress_id, 
	congress.billnumber, 
	congtitle.title,
	CASE
	WHEN conglevel_id = 'H' THEN 'U.S. House'
	WHEN conglevel_id = 'S' THEN 'U.S. Senate'
	END AS "chamber"
	
FROM congstatus
JOIN congress USING (congress_id)
JOIN congtitle USING (congtitle_id)
WHERE congstatus_id IN(
	--House bills
	90338,
	90473,
	91184,
	91716,
	91855,
	92112,
	92114,
	92366,
	94919,
	95243,
	95273,
	96592,
	96799,
	97192,
	97347,
		
	--Senate bills
	84187,
	84822,
	85401,
	86183,
	87519,
	91319,
	92444,
	96788,
	99500,
	99560,
	99693,
	100190
)
ORDER BY chamber, congstatus_id;



/* Below are queries that were deprecated with the presence of the above query. 
These queries pulls bills based on candidates and not the other way around, may exclude
actions that were made while in session of the bill.
*/

-- Get House Candidates
WITH USHouseCandidates AS (
    SELECT 
        office_candidate.office_candidate_id,
        candidate_id,
        office.name as "office",
        party.name as "party",
        state.name as "state",
        districtname.name as "district"
    FROM 
        office_candidate
        
    LEFT JOIN office ON office_candidate.office_id = office.office_id
    LEFT JOIN office_candidate_party ON office_candidate.office_candidate_id = office_candidate_party.office_candidate_id
    LEFT JOIN party ON office_candidate_party.party_id = party.party_id
    LEFT JOIN state ON office_candidate.state_id = state.state_id
    LEFT JOIN districtname ON office_candidate.districtname_id = districtname.districtname_id
    
    WHERE
        office_candidate.officecandidatestatus_id = 1
        AND
    	office.office_id = 5
        AND 
        office_candidate.state_id NOT IN ('AS','DC','GU','MP','VI','PR')
),
-- Only select the bills you need
SelectedHouseBills AS
	(
	SELECT
		office_candidate_id,
		MAX(CASE WHEN cs.congstatus_id = 90338 THEN ca.code END) AS "HR 26",
		MAX(CASE WHEN cs.congstatus_id = 90473 THEN ca.code END) AS "HR 497",
		MAX(CASE WHEN cs.congstatus_id = 91184 THEN ca.code END) AS "HR 5",
		MAX(CASE WHEN cs.congstatus_id = 91716 THEN ca.code END) AS "HR 734",
		MAX(CASE WHEN cs.congstatus_id = 91855 THEN ca.code END) AS "HR 2811",
		MAX(CASE WHEN cs.congstatus_id = 92112 THEN ca.code END) AS "HR 1163",
		MAX(CASE WHEN cs.congstatus_id = 92114 THEN ca.code END) AS "HR 2",
		MAX(CASE WHEN cs.congstatus_id = 92366 THEN ca.code END) AS "HR 467",
		MAX(CASE WHEN cs.congstatus_id = 94919 THEN ca.code END) AS "HR 1435",
		MAX(CASE WHEN cs.congstatus_id = 95243 THEN ca.code END) AS "HR 5692",
		MAX(CASE WHEN cs.congstatus_id = 95273 THEN ca.code END) AS "H Res 757",
		MAX(CASE WHEN cs.congstatus_id = 96592 THEN ca.code END) AS "H Res 894",
		MAX(CASE WHEN cs.congstatus_id = 96799 THEN ca.code END) AS "HR 2670",
		MAX(CASE WHEN cs.congstatus_id = 97192 THEN ca.code END) AS "HR 788",
		MAX(CASE WHEN cs.congstatus_id = 97347 THEN ca.code END) AS "HR 6914"	    																										
		 	    	    	    	    	    	    	    	    	    	    	    	    	    	
   	FROM congstatus_candidate cc
   	
   	-- This narrows down the CandidatesAction to only for active incumbents
   	JOIN USHouseCandidates USING (office_candidate_id)
   	
	LEFT JOIN congaction ca ON cc.congaction_id = ca.congaction_id
	LEFT JOIN congstatus cs ON cc.congstatus_id = cs.congstatus_id
   	
   	GROUP BY office_candidate_id
)
-- Ultimately...
SELECT
	candidate.candidate_id,
	candidate.firstname,
	candidate.lastname,
	USHouseCandidates.office,
	USHouseCandidates.party,
	USHouseCandidates.state,
	USHouseCandidates.district,
	SelectedHouseBills.*
	
FROM candidate

JOIN USHouseCandidates USING (candidate_id)
LEFT JOIN SelectedHouseBills ON USHouseCandidates.office_candidate_id = SelectedHouseBills.office_candidate_id
ORDER BY office, state, district;


-- Get Senate Candidates
WITH CombinedOffices AS (
    SELECT 
        office_candidate.office_candidate_id,
        office_candidate.candidate_id,
        office_candidate.office_id,
        office_candidate.state_id,
        office_candidate.districtname_id,
        ROW_NUMBER() OVER (
            PARTITION BY office_candidate.candidate_id 
            ORDER BY office_candidate.office_candidate_id DESC
        ) AS row_number
    FROM 
        office_candidate
    WHERE 
        office_candidate.officecandidatestatus_id = 1
        OR office_candidate.candidate_id IN (28338, 7547)
),
USSenateCandidates AS (
    SELECT 
        co.office_candidate_id,
        co.candidate_id,
        office.name as "office",
        party.name as "party",
        state.name as "state",
        districtname.name as "district"
    FROM 
        CombinedOffices co
        LEFT JOIN office ON co.office_id = office.office_id
        LEFT JOIN office_candidate_party ON co.office_candidate_id = office_candidate_party.office_candidate_id
        LEFT JOIN party ON office_candidate_party.party_id = party.party_id
        LEFT JOIN state ON co.state_id = state.state_id
        LEFT JOIN districtname ON co.districtname_id = districtname.districtname_id
    WHERE 
     	co.office_id IN (6)
     	AND
        (
        	-- Select the most recent office for these candidates
            co.row_number = 1 AND co.candidate_id NOT IN (28338, 7547)
        	OR
        	-- Select prior office for these candidates
            co.row_number = 2 AND co.candidate_id IN (28338, 7547)
        )
        AND co.state_id NOT IN ('AS','DC','GU','MP','VI','PR')
),
-- Only select the bills you need
SelectedSenateBills AS
	(
	SELECT
		office_candidate_id,
	    MAX(CASE WHEN cs.congstatus_id = 84187 THEN ca.code END) AS "HR 5746",
		MAX(CASE WHEN cs.congstatus_id = 84822 THEN ca.code END) AS "HR 4521",
		MAX(CASE WHEN cs.congstatus_id = 86183 THEN ca.code END) AS "S 2938",
		MAX(CASE WHEN cs.congstatus_id = 87519 THEN ca.code END) AS "HR 5376",
		MAX(CASE WHEN cs.congstatus_id = 91319 THEN ca.code END) AS "H J Res 7",
		MAX(CASE WHEN cs.congstatus_id = 92444 THEN ca.code END) AS "HR 3746",
		MAX(CASE WHEN cs.congstatus_id = 96788 THEN ca.code END) AS "HR 2670",
		MAX(CASE WHEN cs.congstatus_id = 99500 THEN ca.code END) AS "HR 7888",
		MAX(CASE WHEN cs.congstatus_id = 99560 THEN ca.code END) AS "S 4072",
		MAX(CASE WHEN cs.congstatus_id = 99693 THEN ca.code END) AS "HR 815",
		MAX(CASE WHEN cs.congstatus_id = 100190 THEN ca.code END) AS"HR 3935"
		    	
   	FROM congstatus_candidate cc
   	
   	-- This narrows down the CandidatesAction to only for active incumbents
   	JOIN USSenateCandidates USING (office_candidate_id)
   	
	LEFT JOIN congaction ca ON cc.congaction_id = ca.congaction_id
	LEFT JOIN congstatus cs ON cc.congstatus_id = cs.congstatus_id
	LEFT JOIN congtitle ct ON cs.congtitle_id = ct.congtitle_id
	LEFT JOIN congress cg ON cs.congress_id = cg.congress_id
   	
   	GROUP BY office_candidate_id
)
-- Ultimately...
SELECT
	candidate.candidate_id,
	candidate.firstname,
	candidate.lastname,
	USSenateCandidates.office_candidate_id,
	USSenateCandidates.office,
	USSenateCandidates.party,
	USSenateCandidates.state,
	USSenateCandidates.district,
	SelectedSenateBills.*
	
FROM candidate

JOIN USSenateCandidates USING (candidate_id)
JOIN SelectedSenateBills ON USSenateCandidates.office_candidate_id = SelectedSenateBills.office_candidate_id
ORDER BY office, state, district;

/*Sanity check: See the number of offices a candidate has*/
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY candidate_id ORDER BY office_candidate_id DESC) AS row_number
	
FROM office_candidate
WHERE candidate_id = 201704;



SELECT
	firstname,
	lastname,
	state.state_id,
	congaction.name


FROM congstatus
JOIN congstatus_candidate USING (congstatus_id)
JOIN congaction USING (congaction_id)
JOIN office_candidate USING (office_candidate_id)
	
JOIN candidate ON office_candidate.candidate_id = candidate.candidate_id
JOIN state ON office_candidate.state_id = state.state_id
WHERE congstatus_id = 90473

ORDER BY lastname, office_candidate.state_id;


