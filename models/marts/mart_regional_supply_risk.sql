/*
    mart_regional_supply_risk

    Purpose:
        Aggregates well-level groundwater trends up to the chapter
        (Navajo Nation administrative region) level, and assigns a
        supply risk tier based on how fast the water table is dropping
        and how many wells in the chapter are affected.

    Grain:
        One row per chapter.

    Consumers:
        Dashboard / map visual showing which chapters face the
        greatest groundwater supply risk, plus supporting detail
        for a written policy-style narrative.
*/

with trends as (

    select * from {{ ref('int_water_level_trends') }}

),

quality as (

    select
        well_id,
        max(case
            when result_value > mcl_limit then 1 else 0
        end) as has_exceedance

    from {{ ref('stg_watergis__water_quality') }}
    group by 1

),

well_level_risk as (

    select
        t.well_id,
        t.chapter_name,
        t.aquifer_type,
        t.avg_annual_decline_ft,
        t.years_observed,
        coalesce(q.has_exceedance, 0) as has_quality_exceedance,

        -- A well is "declining" if depth-to-water is increasing
        -- (i.e. the water table is dropping) by more than 0.5 ft/year
        case when t.avg_annual_decline_ft > 0.5 then 1 else 0 end as is_declining

    from trends t
    left join quality q on t.well_id = q.well_id
    where t.years_observed >= 2  -- require at least 2 years of history to trust the trend

),

chapter_rollup as (

    select
        chapter_name,
        count(*)                                        as num_wells_monitored,
        sum(is_declining)                                as num_wells_declining,
        round(avg(avg_annual_decline_ft), 2)             as avg_annual_decline_ft,
        sum(has_quality_exceedance)                      as num_wells_with_exceedance,
        round(
            sum(is_declining) * 1.0 / nullif(count(*), 0)
        , 2)                                              as pct_wells_declining

    from well_level_risk
    group by 1

),

scored as (

    select
        *,
        case
            when pct_wells_declining >= 0.66 and avg_annual_decline_ft > 1.0 then 'High'
            when pct_wells_declining >= 0.33 or avg_annual_decline_ft > 0.5 then 'Moderate'
            else 'Low'
        end as supply_risk_tier

    from chapter_rollup

)

select * from scored
order by
    case supply_risk_tier
        when 'High' then 1
        when 'Moderate' then 2
        else 3
    end,
    avg_annual_decline_ft desc
