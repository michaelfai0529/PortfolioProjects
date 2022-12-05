USE [sql_portfolio_prj_1]
GO

Select *
  From CovidDeaths
  Where continent is not null
  Order by 3,4

 --Select *
 --  From CovidVaccination
 --  Order by 3,4

 -- Select Data that gonna be used

 Select Location, date, total_cases, new_cases, total_deaths, population
 From CovidDeaths
 Where continent is not null
 Order by 1,2

 -- Looking Total Deaths : Total cases ratio (in  Hong Kong)
 -- Likelihood of dying if contract covid in Hong Kong

 Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases) as DeathPercentage
 From CovidDeaths
 Where location like '%Kong'
 Order by 1,2

 -- Looking at the Total case : Population ratio
 -- Likelihood of contrating covid

 Select Location, date, total_cases,  Population, (total_cases/Population)*100 as InfectionRate
 From CovidDeaths
 Where location like '%Kong'
 Order by 1,2


--Looking at conutry with Highest Infetion Rate (total_cases/Population)

 Select Location, Max(total_cases) as InfectionCount,  Population, Max ((total_cases/Population))*100 as InfectionRate
 From CovidDeaths
 --Where location like '%Kong'
 Group by Location, population
 Order by InfectionRate Desc
 

--Showing Countries with Highest Death Count Per Population

 Select Location, Max(cast(total_deaths as int)) as TotalDeathsCount, Population, Max ((total_deaths/Population))*100 as DeathRate
 From CovidDeaths
 --Where location like '%Kong'
 Where continent is not null
 Group by Location, Population
 Order by DeathRate Desc

 -- Analysis by continent(1)

 Select location, Max(cast(total_deaths as int)) as TotalDeathsCount
 From CovidDeaths
 --Where location like '%Kong'
 Where continent is null
 Group by  location 
 Order by TotalDeathsCount Desc
 -- Gotta clean the data up in the excel workbook later (remove non geographic data)

 -- Analysis by continent (2)
 Select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
 From CovidDeaths
 --Where location like '%Kong'
 Where Continent is not null
 Group by continent
 Order by TotalDeathsCount Desc
 -- look legit ~


-- Global Numbers

 Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From CovidDeaths
 Where location = 'world'
 Order by 1,2


 -- Looking at VaccinationRate
 -- Using CTE for new column
With VaccRate  (Continent, Location, Date, Population, new_vaccinations, AccumulatedVacc)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(bigint, vac.new_vaccinations)) 
    over (Partition by dea.location Order by dea.location, dea.Date) as AccumulatedVacc
	-- Showing the accumulated Vaccination time to time
 From CovidDeaths dea
 Join CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 
)
Select *, (AccumulatedVacc /population)*100 as VaccRate
From VaccRate 
-- For VaccRate more than 100%, this mean Vaccination > 1 dose per peroson, still usable for analysis


-- Temp Table #VaccRate
Drop Table if exists #VaccRate
Create Table #VaccRate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AccumulatedVac numeric
)

Insert into  #VaccRate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(bigint, vac.new_vaccinations)) 
    over (Partition by dea.location Order by dea.location, dea.Date) as AccumulatedVac
	--, (AccumulatedVaccination /population) as VaccinationRate
 From CovidDeaths dea
 Join CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 

Select *, (AccumulatedVac /population) as VaccRate
From #VaccRate


-- Creating View to store data

Create View VaccRate_1 as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(bigint, vac.new_vaccinations)) 
    over (Partition by dea.location Order by dea.location, dea.Date) as AccumulatedVacc
	-- Showing the accumulated Vaccination time to time
 From CovidDeaths dea
 Join CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 



