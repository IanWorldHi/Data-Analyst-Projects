-- 	Exploratory Data Analysis

select * from layoffs_staging2;
select count(company) from layoffs_staging2;
select year(`date`), sum(total_laid_off) from layoffs_staging2
group by year(`date`)
order by 2 desc;

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

with company_year (company, years, total_laid_off) as 
(
select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
order by 3 desc 
),
company_year_rank as 
(
select *, 
dense_rank() over (partition by years order by total_laid_off DESC) as ranking
from company_year
where years is NOT NULL
)
select *
from company_year_rank
where ranking <=5;





