# Navajo Nation Groundwater Supply Risk — dbt Project

A dbt project that transforms raw Navajo Nation WaterGIS groundwater
monitoring data into a chapter-level supply risk assessment.

## Business question

Which Navajo Nation chapters are at the greatest risk of groundwater
supply decline, based on observed well trends and water quality?

## Data sources

- `wells_raw` — monitoring well locations and construction metadata
- `water_levels_raw` — depth-to-water time series per well
- `water_quality_raw` — periodic lab sample results (arsenic, uranium, TDS, etc.)

(Raw tables are assumed loaded into a `raw` schema in the warehouse via
whatever EL tool/process precedes this project — e.g. a scheduled load
from the public WaterGIS export.)

## Project structure

```
models/
├── staging/       -- 1:1 cleanup of raw source tables
├── intermediate/  -- joins + trend calculations (ephemeral)
└── marts/         -- business-facing tables
    ├── dim_wells.sql
    ├── fct_groundwater_levels.sql
    └── mart_regional_supply_risk.sql   <- flagship output
```

## The flagship model: `mart_regional_supply_risk`

Rolls well-level decline trends and water quality exceedances up to
one row per chapter, and assigns a **Low / Moderate / High** risk tier
based on:

- The share of monitored wells with a declining water table
  (average annual depth-to-water increase > 0.5 ft/year)
- The chapter-wide average annual decline rate
- Presence of wells exceeding EPA Maximum Contaminant Levels

This table is designed to answer a policy-relevant question directly,
rather than stopping at raw metrics — the kind of "so what" layer a
data analysis needs to be useful for decision-makers.

## Running the project

```bash
dbt seed        # load chapter_boundaries lookup
dbt run         # build staging -> intermediate -> marts
dbt test        # run schema + singular tests
dbt docs generate && dbt docs serve   # browse lineage graph
```

## Testing

- Schema tests: `unique`, `not_null`, `relationships`, `accepted_values`
- Singular test: `assert_no_negative_water_levels.sql` catches
  physically implausible readings

## Next steps

- Add a `snapshot` to track how risk tiers change over time
- Extend `mart_regional_supply_risk` with a chapter population
  weighting, to prioritize by people affected, not just well count
