SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%south korea%'
ORDER BY 1,2;

-- Total cases vs Population
-- Shows that percentage of population got Covid
SELECT Location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE location like '%south korea%'
ORDER BY 1,2;

-- Highest InfectionRate compared to Population 
SELECT Location, population, MAX(total_cases) AS HigherstInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM coviddeaths
GROUP BY location, population
ORDER BY InfectionRate desc;

-- Countries with Highest Death Count per Population

SELECT location, MAX(Total_deaths) AS TotalDeathCount
FROM coviddeaths
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Continents with Highest Death count
SELECT continent, MAX(total_deaths) AS DeathCount
FROM coviddeaths
GROUP BY continent
ORDER BY DeathCount desc;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) *100 AS DeathRates
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
ORDER BY 2,3;


-- CTE

WITH PopVsVac (Continent, Location, date, Population, New_vaccinations, CummulativeVaccinationCount)
as 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount
	FROM coviddeaths dea
	JOIN covidvaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
)
SELECT *, (CummulativeVaccinationCount/Population)*100
FROM PopVsVac
WHERE New_vaccinations != 0;


-- Creating view to store data

CREATE VIEW PopVsVac AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
	and dea.date = vac.date
WHERE New_vaccinations != 0;





