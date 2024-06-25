-- Data cleaning

select *
from layoffs;


-- Steps we use
-- 1. Remove duplicate values
-- 2. Standarize the data
-- 3. Null values or blank values 
-- 4. Remove any coloums


-- Make secondary table of main

create table layoff_staging
like layoffs;

select *
from layoff_staging;

insert layoff_staging 
select *
from layoffs;


