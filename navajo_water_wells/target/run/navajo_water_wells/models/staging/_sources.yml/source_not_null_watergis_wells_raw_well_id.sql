select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select well_id
from "navajo_water_wells"."raw"."wells_raw"
where well_id is null



      
    ) dbt_internal_test