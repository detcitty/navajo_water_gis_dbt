-- A singular test: this query should return ZERO rows if the data is valid.
-- dbt fails the test if any rows are returned.
--
-- Depth-to-water should never be negative (it would imply the water
-- table is above ground level, which for these wells is not physically
-- plausible and signals a data entry error).

select
    well_id,
    reading_date,
    depth_to_water_ft
from {{ ref('stg_watergis__water_levels') }}
where depth_to_water_ft < 0
