Select *
From dataAnalyticsDB..covidDeaths
Where continent is not null 
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From dataAnalyticsDB..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- the probability of a person dying when contracted by covid

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dataAnalyticsDB..covidDeaths
Where location like '%hanas%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From dataAnalyticsDB..covidDeaths
--Where location like '%hana%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dataAnalyticsDB..covidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- querying for  Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataAnalyticsDB..covidDeaths
--Where location like '%hana%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Querying for contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataAnalyticsDB..covidDeaths
--Where location like '%hana%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dataAnalyticsDB..CovidDeaths
--Where location like '%hanas%'
where continent is not null 
Group By date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dataAnalyticsDB..CovidDeaths
--Where location like '%hana%'
where continent is not null 
--Group By date
order by 1,2



SELECT * FROM dataAnalyticsDB..covidVaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date ) as RollingPopulationVaccinated
FROM dataAnalyticsDB..covidDeaths dea
JOIN  dataAnalyticsDB..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- using Common Table Expression CTE
WITH PopvsVac (continent,location,date ,population,new_vaccinations,RollingPopulationVaccinated)
as(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as RollingPopulationVaccinated
FROM dataAnalyticsDB..covidDeaths dea
JOIN  dataAnalyticsDB..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2
)

SELECT *, (RollingPopulationVaccinated/population)*100 FROM PopvsVac


--creating A TEMP TABLE

DROP TABLE IF exists PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as RollingPopulationVaccinated
FROM dataAnalyticsDB..covidDeaths dea
JOIN  dataAnalyticsDB..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 1,2

SELECT *, (RollingPopulationVaccinated/population)*100 as PercentRollingPopulationVaccinated 
FROM #PercentPopulationVaccinated

--creating views 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as RollingPopulationVaccinated
FROM dataAnalyticsDB..covidDeaths dea
JOIN  dataAnalyticsDB..covidVaccination vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2

SELECT * FROM PercentPopulationVaccinated

CREATE VIEW HighestContinentDeathCount AS
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataAnalyticsDB..covidDeaths
--Where location like '%hana%'
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

CREATE VIEW HighestCountrytDeathCount AS
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataAnalyticsDB..covidDeaths
--Where location like '%hana%'
Where continent is not null 
Group by Location
--order by TotalDeathCount desc

CREATE VIEW TotalDeathPerDay as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dataAnalyticsDB..CovidDeaths
--Where location like '%hanas%'
where continent is not null 
Group By date
--order by 1,2


CREATE VIEW InfectionRateInGhana as
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From dataAnalyticsDB..covidDeaths
Where location like '%hana%'
--order by 1,2


-- Countries with Highest Infection Rate compared to Population
CREATE VIEW CountriesHighestInfectionRate as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dataAnalyticsDB..covidDeaths
--Where location like '%states%'
Group by Location, Population
--order by PercentPopulationInfected desc