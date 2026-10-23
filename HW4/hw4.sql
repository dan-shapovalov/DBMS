-- All tables for this assignment were created using CSV files mentioned on Canvas, which were
-- imported into their respective relations using MySQL Workbench's Import Wizard.

create database hw4;
use hw4;

select * from countries;
select * from organizations;
select * from launch_sites;
select * from rockets;
select * from missions;
select * from payloads;

-- 1) Retrieve the mission name, rocket name, organization name, launch site name, destination, 
-- launch year, and outcome for all space missions without using table aliases. Sort the results 
-- in descending order by launch year and ascending order by mission name.

select missions.MissionName, 
	rockets.RocketName, 
	organizations.OrgName, 
    launch_sites.SiteName, 
    missions.Destination,
    missions.LaunchYear,
    missions.Outcome
from missions natural join rockets
				natural join organizations
                natural join launch_sites
order by missions.LaunchYear desc, missions.MissionName asc;

-- 2) Retrieve the mission name, rocket name, payload name, payload type, and payload mass (in kg) 
-- for all payloads launched in 2024 without using table aliases. Sort the results in descending order 
-- by payload mass.

select missions.MissionName,
	rockets.RocketName, 
    payloads.PayloadName,
    payloads.PayloadType,
    payloads.MassKg
from missions natural join payloads
				natural join rockets
where missions.LaunchYear = 2024
order by payloads.MassKg desc;

-- 3) Retrieve all launch sites along with their matching mission names, rockets, and launch years 
-- for missions that took place in 2024 without using table aliases, ensuring that launch sites with 
-- no recorded 2024 missions still appear in the results with null values for the mission fields. 
-- Sort the results in alphabetical order by launch site name.

select launch_sites.SiteName,
	missions.MissionName,
    rockets.RocketName,
    missions.LaunchYear
from launch_sites left join missions on launch_sites.SiteID = missions.SiteID and missions.LaunchYear = 2024
				left join rockets using (RocketID)
order by launch_sites.SiteName asc;

-- 4) Write a SQL query using a Common Table Expression (CTE) to calculate the total payload mass (in kg) 
-- deployed by each organization across all missions without using table aliases. Retrieve the organization 
-- name, headquarters country, organization type, and total payload mass, and sort the results in descending 
-- order by total payload mass.

with total_payload_mass as(
	select organizations.OrgName,
		sum(payloads.MassKg) as sum_masskg
	from organizations natural join rockets
                        natural join missions
                        natural join payloads
	group by organizations.OrgName
)
select organizations.OrgName,
	organizations.HeadquartersCountry,
    organizations.OrgType,
    total_payload_mass.sum_masskg
from organizations natural join total_payload_mass
order by total_payload_mass.sum_masskg desc;

-- 5) Write a SQL query using two separate Common Table Expressions (CTEs)—one to calculate total missions 
-- by country code and another to calculate total payload mass by country code without using table aliases. 
-- Then, combine these CTEs with the countries table to display the country name, total number of missions, 
-- and total payload mass (in kg). Sort the results in descending order by total payload mass.

with total_missions as(
	select count(missions.MissionID) as mission_count,
		countries.CountryCode
	from countries natural join launch_sites
					natural join missions
	group by countries.CountryCode
),

total_payload_mass as(
	select sum(payloads.MassKg) as sum_masskg,
		countries.CountryCode
	from countries natural join launch_sites
					natural join missions
                    natural join payloads
	group by countries.CountryCode
)

select countries.CountryName, 
		total_missions.mission_count,
        total_payload_mass.sum_masskg
from countries natural join total_missions
				natural join total_payload_mass
order by total_payload_mass.sum_masskg desc;