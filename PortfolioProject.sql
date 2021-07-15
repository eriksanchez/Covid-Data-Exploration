SELECT 
	*
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT null
ORDER BY 
	3,4


--SELECT 
--	*
--FROM 
--	PortfolioProject..CovidVaccinations
--order by
--	3,4


--Select Data that we are going to be using 

SELECT
	Location, date,total_cases,new_cases,total_deaths,population
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
ORDER BY
	1,2


--Looking at Total Cases Vs Total Deaths
--Shows likihood of dying if you contract covid in your country 
SELECT
	Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%states%'
	AND continent IS NOT null
ORDER BY
	1,2

--Looking at Totatl Cases vs Population 
--Shows what percentage of population got covid

Select Location, date, Population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population 
Select Location, Population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationinfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationinfected desc


--Showing Countries with Highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentageGlobally
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as 
(
	Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	

)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

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
	Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	
	Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	

Select *
From PercentPopulationVaccinated
