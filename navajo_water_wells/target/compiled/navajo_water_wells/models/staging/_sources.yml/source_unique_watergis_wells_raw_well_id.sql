
    
    

select
    well_id as unique_field,
    count(*) as n_records

from "navajo_water_wells"."raw"."wells_raw"
where well_id is not null
group by well_id
having count(*) > 1


