-- One row per well per reading date. Ready to plug into a time series chart.

select
    well_id,
    chapter_name,
    aquifer_type,
    reading_date,
    depth_to_water_ft,
    depth_change_ft

from {{ ref('int_wells_joined_readings') }}
