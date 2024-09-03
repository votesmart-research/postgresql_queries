

WITH

SelectedCategories AS (
	SELECT speech_id
	FROM speech_category
	JOIN category USING (category_id)
	WHERE category.name LIKE '%Foreign Affairs%'
),

SelectedTags AS (
	SELECT speech_id
	FROM speech_tag
	JOIN tag USING (tag_id)
	WHERE LOWER(tag.name) LIKE '%nuclear%'
)

SELECT
	DISTINCT ON (speechtext)
	speech_id,
	title,
	speechdate, 
	location,  
	source,
	'https://justfacts.votesmart.org/public-statement/' || speech_id AS "votesmart_url"

FROM speech
JOIN speech_candidate USING (speech_id)

WHERE
--	speech_id IN (
--	SELECT speech_id FROM SelectedCategories
--	INTERSECT
--	SELECT speech_id FROM SelectedTags
--	)
--	AND
	candidate_id = 15723
	AND
	(LOWER(speechtext) LIKE '%monument%');




-- How many Executive Orders by speech type - by president?
-- Filter speech by categories
-- Filter speech by keywords
