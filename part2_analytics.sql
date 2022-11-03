--Question 1
SELECT     (AVG(COALESCE(c.known_total_funding, 0))) AS average_total_funding
      FROM people           p
 LEFT JOIN companies        c
        ON p.company_name = c.name
     WHERE p.person_id = '92a52877-8d5d-41a6-950f-1b9c6574be7a';

--Question 2
SELECT   (COUNT(1)) AS companies_with_no_people
    FROM companies c
   WHERE NOT EXISTS (SELECT 1
                       FROM people   p
                      WHERE c.name = p.company_name);

--Question 3
WITH part_1 AS (
    SELECT     c.name,
               (COUNT(1)) AS people_qtty
          FROM companies     c
    INNER JOIN people        p
            ON c.name      = p.company_name
      GROUP BY c.name
),   part_2 AS (
    SELECT p.name,
           p.people_qtty,
           (ROW_NUMBER() OVER(PARTITION BY 1
                                  ORDER BY p.people_qtty DESC)) AS rank_popular_companies
      FROM part_1 p
)
SELECT p.name,
       p.people_qtty
  FROM part_2 p
 WHERE p.rank_popular_companies <= 10;

--Question 4
WITH part_1 AS (
    SELECT     c.name,
               c.headcount,
               (ARRAY_AGG('{''' || p.person_id || ''':''' || p.last_title || '''}')) AS founders,
               (ROW_NUMBER() OVER(PARTITION BY 1
                                      ORDER BY c.headcount DESC)) AS rank_largests_headcount
          FROM companies                       c
    INNER JOIN people                          p
            ON c.name                     =    p.company_name
           AND (LOWER(p.last_title))      LIKE '%founder%'
         WHERE (COALESCE(c.headcount, 0)) >    0 
      GROUP BY c.name,
               c.headcount
)
SELECT p.name,
       p.headcount,
       p.founders
  FROM part_1 p
 WHERE p.rank_largests_headcount <= 3;

--Question 5
WITH part_1 AS (
    SELECT p.person_id,
           p.company_name,
           p.company_li_name,
           p.last_title,
           p.group_start_date,
           p.group_end_date,
           (CAST(((COALESCE(p.group_end_date, CURRENT_DATE)) - p.group_start_date) AS FLOAT) / CAST(365 AS FLOAT)) AS years_worked,
           (ROW_NUMBER() OVER(PARTITION BY p.person_id
                                  ORDER BY (COALESCE(p.group_end_date, CURRENT_DATE)) DESC))                       AS rank_job
      FROM people p
     WHERE p.group_start_date IS NOT NULL
),   question_1 AS (
    SELECT p.person_id,
           p.company_name,
           p.company_li_name,
           p.last_title,
           p.group_start_date,
           p.group_end_date,
           p.years_worked
      FROM part_1       p
     WHERE p.rank_job = 2
),   question_2 AS (
    SELECT (AVG(DISTINCT q.years_worked)) AS average_duration_in_years_for_2nd_most_recent_job
      FROM question_1 q
),   question_3 AS (
    SELECT     (COUNT(DISTINCT a.person_id)) AS people_with_more_than_one_job_at_same_time_qtty
          FROM part_1                a
    INNER JOIN part_1                b
            ON a.person_id        =  b.person_id
           AND a.company_name     != b.company_name
           AND a.group_start_date >= b.group_start_date
           AND a.group_start_date <  (COALESCE(b.group_end_date, CURRENT_DATE))
)
SELECT q.*
  FROM question_1 q;

WITH part_1 AS (
    SELECT p.person_id,
           p.company_name,
           p.company_li_name,
           p.last_title,
           p.group_start_date,
           p.group_end_date,
           (CAST(((COALESCE(p.group_end_date, CURRENT_DATE)) - p.group_start_date) AS FLOAT) / CAST(365 AS FLOAT)) AS years_worked,
           (ROW_NUMBER() OVER(PARTITION BY p.person_id
                                  ORDER BY (COALESCE(p.group_end_date, CURRENT_DATE)) DESC))                       AS rank_job
      FROM people p
     WHERE p.group_start_date IS NOT NULL
),   question_1 AS (
    SELECT p.person_id,
           p.company_name,
           p.company_li_name,
           p.last_title,
           p.group_start_date,
           p.group_end_date,
           p.years_worked
      FROM part_1       p
     WHERE p.rank_job = 2
),   question_2 AS (
    SELECT (AVG(DISTINCT q.years_worked)) AS average_duration_in_years_for_2nd_most_recent_job
      FROM question_1 q
),   question_3 AS (
    SELECT     (COUNT(DISTINCT a.person_id)) AS people_with_more_than_one_job_at_same_time_qtty
          FROM part_1                a
    INNER JOIN part_1                b
            ON a.person_id        =  b.person_id
           AND a.company_name     != b.company_name
           AND a.group_start_date >= b.group_start_date
           AND a.group_start_date <  (COALESCE(b.group_end_date, CURRENT_DATE))
)
SELECT q.*
  FROM question_2 q;

WITH part_1 AS (
    SELECT p.person_id,
           p.company_name,
           p.company_li_name,
           p.last_title,
           p.group_start_date,
           p.group_end_date,
           (CAST(((COALESCE(p.group_end_date, CURRENT_DATE)) - p.group_start_date) AS FLOAT) / CAST(365 AS FLOAT)) AS years_worked,
           (ROW_NUMBER() OVER(PARTITION BY p.person_id
                                  ORDER BY (COALESCE(p.group_end_date, CURRENT_DATE)) DESC))                       AS rank_job
      FROM people p
     WHERE p.group_start_date IS NOT NULL
),   question_1 AS (
    SELECT p.person_id,
           p.company_name,
           p.company_li_name,
           p.last_title,
           p.group_start_date,
           p.group_end_date,
           p.years_worked
      FROM part_1       p
     WHERE p.rank_job = 2
),   question_2 AS (
    SELECT (AVG(DISTINCT q.years_worked)) AS average_duration_in_years_for_2nd_most_recent_job
      FROM question_1 q
),   question_3 AS (
    SELECT     (COUNT(DISTINCT a.person_id)) AS people_with_more_than_one_job_at_same_time_qtty
          FROM part_1                a
    INNER JOIN part_1                b
            ON a.person_id        =  b.person_id
           AND a.company_name     != b.company_name
           AND a.group_start_date >= b.group_start_date
           AND a.group_start_date <  (COALESCE(b.group_end_date, CURRENT_DATE))
)
SELECT q.*
  FROM question_3 q;