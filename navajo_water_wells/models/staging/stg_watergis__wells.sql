-- Cleans and standardizes raw well metadata.
-- One row per monitoring well.

with source as (

    select * from {{ source('analytes', 'wells') }}

),

renamed as (

    select
        well_id,
        trim(chapter_name)                     as chapter_name,
        cast(latitude as float64)               as latitude,
        cast(longitude as float64)               as longitude,
        lower(trim(aquifer_type))               as aquifer_type,
        cast(well_depth_ft as float64)           as well_depth_ft,
        cast(date_drilled as date)               as date_drilled

    from source
    where well_id is not null

)

select * from renamed
