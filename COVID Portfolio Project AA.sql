/*
COVID 19 Data Exploration COVID Data

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM CovidDeaths
ORDER BY 3,4;

--Select data that we are going to be starting with
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE Location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at the total cases vs. the population
-- Shows what percentage of population contracted Covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as ContractionRate
FROM CovidDeaths
ORDER BY 1,2;

-- Shows what countries have the highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as ContractionRate
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY ContractionRate desc;

-- Shows the countries with the highest death count compared to population
SELECT Location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY HighestDeathCount desc;

-- Breaking things down by continent
-- Showing continents with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount desc;
 --OR (depending on data)
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount desc;

--Global Numbers BY DATE
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total Death Percentage Globally
SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs. New Vaccinations per day
-- Using CTE and partition by
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinationsPerLocation)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinationsPerLocation
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (TotalVaccinationsPerLocation/Population)*100 as PercentageVaccinated
FROM PopvsVac;

--Using Temp Table to perform previous query
DROP TABLE if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination
(
Continent nvarchar(255),
Locations nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
TotalVaccinationsPerLocation numeric)
INSERT INTO #PercentPopulationVaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinationsPerLocation
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (TotalVaccinationsPerLocation/Population)*100 as PercentageVaccinated
FROM #PercentPopulationVaccination;


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinationsPerLocation
FROM CovidDeaths as deaths
JOIN CovidVaccinations as vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL;


