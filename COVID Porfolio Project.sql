SELECT * 
FROM CovidDeaths 
where continent is not null
order by 3,4


--SELECT * 
--FROM CovidVaccinations
--order by 3,4

SELECT location,date,total_cases,total_deaths,population 
from CovidDeaths
where continent is not null
order by 1,2


--total_cases vs total_deaths
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths
where continent is not null
order by 1,2

--how much percentage of population get infected
SELECT location,date,total_cases,population, (total_cases/population)*100 as Infected_Percentage 
from CovidDeaths
where location like '%states%' and  continent is not null
order by 1,2

--highest deaths percentage
SELECT location,max(total_deaths) as highest_deathscount ,population, max((total_deaths/population)*100) as  highest_death_per
from CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by 4 desc

--highest percentage population infected
SELECT location,max(total_cases) as highest_casescount ,population, max((total_cases/population)*100) as  highest_infected_per
from CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by 4 desc

--showing highest death count per population
SELECT location,max(cast(total_deaths as int)) as total_deathCount
from CovidDeaths
where continent is not null
group by location
order by total_deathCount desc



--grouping the data based on continent 
SELECT continent,max(cast(total_deaths as int)) as total_deathCount
from CovidDeaths
where continent is not null
group by continent
order by total_deathCount desc


--global overall cases and deaths on eachb date
SELECT date,sum(new_cases) as new_cases_count , sum(cast(new_deaths as int)) as new_deaths_count , sum(cast(new_deaths as int))/sum(new_cases)* 100 as deathpercentage
from CovidDeaths
where continent is not null
group by date

--joining coviddeaths and covidvacination tables
SELECT *
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.location = vac.location and
	dea.date = vac.date 



--SELECT dea.location,dea.population,vac.total_vaccinations
--from CovidDeaths dea
--join CovidVaccinations vac
--    ON dea.location = vac.location and
--	dea.date = vac.date 
--where dea.continent is not null

SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingpeople_vacinated
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.location = vac.location and
	dea.date = vac.date 
where dea.continent is not null


--CTE
with CTE_perPeople_vacinated(continent,location,date,population,new_vaccinations,rollingpeople_vacinated)as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingpeople_vacinated
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.location = vac.location and
	dea.date = vac.date 
where dea.continent is not null
)
SELECT *,(rollingpeople_vacinated/population)*100
from CTE_perPeople_vacinated


--temp table

DROP TABLE IF EXISTS #temp_perpop_vaccinated
CREATE TABLE #temp_perpop_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeople_vacinated numeric
)

Insert into #temp_perpop_vaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingpeople_vacinated
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.location = vac.location and
	dea.date = vac.date 
where dea.continent is not null

SELECT * 
from #temp_perpop_vaccinated




--Creating view to store data for later visualisations
Create View temp_perpop_vaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingpeople_vacinated
from CovidDeaths dea
join CovidVaccinations vac
    ON dea.location = vac.location and
	dea.date = vac.date 
where dea.continent is not null

SELECT *
from temp_perpop_vaccinated