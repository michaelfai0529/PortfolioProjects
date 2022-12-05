/*
Queries used for Tableau Project
*/
USE sql_portfolio_prj_1


-- 1. Calculate the Death Percentage all over the world up to date

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%Kong'
where continent is not null 
--Group By date
order by 1,2




-- 2. Let's take a look at Total_Death_ByContinent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International') and location not like ('%income')
Group by location
order by TotalDeathCount desc



-- 3. InfectionRate in each country

Select Location,continent, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%Kong'
Where continent is not null and location not like 'income%'
Group by Location, Population,continent
order by PercentPopulationInfected desc



-- 4. InfectionRate in each country- Time to Time


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Where continent is not null and location not like 'income%'
Group by Location, Population, date
order by PercentPopulationInfected desc



-- 5. See the Vaccination Number over the world & VaccRate

With VaccRate (location,population, Count_Vaccination,Count_FullyVaccination)
as
(
Select vac.location, dea.population, max(cast(people_vaccinated as Bigint)) as Count_Vaccination , max(cast(people_fully_vaccinated as bigint)) as Count_FullyVaccination
--, (Count_Vaccination/dea.population) as VaccRate, (Count_FullyVaccination/dea.population) as Fully_VaccRate
From CovidVaccination vac
Left Join CovidDeaths dea
on dea.location = vac.location and dea.date= vac.date
Where vac.location = 'world'
Group by vac.location, dea.population
)
Select*,(Count_Vaccination/population)*100 as VaccRatePercent, (Count_FullyVaccination/population)*100 as Fully_VaccRatePercent
From VaccRate



-- 6. Get data & See Vaccination Rate over time

With VaccRate (date,location,population, Count_Vaccination,Count_FullyVaccination)
as
(
Select vac.date, vac.location, dea.population, people_vaccinated as Count_Vaccination , people_fully_vaccinated  as Count_FullyVaccination
--, (Count_Vaccination/dea.population) as VaccRate, (Count_FullyVaccination/dea.population) as Fully_VaccRate
From CovidVaccination vac
Left Join CovidDeaths dea
on dea.location = vac.location and dea.date= vac.date
Where vac.location = 'world'
)
Select*,(Count_Vaccination/population)*100 as VaccRatePercent, (Count_FullyVaccination/population)*100 as Fully_VaccRatePercent
From VaccRate
Order by date desc


-- 7. look at world death rate over time time

Select date,new_cases , new_deaths , cast(new_deaths as int)/(NULLIF(New_Cases,0))*100 as DeathPercentage
From CovidDeaths
Where location = 'world'
--Group By date
order by 1,2



-- 8. Combining 2 CTE (6 & 7)

With 
CTE_VaccRate (date,location,population, Count_Vaccination,Count_FullyVaccination)
as
(
Select vac.date, vac.location, dea.population, people_vaccinated as Count_Vaccination , people_fully_vaccinated  as Count_FullyVaccination
--, (Count_Vaccination/dea.population) as VaccRate, (Count_FullyVaccination/dea.population) as Fully_VaccRate
From CovidVaccination vac
Left Join CovidDeaths dea
on dea.location = vac.location and dea.date= vac.date
Where vac.location = 'world'
),

CTE_DeaRate (date,location,new_cases,new_deaths,DeathPercentage)
as
(
Select date,location,new_cases , new_deaths , cast(new_deaths as int)/(NULLIF(New_Cases,0))*100 as DeathPercentage
From CovidDeaths
Where location = 'world'
)
Select*,(A.Count_Vaccination/population)*100 as VaccRatePercent,(A.Count_FullyVaccination/population)*100 as Fully_VaccRatePercent
From CTE_VaccRate A inner join CTE_DeaRate B
on A.location = B.location and A.date= B.date
Order by A.date 




















