Select * From Project2..CovidDeaths
Order by 3,4;

Select * From Project2..CovidVaccinations
Order By 3,4;

--select data that we are going to be using--

Select location,date,total_cases,new_cases,total_deaths,population
From Project2..coviddeaths
Order by 1,2;

--Looking at Total cases VS Total Deaths--
-- Shows likelihood of dying if you contract covid in your country--

Select Location,Date,Total_cases,Total_deaths,(Total_Deaths/Total_Cases)*100 AS Death_Percent
From Project2..CovidDeaths
Where Location Like '%states%'
Order by 1,2;

--Looking at total cases VS Population--
--Shows what percentage of population got covid--

Select Location,Date,Total_cases,Population,(Total_cases/Population)*100 AS Covid_Percent
From project2..CovidDeaths
Where Location like '%india%'
Order by 1,2;

--Countries with highest infection rate compared to populations--

Select Location,MAX(Total_cases)AS HighestInfectionCount,population,MAX((Total_Cases/Population)*100)
AS HighestInfectedPercent
From Project2..CovidDeaths
Group by Location,Population
Order by HighestInfectedPercent Desc;

--Countries with highest death rate per Population--

Select Location,MAX(Cast(Total_Deaths as int)) AS HighestDeath from Project2..CovidDeaths
--Cast is used because we are changing is data type to int , it was varchar before--
Where Continent is not null
Group by Location
Order by HighestDeath Desc;

--Let's break things down by continent--

Select Continent,MAX(Cast(Total_Deaths As int)) AS HighestDeathCount 
From Project2..CovidDeaths
Where Continent is not null
Group By Continent
Order by HighestDeathCount Desc ;

--Showing Death Count with highest death count per population--

Select Continent,MAX(Cast(Total_Deaths As int)) AS HighestDeathCount 
From Project2..CovidDeaths
Where Continent is not null
Group By Continent
Order by HighestDeathCount Desc ;


--Global Numbers--
--Sum of New cases and new deaths by date

Select Date,Sum(New_Cases)AS TotalCases,Sum(Cast(New_Deaths as int))AS TotalDeath,
Sum(Cast(New_Deaths as int))/Sum(New_Cases)*100 AS DeathPercent
From Project2..CovidDeaths
Where Continent is not null
Group by Date
Order by 1,2

--Sum of new cases and new deaths without the date

Select Sum(New_Cases)AS TotalCases,Sum(Cast(New_Deaths as int))AS TotalDeath,
Sum(Cast(New_Deaths as int))/Sum(New_Cases)*100 AS DeathPercent
From Project2..CovidDeaths
Where Continent is not null
--Group by Date
Order by 1,2

--Looking for Total Population VS Vaccination
 
 With POPVSVAC(Continent,Location,Date,Population,New_vaccination,RollingPeoplevacciation)
 as
(Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(Cast(New_Vaccinations as Int)) Over (Partition By d.Location Order by d.location,d.date ) As RollingPeoplevaccination
From Project2..CovidDeaths d
Join Project2..CovidVaccinations v
ON d.Location=v.Location
and d.date= v.date
Where d.continent is not null
--Order by 2,3
)
Select *,(RollingPeoplevacciation/Population)*100 
from POPVSVAC

--Temp Table--

Drop Table if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccination Numeric,
RollingPeoplevaccination Numeric
)
Insert Into #PercentPopulationVaccinated
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(Cast(New_Vaccinations as Int)) Over (Partition By d.Location Order by d.location,d.date ) As RollingPeoplevaccination
From Project2..CovidDeaths d
Join Project2..CovidVaccinations v
ON d.Location=v.Location
and d.date= v.date
Where d.continent is not null
--Order by 2,3
Select *,(RollingPeoplevacciation/Population)*100 
from #PercentPopulationVaccinated

--Creating View to Store data for later visualization--

Create View PercentPopulationVaccinated as

Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(Cast(New_Vaccinations as Int)) Over (Partition By d.Location Order by d.location,d.date ) As RollingPeoplevaccination
From Project2..CovidDeaths d
Join Project2..CovidVaccinations v
ON d.Location=v.Location
and d.date= v.date
Where d.continent is not null;





