# Mobility Demand Intelligence Platform

A Snowflake-based data platform that integrates NYC taxi trip data with NOAA weather observations to analyze how weather conditions influence urban mobility demand and revenue patterns.

## Architecture

```
External Sources
  |-- NYC Yellow Taxi CSV (Jan 2015)
  |-- NOAA Weather (Snowflake Public Data)
  |
  v
RAW (Snowflake)
  |-- trips_raw        (COPY INTO from CSV)
  |-- weather_raw       (VIEW over NOAA public dataset)
  |
  v
STAGING (dbt views)
  |-- stage_trips       (type casting, timestamp parsing, filtering)
  |-- stage_weather     (daily aggregation across NYC stations)
  |
  v
CORE (dbt tables)
  |-- fact_trips_daily  (daily trip aggregations)
  |-- dim_weather_daily (daily weather + rain flag)
  |
  v
MART (dbt table)
  |-- daily_mobility_weather_metrics (joined mobility + weather)
```

## Tech Stack

| Component       | Technology                    |
|-----------------|-------------------------------|
| Data Platform   | Snowflake                     |
| Transformation  | dbt Core 1.11                 |
| Ingestion       | Snowflake Stage + COPY INTO   |
| Weather Data    | NOAA via Snowflake Public Data|
| Version Control | Git + GitHub                  |
| Compute         | X-Small Warehouse             |

## Project Structure

```
src/
  sql/
    01_setup.sql              -- Warehouse, database, schemas, role, grants
    02_raw_trips.sql          -- File format, stage, table, COPY INTO
    03_raw_weather.sql        -- NOAA weather view
    analysis/
      demand_overview.sql     -- Daily trip count trend
      revenue_trend.sql       -- Revenue + avg fare trend
      weather_impact.sql      -- Rain vs non-rain comparison
      temperature_vs_demand.sql -- Temperature vs trip count
  dbt/mobility_dbt/
    models/
      staging/                -- Views: type casting, cleaning
      core/                   -- Tables: aggregation, dimensions
      marts/                  -- Tables: analytics-ready dataset
    macros/                   -- Custom schema name generation
    packages.yml              -- dbt-utils dependency
  docs/
    PRD.md                    -- Product requirements
    Design-HLD.md             -- High-level design
    TODO.md                   -- Sprint plan
```

## Setup

### Prerequisites

- Snowflake account
- Python 3.10+ with dbt-snowflake installed
- Snowflake Public Data (NOAA) shared database mounted as `snowflake_public_data_free`

### 1. Snowflake Infrastructure

Run `src/sql/01_setup.sql` in Snowsight as `ACCOUNTADMIN`. Replace `<YOUR_SNOWFLAKE_USERNAME>` with your username.

### 2. Load Raw Data

1. Download `yellow_tripdata_2015-01.csv` from NYC TLC
2. Upload to Snowflake internal stage: `PUT file:///path/to/yellow_tripdata_2015-01.csv @mobility_db.raw.taxi_trips_internal_stage;`
3. Run `src/sql/02_raw_trips.sql` in Snowsight
4. Run `src/sql/03_raw_weather.sql` in Snowsight

### 3. Configure dbt Profile

Add to `~/.dbt/profiles.yml`:

```yaml
mobility_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <YOUR_ACCOUNT>
      user: <YOUR_USERNAME>
      password: <YOUR_PASSWORD>
      role: mobility_role
      warehouse: mobility_wh
      database: mobility_db
      schema: staging
      threads: 4
```

### 4. Run dbt

```bash
cd src/dbt/mobility_dbt
dbt deps
dbt run --profile mobility_dbt
dbt test --profile mobility_dbt
```

### 5. Generate Docs

```bash
dbt docs generate --profile mobility_dbt
dbt docs serve --profile mobility_dbt
```

## Sample Results

**Data Quality Spot-Checks (January 2015):**

| Check                  | Result                          |
|------------------------|---------------------------------|
| Raw row count          | 500,000                         |
| Mart total trips       | 496,618 (filtered bad records)  |
| Days covered           | 31 (Jan 1 - Jan 31)            |
| Daily revenue range    | $67,606 - $315,621              |
| Average fare range     | $8.85 - $12.83                  |
| Temperature range      | -10.5 to 7.9 (tenths of C)     |
| Rainy days             | 27                              |
| Dry days               | 4                               |

**dbt Tests:** 22 tests, all passing (not_null, unique, accepted_values, relationships).

## Key Design Decisions

- **Layered architecture** (RAW to STAGING to CORE to MART) separates concerns and enables independent testing at each layer
- **Views for staging** (zero storage cost), **tables for core/mart** (pre-computed for query performance)
- **Multi-format timestamp parsing** with COALESCE + TRY_TO_TIMESTAMP_NTZ for resilience against format variations
- **LEFT JOIN** from trips to weather preserves all trip days even when weather data is missing
- **Future grants** on schemas ensure new dbt-created objects are automatically accessible

## Documentation

- [Product Requirements (PRD)](src/docs/PRD.md)
- [High-Level Design (HLD)](src/docs/Design-HLD.md)
- [Sprint Plan (TODO)](src/docs/TODO.md)