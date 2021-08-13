select * 
from PorfolioProject..CovidDeaths
where continent is not null
order by 3,4 

select * 
from PorfolioProject..CovidVacsination
order by 3,4


-- Select Data that we are going to be using. 

select location, date, total_cases, new_cases, total_deaths, population 
from PorfolioProject..CovidDeaths
order by 1,2 


-- Looking at the total cases vs total deaths 
--Likly hood of dying if you contracted Covid in United States
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where location like '%states'
order by 1,2 

-- Looking at the total cases vs the population in the United States 
select location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where location like '%states'
order by 1,2 

--Looking at counties with the highest infection rate compare to Population 
select location, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentofPopulationInfected
from PorfolioProject..CovidDeaths
group by location,population
order by PercentofPopulationInfected desc

-- Showing the Countries with Highest death count per population
select location, max(cast(Total_deaths as int)) as TotalDeath
from PorfolioProject..CovidDeaths
where continent is not null 
group by location
order by TotalDeath desc 

-- Total Death by Continent 
select location, max(cast(Total_deaths as int)) as TotalDeath
from PorfolioProject..CovidDeaths
where continent is null 
group by location
order by TotalDeath desc 


--- GLOBAL NUMBER
select sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where location like '%states' 
Group by date
order by 2,3



-- Total Population vs Vacsinations 

With PopVsVac (continent, location, Date, population, New_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*1000
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacsination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Using Temp Table to perform calculation on partition by in previous query
 
 
 DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*1000
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacsination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 from 
#PercentPopulationVaccinated



-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*1000
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacsination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


 