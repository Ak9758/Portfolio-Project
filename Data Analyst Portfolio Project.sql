--Total cases vs Total Deaths in India
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
From Portfolio_Project..Covid_Deaths
Where Location= 'India'
Order by 1,2

--Total cases vs Total Poplulation(Infection Rate)

Select Location,date,population,total_cases,(total_cases/population)*100 as Percent_population_infected
From Portfolio_Project..Covid_Deaths
Where continent is not null
Order by 1,2 

--Location-wise Infection rate per populatiob
Select Location, population,MAX (total_cases) as Highest_infection_count,MAX ((total_cases/population))*100 as Percent_population_infected
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group By Location, population
Order by 1,2 

--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as Total_death_count
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group By Location
Order by Total_death_count Desc

--Continent-wise highest death count per population
Select continent, MAX(cast(total_deaths as int)) as Total_death_count
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group By continent
Order by Total_death_count Desc

--Global numbers
Select date,SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group by date
Order by 1,2

--Total Population vs Vaccination
Select d.continent,d.location, d.date, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as CF_People_vaccinated
From Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
on d.date= v.date
and d.location= v.location
where d.continent is not null
order by 1,2

--Use CTE
With PopVsVac(continent,location,date,population,new_vaccinations,CF_People_vaccinated)
as
(
Select d.continent,d.location, d.date, d.population,v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as CF_People_vaccinated
From Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
on d.date= v.date
and d.location= v.location
where d.continent is not null
)
select *,(CF_People_vaccinated/population)*100 
from PopVsVac

--Temp Table

Create Table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
CF_People_vaccinated numeric
)

Insert into #VaccinationPercentage
Select d.continent,d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as CF_People_vaccinated
From Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
on d.date= v.date
and d.location= v.location
where d.continent is not null

select *,(CF_People_vaccinated/population)*100 
from #VaccinationPercentage;



--Creating view to store data for later visualisations

create view VaccinationPercentage
Select d.continent,d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as CF_People_vaccinated
From Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
on d.date= v.date
and d.location= v.location
where d.continent is not null

