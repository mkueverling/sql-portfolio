
/*	Finalized Queries for the Covid-19 Dashboard	*/


-- Top Metrics Global 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS death_percentage
FROM "Covid-19 Dashboard"..CovidDeaths
--WHERE location = 'Germany'
WHERE continent IS NOT NULL


-- Top Metrics Continents
SELECT location, SUM(CAST(new_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_deaths DESC

-- Most Infected Percentage
SELECT Location, Population, MAX(COALESCE(total_cases,0)) AS highest_infections,  MAX(COALESCE(total_cases/population,0))*100 AS population_infected_percent
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Germany'
GROUP BY Location, Population
ORDER BY population_infected_percent DESC


-- Most Infected Percentage Grouped by Date
SELECT Location, Population, date, MAX(COALESCE(total_cases,0)) AS infection_count,  MAX(COALESCE(total_cases/population,0))*100 AS population_infected_percent
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population, date
ORDER BY population_infected_percent DESC

--------------------------------------------------------------------------------------------------------------------------------
/*	The queries below were not included		*/



	-- SELECT Statements for exploring the data

--SELECT *
--FROM PortfolioProject..	CovidDeaths
--WHERE Continent is not null
--ORDER BY location, date

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE Continent is not null
--ORDER BY location, date


/*
The "WHERE 'continent' IS NOT NULL" statement in most of the queries are due to
'continents' being listed in the same column as 'countries' in the column 'location'
as seen in the query below.
*/


SELECT location, date, total_cases, new_cases, population
--WHERE Continent is not null
FROM PortfolioProject..CovidDeaths
ORDER BY location, date


				-- GENERAL QUERY (DEATH PERCENTAGE)
	-- Shows the percentage of deaths occuring with the virus ORDER BY DATE

SELECT location, date, total_cases, (total_deaths) AS total_deaths, (total_deaths/total_cases)*100 AS deaths_ratio
FROM PortfolioProject..CovidDeaths
--WHERE location IN ('Germany')
WHERE Continent is not null
ORDER BY date 


					-- GENERAL QUERY (CASE PERCENTAGE)
	-- Comparing Population to the Total Cases
	-- Shows the percentage of population having covid-19

SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_ratio
FROM PortfolioProject..CovidDeaths
--WHERE location IN ('Germany')
WHERE Continent is not null
ORDER BY date 


					-- COUNTRY BREAKDOWNS

	-- Countries with highest infection rate to population
	-- Ordered by percentage of population infected

SELECT location, population, MAX(total_cases) as highest_infenction_count, max(total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
GROUP BY location, population 
ORDER BY percent_population_infected DESC


	-- Countries with the highest death rate per population
	-- Ordered by percentage of population deceased with covid

SELECT location, MAX(cast(total_deaths as int)) as "death_count", max(cast(total_deaths as int)/population)*100 AS percent_population_death
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
GROUP BY location
ORDER BY percent_population_death DESC


	-- Countries with the highest death count
	-- Ordered by death count

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC


				-- CONTINENT BREAKDOWN
	-- death count and ratio for continents

SELECT continent, population, MAX(cast(total_deaths as int)) as "total_death_count", max(cast(total_deaths as int)/population)*100 AS percent_population_death
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
GROUP BY continent, population
ORDER BY percent_population_death DESC


	-- Continent with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


				--GLOBAL BREAKDOWN
	--Overview of Total Cases, Deaths and Death Percentage

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_ratio
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2	

	--Total Vaccinations to Population
	--Using CTE

WITH PopulationToVaccination (continent, location, date, population, new_vaccinations, vaccinated_rolling_count)
AS
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER
			(PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccinated_rolling_count
	FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY location, date
	)
	SELECT *,  (vaccinated_rolling_count/population)*100 AS population_vaccinated_percent
	FROM PopulationToVaccination

	-- Total Vaccinations to Population
	-- Using TEMP TABLE

		
DROP TABLE IF EXISTS #PopulationVaccinatedPercent
CREATE TABLE #PopulationVaccinatedPercent
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	vaccinated_rolling_count numeric
)

INSERT INTO #PopulationVaccinatedPercent
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER
			(PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccinated_rolling_count
	FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY location, date

	SELECT *,  (vaccinated_rolling_count/population)*100 AS population_vaccinated_percent
	FROM #PopulationVaccinatedPercent



				-- GERMANY BREAKDOWN
	-- Total cases, deaths and death percentage
	-- Ordered by date

SELECT location, date, total_cases, (total_deaths) AS total_deaths, (total_deaths/total_cases)*100 AS deaths_ratio
FROM PortfolioProject..CovidDeaths
WHERE location IN ('Germany')
ORDER BY date 


	-- Total death count and percentage to population

SELECT location, population, MAX(cast(total_deaths as int)) as "death_count", max(cast(total_deaths as int)/population)*100 AS percent_population_death
FROM PortfolioProject..CovidDeaths
WHERE location IN ('Germany')
GROUP BY location, population
ORDER BY percent_population_death DESC


	-- Total infected count and percentage to population

SELECT location, population, MAX(total_cases) as total_infenction_count, max(total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE location IN ('Germany')
GROUP BY location, population 
ORDER BY percent_population_infected DESC



	-- VIEWS FOR DATA VISUALIZATION



CREATE VIEW PercentPopulationVaccinated as 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CONVERT(INT, vac.new_vaccinations)) OVER
			(PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccinated_rolling_count
	FROM PortfolioProject..CovidDeaths AS dea
	JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY location, date






