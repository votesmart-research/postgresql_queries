-- How many bills Biden or Trump has vetoed or signed on a particular issue with a date range?


WITH
SelectedCategory AS(

	SELECT 
		congcategory_id,
		congcategory_category_id,
		category.name
	
	FROM congcategory_category
	JOIN category USING (category_id)
	
	WHERE category.name LIKE '%Infra%'
	ORDER BY category.name, congcategory_id
),

SelectedTag AS (

	SELECT 
		congcategory_id,
		congcategory_tag_id,
		tag.name
	
	FROM congcategory_tag
	JOIN tag USING (tag_id)
	
	WHERE LOWER(tag.name) LIKE '%electric%'
	ORDER BY tag.name
),

AllBills AS (
	SELECT 
		congress.congress_id,
		congstatus_id,
		congcategory_id,
		congress.billnumber,
		congtitle.title,
		statusdate
		
	FROM congstatus
	
	JOIN congress USING (congress_id)
	JOIN congtitle USING (congtitle_id)

	WHERE statusdate >= '2016-01-03' AND statusdate <= '2025-01-03'
	ORDER BY statusdate DESC
),

CatNTagBills AS (
	SELECT *
	FROM AllBills
	WHERE
		congcategory_id IN (
--		SELECT congcategory_id FROM SelectedCategory
--		INTERSECT 
		SELECT congcategory_id FROM SelectedTag
		)
)

SELECT
	congress_id,
	congstatus_id,
	office_candidate_id,
	billnumber,
	CatNTagBills.statusdate,
	CatNTagBills.title,
	congaction.name AS "Action",
	'https://justfacts.votesmart.org/bill/' || '/' || congress_id AS votesmart_url 

FROM congstatus_candidate

JOIN office_candidate USING (office_candidate_id)
JOIN congaction USING (congaction_id)
JOIN CatNTagBills USING (congstatus_id)

WHERE 
--	candidate_id = 53279
	candidate_id = 15723
--	AND
--	congaction.name IN ('Veto')

ORDER BY statusdate DESC, congress_id;

