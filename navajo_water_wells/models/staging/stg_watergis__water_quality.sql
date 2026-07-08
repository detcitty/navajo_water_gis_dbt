-- Cleans raw water quality lab sample results.
-- One row per well per sample date per analyte.

with source as (

    select * from {{ source('analytes', 'wells') }}

),,

renamed as (

    select
        well_id,
        cast(sample_date as date)                as sample_date,
        lower(trim(analyte))                     as analyte,
        cast(result_value as float64)             as result_value,
        trim(unit)                               as unit,
        cast(mcl_limit as float64)                as mcl_limit  -- EPA Maximum Contaminant Level

    from source
    where well_id is not null

)

select * from renamed
