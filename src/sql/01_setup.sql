USE ROLE accountadmin;

-- 1) Warehouse (cost-controlled)
CREATE WAREHOUSE IF NOT EXISTS mobility_wh
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- 2) Database + layered schemas
CREATE DATABASE IF NOT EXISTS mobility_db;

CREATE SCHEMA IF NOT EXISTS mobility_db.raw;
CREATE SCHEMA IF NOT EXISTS mobility_db.staging;
CREATE SCHEMA IF NOT EXISTS mobility_db.core;
CREATE SCHEMA IF NOT EXISTS mobility_db.mart;

-- 3) Project role (least privilege for day-to-day work)
CREATE ROLE IF NOT EXISTS mobility_role;

-- 4) Grants: warehouse
GRANT USAGE, OPERATE ON WAREHOUSE mobility_wh TO ROLE mobility_role;

-- 5) Grants: database-level
GRANT USAGE ON DATABASE mobility_db TO ROLE mobility_role;

-- 6) Grants: schema-level usage
GRANT USAGE ON SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT USAGE ON SCHEMA mobility_db.staging TO ROLE mobility_role;
GRANT USAGE ON SCHEMA mobility_db.core TO ROLE mobility_role;
GRANT USAGE ON SCHEMA mobility_db.mart TO ROLE mobility_role;

-- 7) Grants: create objects in each schema
--    RAW needs extra privileges for stages, file formats, and data loading
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT CREATE STAGE, CREATE FILE FORMAT ON SCHEMA mobility_db.raw TO ROLE mobility_role;

GRANT CREATE TABLE, CREATE VIEW ON SCHEMA mobility_db.staging TO ROLE mobility_role;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA mobility_db.core TO ROLE mobility_role;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA mobility_db.mart TO ROLE mobility_role;

-- 8) Grants: read/write on ALL existing and future objects in every schema
--    This ensures dbt can SELECT from tables, run tests, and drop/recreate models
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON ALL TABLES IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON ALL TABLES IN SCHEMA mobility_db.staging TO ROLE mobility_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON ALL TABLES IN SCHEMA mobility_db.core TO ROLE mobility_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON ALL TABLES IN SCHEMA mobility_db.mart TO ROLE mobility_role;

GRANT SELECT ON ALL VIEWS IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA mobility_db.staging TO ROLE mobility_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA mobility_db.core TO ROLE mobility_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA mobility_db.mart TO ROLE mobility_role;

-- 9) Grants: future objects (so new tables/views created by dbt are automatically accessible)
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON FUTURE TABLES IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON FUTURE TABLES IN SCHEMA mobility_db.staging TO ROLE mobility_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON FUTURE TABLES IN SCHEMA mobility_db.core TO ROLE mobility_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
    ON FUTURE TABLES IN SCHEMA mobility_db.mart TO ROLE mobility_role;

GRANT SELECT ON FUTURE VIEWS IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA mobility_db.staging TO ROLE mobility_role;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA mobility_db.core TO ROLE mobility_role;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA mobility_db.mart TO ROLE mobility_role;

-- 10) Grants: stages and file formats (for COPY INTO / PUT operations)
GRANT READ, WRITE ON ALL STAGES IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT READ, WRITE ON FUTURE STAGES IN SCHEMA mobility_db.raw TO ROLE mobility_role;
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA mobility_db.raw TO ROLE mobility_role;

-- 11) Grants: access to Snowflake public shared database (for NOAA weather data)
GRANT IMPORTED PRIVILEGES ON DATABASE snowflake_public_data_free TO ROLE mobility_role;

-- 12) Assign role to your user
-- >> Replace <YOUR_SNOWFLAKE_USERNAME> with your actual Snowflake username
GRANT ROLE mobility_role TO USER <YOUR_SNOWFLAKE_USERNAME>;

-- 13) Quick verification
SHOW WAREHOUSES LIKE 'MOBILITY_WH';
SHOW DATABASES LIKE 'MOBILITY_DB';
SHOW SCHEMAS IN DATABASE mobility_db;