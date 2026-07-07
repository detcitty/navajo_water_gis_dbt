-- Aggregates readings up to one row per well, summarizing the
-- long-run trend in depth-to-water over the full observed history.

with readings as (

    select * from {{ ref('int_wells_joined_readings') }}

),

first_last as (

    select
        well_id,
        chapter_name,
        aquifer_type,
        min(reading_date)                                  as first_reading_date,
        max(reading_date)                                  as last_reading_date,
        count(*)                                           as num_readings,

        -- first and last depth readings, ordered by date
        min_by(depth_to_water_ft, reading_date)            as first_depth_to_water_ft,
        max_by(depth_to_water_ft, reading_date)            as last_depth_to_water_ft

    from readings
    group by 1, 2, 3

),

trend as (

    select
        *,
        last_depth_to_water_ft - first_depth_to_water_ft   as total_depth_change_ft,
        date_diff('year', first_reading_date, last_reading_date) as years_observed,
        round(
            (last_depth_to_water_ft - first_depth_to_water_ft)
            / nullif(date_diff('year', first_reading_date, last_reading_date), 0)
        , 2)                                                as avg_annual_decline_ft

    from first_last

)

select * from trend
