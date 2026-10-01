-- All tables for this assignment were created using CSV files mentioned on Canvas, which were
-- imported into their respective relations using MySQL Workbench's Import Wizard.
-- All primary keys, foreign keys, and composite keys were created when buidling EER Diagram with interactive Workbench's UI. 

create database hw3;

use hw3;

-- Check if the tables were properly imported
select * from countries;
select * from operators;
select * from fuel_types;
select * from power_plants;
select * from generation_records;
select * from emission_metrics;

-- 1) Retrieve the plant name, country name, operator name, fuel category, fuel name, 
-- capacity (in MW), and commission year for all power plants without using table aliases. 
-- Sort the results in descending order by capacity.

select 
	power_plants.PlantName, 
	countries.CountryName, 
    operators.OperatorName,
    fuel_types.FuelCategory,
    fuel_types.FuelName,
    power_plants.CapacityMW,
    power_plants.CommissionYear
from power_plants natural join countries
				natural join operators
                natural join fuel_types
order by power_plants.CapacityMW desc;
                
-- 2) Retrieve the plant name, country code, calendar year, and annual generation (in GWh) for all 
-- power plants for the year 2024 without using table aliases. Sort the results in descending order by generation.

select 
	power_plants.PlantName,
    power_plants.CountryCode,
	generation_records.year,
    generation_records.generationgwh
from power_plants natural join generation_records
where generation_records.year = 2024
order by generation_records.generationgwh desc;

-- 3) Retrieve the plant name, country code, calendar year, annual generation (in GWh), 
-- and CO2 emissions (in tonnes) for all power plants for the year 2024 without using table aliases. 
-- Sort the results in ascending order by CO2 emissions.

select 
	power_plants.PlantName,
    power_plants.CountryCode,
    generation_records.year,
    generation_records.generationgwh,
    emission_metrics.co2emissionstonnes
from power_plants natural join generation_records
				natural join emission_metrics
where generation_records.year = 2024
order by emission_metrics.co2emissionstonnes asc;

-- 4) Write a SQL query using a Common Table Expression (CTE) to calculate the total cumulative 
-- power generation (in GWh) for each operator across all available years without using table aliases. 
-- Retrieve the operator name, headquarters country, and their total generated power, and sort the results 
-- in descending order by total generation.

with cumulative_power_gen as(
	select 
		power_plants.OperatorID,
		sum(generationgwh) as cumul_power_gen
	from power_plants natural join generation_records
	group by power_plants.OperatorID
    )

select 
	operators.OperatorName,
    operators.HeadquartersCountry,
    cumulative_power_gen.cumul_power_gen
from operators join cumulative_power_gen on operators.OperatorID = cumulative_power_gen.OperatorID
order by cumulative_power_gen.cumul_power_gen desc;


-- 5) Write a SQL query using two separate Common Table Expressions (CTEs)
-- one to calculate total power generation by country code and another to calculate total 
-- CO2 emissions by country code without using table aliases. Then, join these CTEs with 
-- the countries table to display the country name, total generation (in GWh), and total CO2 emissions (in tonnes). 
-- Sort the results in descending order by total generation.

with country_total_power_gen as(
	select 
		sum(generation_records.generationgwh) as total_generationgwh,
		power_plants.CountryCode
	from generation_records natural join power_plants
	group by power_plants.CountryCode
	),
    
country_total_emissions as(
	select 
		sum(emission_metrics.co2emissionstonnes) as total_emissions,
		power_plants.CountryCode
	from emission_metrics natural join power_plants
	group by power_plants.CountryCode
	)

select 
	countries.CountryName,
    country_total_power_gen.total_generationgwh,
    country_total_emissions.total_emissions
from countries natural join country_total_power_gen
			natural join country_total_emissions
order by country_total_power_gen.total_generationgwh desc;