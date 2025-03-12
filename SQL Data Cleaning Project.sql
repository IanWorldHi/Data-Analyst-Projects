-- Data cleaning

-- 1 Remove duplicates
-- 2 Standardize data
-- 3 Null or Blank values
-- 4 Remove any unnecessary columns


-- Creating duplicates to edit and still have a backup raw data
create table layoffs_staging 
like layoffs;

insert layoffs_staging 
select *
from layoffs;

-- 1 Remove duplicates
select *,
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

with duplicate_cte as
(select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging)
select * from duplicate_cte
where row_num>1
;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete from layoffs_staging2 where row_num>1;

select * from layoffs_staging2;
-- 2 Standardize data
select company, trim(company) from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry from layoffs_staging2 order by industry;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

update layoffs_staging2
set country = trim(trailing '.' from country) 
where country like 'United States%';

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;


-- 3 Null or Blank values

update layoffs_staging2
set industry = NULL
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is NULL OR t1.industry = '')
AND t2.industry is NOT NULL;


-- 4 Remove any unnecessary columns

delete 
from layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

alter table layoffs_staging2
drop column `row num`;








