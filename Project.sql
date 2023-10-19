Select * from PortfolioProject..CovidDeaths
ORDER BY 3,4

--Select * from PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select the data that we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population_density
from PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying due to COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location = 'INDIA'
ORDER BY 1,2

-- Looking at the total cases versus the population
SELECT location, date, total_cases, population_density, (total_cases/population_density)*100 as PercentPopulation
from PortfolioProject..CovidDeaths
WHERE location like 'A%'
ORDER BY 1,2

-- Looking at the countries with the highest infection rate compared to the population
SELECT location, population_density, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population_density))*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
--WHERE location like 'A%'
GROUP BY Location, population_density
ORDER BY 1,2

-- Countries with the highest death count per Population
SELECT location, MAX(cast(total_deaths as int)) AS Totaldeathcount
from PortfolioProject..CovidDeaths
--WHERE location like 'A%'
GROUP BY Location
ORDER BY 1,2

-- Grouping it By Continent
SELECT continent, MAX(cast(total_deaths as int)) AS Totaldeathcount
from PortfolioProject..CovidDeaths
--WHERE location like 'A%'
WHERE continent is not null
GROUP BY continent
ORDER BY 1,2

--GLOBAL NUMBERS
SELECT date, SUM(new_cases),MAX(cast(new_deaths as int)) AS Totaldeathcount
from PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total cases
SELECT SUM(new_cases) AS Totalcases,MAX(cast(new_deaths as int)) AS Totaldeathcount
from PortfolioProject..CovidDeaths

SELECT DEA.continent, DEA.location, DEA.date, VAC.population, VAC.new_vaccinations
FROM PortfolioProject..CovidVaccinations$ VAC
JOIN PortfolioProject..CovidDeaths DEA
ON DEA.location=VAC.location
and DEA.date=VAC.date
WHERE DEA.continent is not null
ORDER BY 1

--Looking at Total Population Vs Vaccinations
SELECT DEA.continent, DEA.location, DEA.date, VAC.population, VAC.new_vaccinations, SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location ORDER BY DEA.location)
FROM PortfolioProject..CovidVaccinations$ VAC
JOIN PortfolioProject..CovidDeaths DEA
ON DEA.location=VAC.location
and DEA.date=VAC.date
WHERE DEA.continent is not null
ORDER BY 1

-- USE CTE
with POPvsVAC (continent, location, date, population, new_vaccinations, NEW)
as 
(
SELECT DEA.continent, DEA.location, DEA.date, VAC.population, VAC.new_vaccinations, SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location ORDER BY DEA.location) as NEW
FROM PortfolioProject..CovidVaccinations$ VAC
JOIN PortfolioProject..CovidDeaths DEA
ON DEA.location=VAC.location
and DEA.date=VAC.date
WHERE DEA.continent is not null
)
SELECT * FROM POPvsVAC

-- Creating view to store data for later visualizations
CREATE View PercentPeopleVaccinated as 
SELECT DEA.continent, DEA.location, DEA.date, VAC.population, VAC.new_vaccinations, SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DEA.location ORDER BY DEA.location) as NEW
FROM PortfolioProject..CovidVaccinations$ VAC
JOIN PortfolioProject..CovidDeaths DEA
ON DEA.location=VAC.location
and DEA.date=VAC.date
WHERE DEA.continent is not null

SELECT * FROM PercentPeopleVaccinated