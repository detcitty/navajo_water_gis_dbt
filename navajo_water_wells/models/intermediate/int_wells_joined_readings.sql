-- Joins well metadata onto each water level reading and computes
-- the change in level since the prior reading for that well.

with wells as (

    select * from {{ ref('stg_watergis__wells') }}

),

readings as (

    select * from {{ ref('stg_watergis__water_levels') }}

),

joined as (

    select
        r.well_id,
        w.chapter_name,
        w.aquifer_type,
        w.well_depth_ft,
        r.reading_date,
        r.depth_to_water_ft,
        lag(r.depth_to_water_ft) over (
            partition by r.well_id order by r.reading_date
        ) as prior_depth_to_water_ft

    from readings r
    left join wells w on r.well_id = w.well_id

),

with_change as (

    select
        *,
        -- Depth-to-water INCREASING means the water table is DROPPING
        depth_to_water_ft - prior_depth_to_water_ft as depth_change_ft

    from joined

)

select * from with_change
