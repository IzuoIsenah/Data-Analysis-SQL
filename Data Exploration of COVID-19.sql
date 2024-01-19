-- EXPLORING THE COVID-19 DEATHS AND VACCINATIONS DATA

------------------------------------------------------------------

-- To determine the total cases vs total deaths percentage

SELECT continent, location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 
AS DeathPercentage 
FROM CovidDeaths
ORDER BY location, date

-- To determine the total cases vs population

SELECT location, date, population, total_cases, (total_cases / population) * 100
AS PopulationPercentInfected
FROM CovidDeaths
ORDER BY location, date

-- To determine countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestCases, MAX((total_cases/population) * 100) 
AS PopulationInfectionRate
FROM CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectionRate DESC

-- To determine the highest death rate per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- To determine the global number of total cases and total deaths

SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths as int)) AS totaldeaths,
   SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 as deathpercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


-- To determine total population vs vaccinations by joining the CovidDeaths and CovidVaccination Tables

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM CovidDeaths as d
JOIN CovidVaccinations as v
   ON d.location = v.location
  and d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3

-- To determine the number the number of new vaccinations each day on a rolling basis

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
  SUM(cast(v.new_vaccinations as int)), OVER (PARTITION BY d.location 
   order by d.location, d.date) as RollingcountofVaccinations
FROM CovidDeaths as d
   JOIN CovidVaccinations as v
        ON d.location = v.location
       and d.date = v.date
Where d.continent IS NOT NULL
Order By 1,2,3

-- To determine the total population vs rolling count of vaccinations Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingcountofVaccinations)
   AS
(SELECT d.continent, d.location. d.date, d.population, v.new_vaccinations
   SUM(cast(v.new_vaccinations as int)), OVER (PARTITION BY d.location 
   order by d.location, d.date) as RollingcountofVaccinations
FROM CovidDeaths as d
   JOIN CovidVaccinations as v
        ON d.location = v.location
       and d.date = v.date
Where d.continent IS NOT NULL
)
SELECT *, (RollingcountofVaccinations/population) * 100
FROM PopvsVac


-- Using temporary table to determine the percentage of population vaccinated

DROP Table if exists #PercentPopulationVaccinted 
CREATE #PercentPopulationVaccinted
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingcountofVaccinations
)
    
INSERT INTO #PercentPopulationVaccinted
SELECT d.continent, d.location, d.date, d.population, v.newvaccinations,
    SUM(cast(v.new_vaccinations as int)), OVER (PARTITION BY d.location 
    order by d.location, d.date) as RollingcountofVaccinations
FROM CovidDeaths as d
    JOIN CovidVaccinations as v
        ON d.location = v.location
       and d.date = v.date
Where d.continent IS NOT NULL

SELECT *, (RollingcountofVaccinations/population) * 100
FROM #PercentPopulationVaccinted


-- Creating views for visualisations

CREATE VIEW PercentPopulationVaccinted as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
    SUM(cast(v.new_vaccinations as int)), OVER (PARTITION BY d.location 
    order by d.location, d.date) as RollingcountofVaccinations
FROM CovidDeaths as d
    JOIN CovidVaccinations as v
        ON d.location = v.location
       and d.date = v.date
Where d.continent IS NOT NULL