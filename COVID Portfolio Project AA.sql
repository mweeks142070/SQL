/*
COVID 19 Data Exploration COVID Data SSMS

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM CovidDeaths
ORDER BY 3,4;

--Select data that we are going to be starting with and explore
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

-- Looking at total cases vs. total deaths for US
-- Shows likelihood of dying if you contract Covid in United States
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 2) as death_percentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;

-- Looking at the total cases vs. the population
-- Shows what percentage of population contracted Covid in United States
SELECT Location, date, population, total_cases, ROUND((total_cases/population) * 100, 2) as contraction_rate
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;

-- Shows what countries have the highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as highest_infection_count, ROUND(MAX((total_cases/population)) * 100, 2) as contraction_rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY contraction_rate DESC;

-- Shows the countries with the highest death count compared to population
-- Had to use cast as data type in data base was creating an issue
-- Continents were listed in the results as "Location" and the continent column was left null. It was being included in our results when we just want to see countries.
SELECT Location, population, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Breaking things down by continent
-- Showing continents with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;
 --OR (depending on dataset, the one we used here made this a little confusing)
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc;

--Global Numbers BY DATE
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases)*100),2) as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total Death Percentage Globally
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases)*100),2) as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs. New Vaccinations per day for U.S.
-- Using CTE and partition by
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, total_vacs_per_location_rolling)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
SUM(cast(vacs.new_vaccinations as int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as total_vacs_per_location_rolling
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vacs
ON deaths.location = vacs.location
AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (total_vacs_per_location_rolling/population)*100 as percent_vaccinated
FROM pop_vs_vac
WHERE location = 'United States'
ORDER BY 2,3;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccianted as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
SUM(cast(vacs.new_vaccinations as int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as total_vacs_per_location_rolling
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vacs
ON deaths.location = vacs.location
AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL


