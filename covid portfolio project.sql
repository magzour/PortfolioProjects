SELECT * FROM PortfolioProject..coviddeaths$ 
Where continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..covidvaccinations$ ORDER BY 3,4
-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..coviddeaths$ ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM PortfolioProject..coviddeaths$ 
Where location Like '%states%' ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage FROM PortfolioProject..coviddeaths$ 
--Where location Like '%states%' 
ORDER BY 1,2

--Looking at countries with highest Infection Rate compared to Population

SELECT continent, location, MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..coviddeaths$ 
--Where location Like '%states%' 
Group By continent, location
ORDER BY PercentPopulationInfected desc


--Showing Countries with highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..coviddeaths$
Where continent is not null
Group by location, population
Order by TotalDeathCount DESC

-- Let's break things down by continent


-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..coviddeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, 
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100
as DeathPercentage
FROM PortfolioProject..coviddeaths$
--WHERE location like '%states'
Where continent is not null
--Group By date
Order By 1,2

--Looking at total population vs vaccinations
With PopvsVac (continent, Location, Date, Population, new_vacciantions, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(Convert (bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER By dea.location, dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100

From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac

-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(Convert (bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER By dea.location, dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100

From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location 
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
SUM(Convert (bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER By dea.location, dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100

From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated