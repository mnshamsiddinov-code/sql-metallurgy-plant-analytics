-- init_schema.sql
-- Vanyukov furnace smelting database schema
-- Dialect: SQLite-compatible SQL

PRAGMA foreign_keys = ON;

--------------------------------------------------
-- 1. furnaces – справочник печей
--------------------------------------------------
CREATE TABLE IF NOT EXISTS furnaces (
    furnace_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    furnace_name    TEXT NOT NULL,
    location        TEXT,
    startup_date    DATE,
    status          TEXT    -- e.g. 'active', 'maintenance', 'shutdown'
);

--------------------------------------------------
-- 2. heats – отдельные плавки в печи Ванюкова
--------------------------------------------------
CREATE TABLE IF NOT EXISTS heats (
    heat_id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    furnace_id              INTEGER NOT NULL,
    heat_start_time         DATETIME NOT NULL,
    heat_end_time           DATETIME NOT NULL,

    -- Свойства шихты и режима
    concentrate_moisture_pct    REAL,   -- влажность концентрата, %
    blast_rate_nm3_h            REAL,   -- расход дутья, нм3/ч

    -- Параметры газов и теплового режима
    off_gas_temperature_c       REAL,   -- температура отходящих газов, °C

    -- Состояние печи / перегрев / износ
    wall_temperature_c          REAL,   -- температура стен, °C
    roof_temperature_c          REAL,   -- температура свода, °C
    overheating_flag            INTEGER DEFAULT 0,   -- 0 = нет, 1 = да
    overheating_zone            TEXT,   -- описание зоны перегрева (если есть)
    wear_rate_mm_per_day        REAL,   -- скорость износа футеровки

    -- Внешний ключ
    FOREIGN KEY (furnace_id) REFERENCES furnaces(furnace_id)
);

--------------------------------------------------
-- 3. matte_analysis – состав штейна
--------------------------------------------------
CREATE TABLE IF NOT EXISTS matte_analysis (
    matte_analysis_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    heat_id             INTEGER NOT NULL,

    cu_matte_pct        REAL,   -- Cu в штейне, %
    fe_matte_pct        REAL,   -- Fe в штейне, %
    s_matte_pct         REAL,   -- S в штейне, %
    matte_mass_t        REAL,   -- масса штейна, т

    FOREIGN KEY (heat_id) REFERENCES heats(heat_id)
);

--------------------------------------------------
-- 4. slag_analysis – состав шлака
--------------------------------------------------
CREATE TABLE IF NOT EXISTS slag_analysis (
    slag_analysis_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    heat_id             INTEGER NOT NULL,

    cu_slag_pct         REAL,   -- Cu в шлаке, %
    fe_slag_pct         REAL,   -- Fe в шлаке, %
    feo_pct             REAL,   -- FeO, %
    fe3o4_pct           REAL,   -- Fe3O4, %
    fluxes_t            REAL,   -- шлакообразующие, т
    slag_mass_t         REAL,   -- масса шлака, т

    FOREIGN KEY (heat_id) REFERENCES heats(heat_id)
);
