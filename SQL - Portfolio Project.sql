select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
where continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count Per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTITNENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations (Using Joins, window function, partition clause)

select *
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- using CTE function

with PopvsVac (contitnent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
from #percentpopulationvaccinated

--creating view to store date for later tableau visualizations

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated 