SELECT *
FROM PortfolioProject.dbo.CovidDeaths

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, CAST(total_cases AS float)/CAST(population AS float)*100 AS CovidContractPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Malaysia%'
order by 1,2 

-- Looking at countries with highest infection rate compared to Population

SELECT location, population, MAX(CAST(total_cases AS INT)) AS HighestInfectionCount, MAX((CAST(total_cases AS INT)/population))*100 AS CovidContractPercentage
FROM PortfolioProject.dbo.CovidDeaths
group by location,population
order by CovidContractPercentage desc

-- Showing countries with highest death count per population

SELECT location, MAX(CAST (total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
group by location
order by HighestDeathCount desc

-- Showing results by continent instead

SELECT continent, MAX(CAST (total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
group by continent
order by HighestDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST (total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
group by continent
order by HighestDeathCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
From PopvsVac



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select*, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations



Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
From PercentPopulationVaccinated
