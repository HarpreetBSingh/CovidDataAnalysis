Select *
From CovidData..CovidDeaths
order by 3,4

--Select *
--From CovidData..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
from CovidData..CovidDeaths
order by 1,2
--We notice how for some countries, such as Afghanistan, they did not recording deaths until a month in

-- Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_rate
from CovidData..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths for Canada
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_rate
from CovidData..CovidDeaths
where Location = 'Canada'
order by 1,2
-- Possibly due to way it was reported, death rate was over 9% in May of 2020 in Canada.
-- If you were to get COVID today, the death rate could be 1.05%.

--Looking at Total Cases vs Population
SELECT Location, date, total_cases, population,(total_cases/population)*100 as infection_rate
from CovidData..CovidDeaths
where Location = 'Canada'
order by 1,2
--Shows that 9.74% of the Canadian population has gotten COVID

SELECT Location, Population, MAX(total_cases) as CovidCount,MAX(total_cases/population)*100 as infection_rate
from CovidData..CovidDeaths
Group by Location, Population
order by infection_rate desc
--Viewing population, covid count, and infection rate by country

SELECT Location, MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidData..CovidDeaths
where continent is not null
Group by Location
order by Total_Death_Count desc
--Showing countries with highest death count

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidData..CovidDeaths
where continent is null 
AND location != 'Upper middle income' 
AND location != 'High income' 
AND location != 'Lower middle income' 
AND location != 'Low income' 
AND location != 'International' 
AND location != 'European Union' 
Group by location
order by Total_Death_Count desc
--Showing continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidData..CovidDeaths
where continent is null 
AND location = 'Upper middle income' 
OR location = 'High income' 
OR location = 'Lower middle income' 
OR location = 'Low income' 
Group by location
order by Total_Death_Count desc
--Showing highest death count varied by level of income
--Low amount of low income deaths can indicate that there is a lack of testing and resources

SELECT date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
from CovidData..CovidDeaths
where continent is not null
Group by date
order by 1,2
-- We notice how the death rate is as low as .3% these days, when it was well over 2% during the peak

SELECT sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
from CovidData..CovidDeaths
where continent is not null
order by 1,2
-- Global death percentage is 1.215%, probably due to how low the death rate has become in recent months

Select *
From CovidData..CovidDeaths d
Join CovidData..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
-- Joining tables to see if everything works

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vacination_Total)
as
(
Select d.continent, d.location,d.date,d.population,v.new_vaccinations,SUM(Cast(v.new_vaccinations as bigint)) OVER (Partition by d.location ORDER by d.location, d.date) as Rolling_Vacination_Total
From CovidData..CovidDeaths d
Join CovidData..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null
)
Select *, (Rolling_Vacination_Total/Population)*100 as Vaccination_Percentage
From PopvsVac
-- New vaccinations by continent, location, and day
-- Rolling vacination totals and percentages

-- Creating temp table (Percentage of population vaccinated)
Drop table if exists #VaccinationPercentage
Create Table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vacination_Total numeric)

Insert into #VaccinationPercentage
Select d.continent, d.location,d.date,d.population,v.new_vaccinations,SUM(Cast(v.new_vaccinations as bigint)) OVER (Partition by d.location ORDER by d.location, d.date) as Rolling_Vacination_Total
From CovidData..CovidDeaths d
Join CovidData..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null

Select *, (Rolling_Vacination_Total/Population)*100 as Vaccination_Percentage
From #VaccinationPercentage

--Creating a view for storage of data

Create View VaccinationPercentage as
Select d.continent, d.location,d.date,d.population,v.new_vaccinations,SUM(Cast(v.new_vaccinations as bigint)) OVER (Partition by d.location ORDER by d.location, d.date) as Rolling_Vacination_Total
From CovidData..CovidDeaths d
Join CovidData..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null

SELECT * 
FROM VaccinationPercentage

Create View Canadian_COVID_Death_Rate as
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_rate
from CovidData..CovidDeaths
where Location = 'Canada'

SELECT * 
FROM Canadian_COVID_Death_Rate

Create View Canadian_COVID_Infection_Rate as
SELECT Location, date, total_cases, population,(total_cases/population)*100 as infection_rate
from CovidData..CovidDeaths
where Location = 'Canada'

SELECT *
FROM Canadian_COVID_Infection_Rate

Create View Death_Count_By_Country as
SELECT Location, MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidData..CovidDeaths
where continent is not null
Group by Location
--Showing countries with highest death count

Select * FROM 
Death_Count_By_Country

Create View Death_Rate_By_Day as
SELECT date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
from CovidData..CovidDeaths
where continent is not null
Group by date
-- We notice how the death rate is as low as .3% these days, when it was well over 2% during the peak

Select * From
Death_Rate_By_Day