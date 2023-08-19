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











