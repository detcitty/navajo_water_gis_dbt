-- One row per well: stable dimension table for joining to any fact table.

select
    well_id,
    chapter_name,
    aquifer_type,
    latitude,
    longitude,
    well_depth_ft,
    date_drilled

from {{ ref('stg_watergis__wells') }}
