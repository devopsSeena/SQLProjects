SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations
--============================================================================
--Death Percentage in a specific location

SELECT location,date,total_cases ,total_deaths,(total_deaths/total_cases)*100 DeathPercent
FROM CovidDeaths
WHERE location = 'India'
ORDER BY location,date
--============================================================================
--Percentage of Population who got Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as PercentOfPopulationInfected
FROM CovidDeaths
WHERE location = 'India'
ORDER BY location,date
--============================================================================
--High infection rate comparerd to population

SELECT location,population,MAX(total_cases) AS HighestCases,MAX((total_cases/population)*100) as PercentOfPopulationInfected 
FROM CovidDeaths
GROUP BY population,location
ORDER BY PercentOfPopulationInfected DESC
--============================================================================
--Countries With highest death count per population

SELECT location,MAX(CAST(total_deaths AS INT)) AS DeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC
--============================================================================
--Continents with highest death count

SELECT continent,MAX(CAST(total_deaths AS INT)) AS DeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC
--============================================================================
--Global Numbers

SELECT SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
--============================================================================
--Global Death Percentage Datewise

SELECT date, SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 As DeathPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP By date
ORDER BY date
--============================================================================
--Total Population vs Vaccinations

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT))OVER( PARTITION BY CD.location ORDER BY CD.location ,CD.date) AS RollingVaccinationCount
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY location,date
--============================================================================
--Vaccination Percent per Population Using CTE

WITH CTE_VaccinationPercent 
As
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT))OVER( PARTITION BY CD.location ORDER BY CD.location ,CD.date) AS RollingVaccinationCount
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)
SELECT continent,location,date,population,new_vaccinations,RollingVaccinationCount,(RollingVaccinationCount/population)*100
FROM CTE_VaccinationPercent
ORDER BY location,date
--============================================================================
--Vaccination Percent per Population Using Temp

DROP TABLE IF EXISTS #VaccinationPercent
CREATE TABLE #VaccinationPercent
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingVaccinationCount NUMERIC
)

INSERT INTO #VaccinationPercent
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT))OVER( PARTITION BY CD.location ORDER BY CD.location ,CD.date) AS RollingVaccinationCount
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT * FROM #VaccinationPercent
--============================================================================
--Creating View for Visualization

CREATE VIEW VaccinationPercent
AS
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS INT))OVER( PARTITION BY CD.location ORDER BY CD.location ,CD.date) AS RollingVaccinationCount
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
