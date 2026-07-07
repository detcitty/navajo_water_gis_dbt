-- Cleans raw depth-to-water time series readings.
-- One row per well per reading date.

with source as (

    select * from {{ source('watergis', 'water_levels_raw') }}

),

renamed as (

    select
        well_id,
        cast(reading_date as date)               as reading_date,
        cast(depth_to_water_ft as float64)        as depth_to_water_ft

    from source
    where well_id is not null
      and reading_date is not null

)

select * from renamed
