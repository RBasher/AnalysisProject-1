Select *
From [PortfoilioProject1]..['Covid Deaths$']
where continent is not null
order by 3,4
--Select *
--From [PortfoilioProject1]..['Covid Vaccine$']
--order by 3,4
-- select data that is going to use
Select location,date,total_cases,new_cases,total_deaths,population
From [PortfoilioProject1]..['Covid Deaths$']
where continent is not null
order by 1,2
--looking at total case vs total death
--shows likelihood if u get contact of covid
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [PortfoilioProject1]..['Covid Deaths$']
where continent is not null
--where location like '%desh%'
order by 1,2
--total cases vs population
--what percentage of population got covid
Select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
From [PortfoilioProject1]..['Covid Deaths$']
where continent is not null
--where location like '%desh%'
order by 1,2
--looking at highest infection rate compare to population
Select location,population,Max(total_cases) as highestinfection,Max((total_cases/population)*100 )as CovidPercentage
From [PortfoilioProject1]..['Covid Deaths$']
--where location like '%desh%'
where continent is not null
Group By location,population
order by CovidPercentage desc
--showing countries with highest death per population

Select continent,Max(cast(total_deaths as int)) as totaldeathcount
From [PortfoilioProject1]..['Covid Deaths$']
--where location like '%desh%'
where continent is not null
Group By continent
order by totaldeathcount desc
--lets breakdown as continent
Select continent,Max(cast(total_deaths as int)) as totaldeathcount
From [PortfoilioProject1]..['Covid Deaths$']
--where location like '%desh%'
where continent is not null
Group By continent
--Global Numbers
Select Sum(new_cases) as totalcases,Sum(cast(new_deaths as int))as totaldeaths,Sum(cast(new_deaths as int ))/sum(new_cases )*100 as DeathPercentage
From [PortfoilioProject1]..['Covid Deaths$']
--where location like '%desh%'
where continent is not null

order by 1,2
--Looking at total vaccination vs total population
 
 --Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 --sum(Convert(int,vac.new_vaccinations)) 
 --from [PortfoilioProject1]..['Covid Deaths$']as dea
 --join [PortfoilioProject1]..['Covid Vaccine$'] as vac on 

 --dea.location=vac.location
 --and dea.date=vac.date
 --where dea.continent is not null
 --order by 2,3
  --Use CTE
 With PopVCVac(continent,location,date,population,new_vaccination,rollingpeoplevac) as
 (
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevac
 from [PortfoilioProject1]..['Covid Deaths$']as dea join 
 [PortfoilioProject1]..['Covid Vaccine$'] vac on
 dea.location=vac.location and
 dea.date=vac.date
Where dea.continent is not null

 --order by 2,3
 )
 Select*,(rollingpeoplevac/population)*100
 From PopVCVac
 --temptable
 drop table if exists #PopulationVaccineted
 create table #PopulationVaccineted
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
 rollingpeoplevac numeric)
 insert into #PopulationVaccineted
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevac
 from [PortfoilioProject1]..['Covid Deaths$']as dea join 
 [PortfoilioProject1]..['Covid Vaccine$'] vac on
 dea.location=vac.location and
 dea.date=vac.date
Where dea.continent is not null

 --order by 2,3
 

  Select*,(rollingpeoplevac/population)*100
 From #PopulationVaccineted
 --creating view for storing data for letter data visualization
 create view  PopulationVaccineted as
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevac
 from [PortfoilioProject1]..['Covid Deaths$']as dea join 
 [PortfoilioProject1]..['Covid Vaccine$'] vac on
 dea.location=vac.location and
 dea.date=vac.date
Where dea.continent is not null
Select*
From PopulationVaccineted