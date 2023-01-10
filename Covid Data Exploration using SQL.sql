select *
from [Portfolio Project]..CovidDeaths$
order by 3,4

--select *
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

select location,date, total_cases, new_cases,population
from [Portfolio Project]..CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases,new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths$
where location like '%India%'
order by 1,2

--Total Cases vs Total Population
--shows what %age of population got covid in the country
select location, date, population, total_cases,(total_cases/population)*100 as Total_Percentage
from [Portfolio Project]..CovidDeaths$
where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select Location, Population, Max(total_cases) as Highest_Infection_Count,max((total_cases/population))*100 as Percent_Population_Infected
from [Portfolio Project]..CovidDeaths$
--where location like '%India%'
group by location,population
order by Percent_Population_Infected desc

--For India
select location, population, Max(total_cases) as highest_infection_count,max((total_cases/population))*100 as Percent_Population_Infected
from [Portfolio Project]..CovidDeaths$
where location like '%India%'
group by location,population
order by Percent_Population_Infected desc

--showing countries with highest death count per population
select location, Max(cast(total_deaths as int)) as highest_death_count
from [Portfolio Project]..CovidDeaths$
--where location like '%India%'
where continent is not null
group by location
order by highest_death_count desc

--showing continents with highest death count per population
select location, Max(cast(total_deaths as int)) as highest_death_count
from [Portfolio Project]..CovidDeaths$
--where location like '%India%'
where continent is null
group by location
order by highest_death_count desc


--Not the exact count 
select continent, Max(cast(total_deaths as int)) as highest_death_count
from [Portfolio Project]..CovidDeaths$
--where location like '%India%'
where continent is not null
group by continent
order by highest_death_count desc

--Global numbers with date
select date,sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage-- total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths$
--where location like '%India%' 
where continent is not null
group by date
order by 1,2

--global numbers without date
select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage-- total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths$
--where location like '%India%' 
where continent is not null
order by 1,2

--Looking at Total Population vs New Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location 
	order by dea.location,dea.date) as RollingPeopleVaccination
--RollingPeopleVaccination/Population * 100
from [Portfolio Project]..CovidDeaths$ as Dea
join [Portfolio Project]..CovidVaccinations$ as Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with PopvsVacc (continent,location,date,population,new_vaccinations,RollingPeopleVaccination)
as
(
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location 
		order by dea.location,dea.date) as RollingPeopleVaccination
	from [Portfolio Project]..CovidDeaths$ as Dea
	join [Portfolio Project]..CovidVaccinations$ as Vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select *,(RollingPeopleVaccination/Population * 100)
from PopvsVacc
where location like '%INDIA%'

--Temp Table


Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location 
		order by dea.location,dea.date) as RollingPeopleVaccination
	from [Portfolio Project]..CovidDeaths$ as Dea
	join [Portfolio Project]..CovidVaccinations$ as Vac
		on dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

Select *,(RollingPeopleVaccination/Population *100)
from #PercentPopulationVaccinated

--Creating view

USE [Portfolio Project] 
GO
create view Vacc_Popul_Percent as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location 
		order by dea.location,dea.date) as RollingPeopleVaccination
	from [Portfolio Project]..CovidDeaths$ as Dea
	join [Portfolio Project]..CovidVaccinations$ as Vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3



select *
from Vacc_Popul_Percent

/****** Script for selectTopNRows command from ssms *****/
select top(1000) [continent],
				[location],
				[date],
				[population],
				[new_vaccinations],
				[RollingPeopleVaccination]
from [Portfolio Project].[dbo].[Vacc_Popul_Percent]