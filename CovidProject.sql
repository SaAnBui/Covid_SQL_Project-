--------------------------------------------------
-- Project Title: SQL Covid Project
-- Description of work: Uploaded 2 Excel files into MSSMS. Write various queries to explore  
--		the data on Covid deaths and Covid vaccinations from May 2020.
-- Results: Views are created to be used in later visualizations.
-- Link to Dataset: https://ourworldindata.org/covid-deaths
--------------------------------------------------

-- to see a few rows of data
SELECT TOP 50 *
FROM PortfolioProject.dbo.CovidDeaths;

-- is there continent level data?
-- How is it when the location is at continent level?
SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null ;

-- to select only contries and remove continent rows
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null;

-- select data that we are going to be using 
SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2;

-- looking at Total Cases vs Total Dealths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2;

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2;

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;



-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;
-- lET'S BREAK IT DOWN BY CONTINENTS
-- when continent is null, location is non-country identification
-- When continent is not null, location is country and continent is a continent where the country belong
-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
-- percent of death per day
SELECT date, sum(new_cases) as TotalCases,
	SUM(new_deaths) as TotalDeaths,
	(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2; 

-- Overall death percentage across the world
SELECT  sum(new_cases) as TotalCases,
	SUM(new_deaths) as TotalDeaths,
	(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2; 

-- VACCINATIONS
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations;

-- looking at total population and vaccinations
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2, 3;

-- Use CTE to obtain percentage of vaccination
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as
	(
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
	)
SELECT * , (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PopvsVac
ORDER BY 2, 3;

-- Use Temp table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT * , (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2, 3;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulatedVaccinated AS 
	SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null;

