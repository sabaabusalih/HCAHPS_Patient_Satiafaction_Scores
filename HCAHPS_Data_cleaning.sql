--- We will be using two tables: hcahps_data and hospital_beds
--select * from "postgres"."Hospital_Data".hcahps_data

--select * from "postgres"."Hospital_Data".hospital_beds

-----------------------------------
-- convert date from text format to date format
-- adding the zero back to some of the provider_ccn, excel treated it as a number so the zero was choped automatically, we want 6 maximum characters
--------------------------------------
create table "postgres"."Hospital_Data".Tableau_File as
with hospital_beds_prep as(
select lpad(cast(provider_ccn as text),6,'0') as provider_ccn,
hospital_name,
to_date(fiscal_year_begin_date,'MM/DD/YYYY') as fiscal_year_begin_date,         
to_date(fiscal_year_end_date,'MM/DD/YYYY') as fiscal_year_end_date,
number_of_beds,
-------------------------------
-- used partitioning to order each provider ccn by date, to get the most recent number of beds
--------------------------------
row_number() over (partition by provider_ccn order by to_date(fiscal_year_end_date,'MM/DD/YYYY') desc) as nth_row
from "postgres"."Hospital_Data".hospital_beds)

-----------------
-- use the below code to make sure there are no duplicate provider
-------------------
--select provider_ccn, count(*) as count_of_rows
--from hospital_beds_prep
--where nth_row = 1
--group by provider_ccn
--order by count(*)
------
-----------------------------
-- left join Hcahps and beds table on provider_ccn
------------------------------- 
select lpad(cast(facility_id as text),6,'0') as provider_ccn
,to_date(start_date,'MM/DD/YYYY') as start_date_converted
,to_date(end_date,'MM/DD/YYYY') as end_date_converted
,hcahps.*
,beds.number_of_beds
,beds.fiscal_year_begin_date as beds_start_report_period
,beds.fiscal_year_end_date as beds_end_report_period
from "postgres"."Hospital_Data".hcahps_data as hcahps
left join hospital_beds_prep as beds
on lpad(cast(facility_id as text),6,'0') = beds.provider_ccn
and beds.nth_row=1