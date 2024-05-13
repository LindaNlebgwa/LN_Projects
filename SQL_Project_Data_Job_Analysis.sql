/*
Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest paying Aata Analyst roles that are available remotely.
- Focuses on job postings with specified salaries (remove nulls).
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment opportunities
*/

SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS compamy_name
FROM 
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' AND 
      job_location = 'Anywhere' AND 
      salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10


/*
Question: What skills are required for the top-paying Data Analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skills required for these roles 
- Why? It provides a deatailed look at which high-paying jobs demand certain skills,
   helping job seekers understand which skills to develop that align with top salaries
   */


WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS compamy_name
    FROM 
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND 
        salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC


    /*
Question: What are the most in-demand skills for data analysts?
- Join job postings to Inner join table similar to query 2
- Identify the top 5 in-demand skills for data analyst'
- Focus on all job postings.
- Why? Retrieve the top 5 skills with the highest demand in the job market,
   provide insights into the most valuable skills for job seekers.
*/



SELECT 
   skills,
   COUNT(skills_job_dim.skill_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND 
   job_work_from_home = TRUE
GROUP BY
   skills
ORDER BY
   demand_count DESC
LIMIT 10;


/*
Question: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focus on the roles with specified salaries, regardless of location
- Why? It reveals how different skills impact salary levels for Data Analysts and
   helps identify the most finacially rewarding skills to acquire or improve
*/


SELECT 
   skills,
   ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' 
    AND salary_year_avg IS NOT NULL 
    AND job_work_from_home = TRUE
GROUP BY
   skills
ORDER BY
   avg_salary DESC
LIMIT 10; 



/*
Question: What are the most optimal skills to learn (aka its in high demand and a high paying skill)?
- Identify skills in high demand and associated with high average high salaries for Data Analyst roles
- Concentrate on remote positions with specified salaries
- Why? Target skills that offer job security (high demand) and finacial benefits (high salaries),
    offering strategic insights for career development in data analysis
*/


WITH skills_demand AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.skill_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL 
        AND job_work_from_home = TRUE
    GROUP BY
        skills_dim.skill_id
), average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL 
        AND job_work_from_home = TRUE
    GROUP BY
        skills_job_dim.skill_id
)

SELECT 
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
FROM 
    skills_demand
INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE 
    demand_count > 10
ORDER BY 
    avg_salary DESC,
    demand_count DESC
LIMIT 25