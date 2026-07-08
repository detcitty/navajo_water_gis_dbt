select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select reading_date
from "navajo_water_wells"."raw"."water_levels_raw"
where reading_date is null



      
    ) dbt_internal_test