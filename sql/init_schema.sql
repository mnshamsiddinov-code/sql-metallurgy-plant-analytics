------------------------------------------------------------
-- Vanyukov Furnace Smelting Database Schema (SQL Server)
-- Author: <your_name>
-- This script creates all tables required for the project
-- Compatible with Microsoft SQL Server (T-SQL)
------------------------------------------------------------

-- Create database if needed (optional)
-- CREATE DATABASE VanyukovFurnaceAnalytics;
-- GO

-- Use database
-- USE VanyukovFurnaceAnalytics;
-- GO

------------------------------------------------------------
-- 1. Drop tables if they already exist (for re-creation)
------------------------------------------------------------
IF OBJECT_ID('dbo.slag_analysis', 'U') IS NOT NULL DROP TABLE dbo.slag_analysis;
IF OBJECT_ID('dbo.matte_analysis', 'U') IS NOT NULL DROP TABLE dbo.matte_analysis;
IF OBJECT_ID('dbo.heats', 'U') IS NOT NULL DROP TABLE dbo.heats;
IF OBJECT_ID('dbo.furnaces', 'U') IS NOT NULL DROP TABLE dbo.furnaces;
GO

------------------------------------------------------------
-- 2. furnaces – reference table for furnaces
------------------------------------------------------------
CREATE TABLE dbo.furnaces (
    furnace_id      INT IDENTITY(1,1) PRIMARY KEY,
    furnace_name    NVARCHAR(100) NOT NULL,
    location        NVARCHAR(100),
    startup_date    DATE,
    status          NVARCHAR(50)   -- e.g. active / maintenance / shutdown
);
GO

------------------------------------------------------------
-- 3. heats – smelting operations (one row = one heat)
------------------------------------------------------------
CREATE TABLE dbo.heats (
    heat_id                 INT IDENTITY(1,1) PRIMARY KEY,
    furnace_id              INT NOT NULL,
    heat_start_time         DATETIME2 NOT NULL,
    heat_end_time           DATETIME2 NOT NULL,

    -- Feed and operating conditions
    concentrate_moisture_pct    FLOAT,
    blast_rate_nm3_h            FLOAT,

    -- Gas and thermal conditions
    off_gas_temperature_c       FLOAT,
    wall_temperature_c          FLOAT,
    roof_temperature_c          FLOAT,

    -- Overheating and refractory wear
    overheating_flag            BIT DEFAULT 0,
    overheating_zone            NVARCHAR(100),
    wear_rate_mm_per_day        FLOAT,

    CONSTRAINT fk_heats_furnace
        FOREIGN KEY (furnace_id) REFERENCES dbo.furnaces(furnace_id)
);
GO

------------------------------------------------------------
-- 4. matte_analysis – matte composition per heat
------------------------------------------------------------
CREATE TABLE dbo.matte_analysis (
    matte_analysis_id   INT IDENTITY(1,1) PRIMARY KEY,
    heat_id             INT NOT NULL,

    cu_matte_pct        FLOAT,   -- % Cu in matte
    fe_matte_pct        FLOAT,   -- % Fe in matte
    s_matte_pct         FLOAT,   -- % S in matte
    matte_mass_t        FLOAT,   -- mass of matte, tons

    CONSTRAINT fk_matte_heat
        FOREIGN KEY (heat_id) REFERENCES dbo.heats(heat_id)
);
GO

------------------------------------------------------------
-- 5. slag_analysis – slag composition per heat
------------------------------------------------------------
CREATE TABLE dbo.slag_analysis (
    slag_analysis_id    INT IDENTITY(1,1) PRIMARY KEY,
    heat_id             INT NOT NULL,

    cu_slag_pct         FLOAT,
    fe_slag_pct         FLOAT,
    feo_pct             FLOAT,
    fe3o4_pct           FLOAT,
    fluxes_t            FLOAT,
    slag_mass_t         FLOAT,

    CONSTRAINT fk_slag_heat
        FOREIGN KEY (heat_id) REFERENCES dbo.heats(heat_id)
);
GO

------------------------------------------------------------
-- SCHEMA CREATED SUCCESSFULLY
------------------------------------------------------------
