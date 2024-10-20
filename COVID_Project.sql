Select *
From Portfolio_Project..CovidDeaths
order by 3,4

--Select *
--From Portfolio_Project..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where location like '%states%'
and where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
Select Location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
Where location like '%states%'
and where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by Location, population
order by PercentPopulationInfected desc

-- Showing Continent with Highest Death Count per Population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing Countries with Highest Death Count per Population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Global Numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Globally, death percentage is ~2%
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccinations USING CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
-- partition by location so we restart with new country
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Looking at Total Population vs Vaccinations USING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
-- partition by location so we restart with new country
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
