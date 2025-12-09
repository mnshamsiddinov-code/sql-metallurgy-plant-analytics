-- insert_synthetic_data.sql
-- Generate large synthetic dataset for Vanyukov furnace smelting
-- Dialect: SQLite-compatible SQL

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

--------------------------------------------------
-- 0. Очистка таблиц (чтобы скрипт можно было запускать повторно)
--------------------------------------------------
DELETE FROM slag_analysis;
DELETE FROM matte_analysis;
DELETE FROM heats;
DELETE FROM furnaces;

--------------------------------------------------
-- 1. Одна печь Ванюкова
--------------------------------------------------
INSERT INTO furnaces (furnace_id, furnace_name, location, startup_date, status)
VALUES
    (1, 'Vanyukov Furnace #1', 'Copper Smelter A', '2021-01-01', 'active');

--------------------------------------------------
-- 2. Генерация ~1000 плавок с датами в диапазоне 2022–2024 гг.
-- Каждая строка = одна плавка (heat)
--------------------------------------------------

WITH RECURSIVE seq(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 1000          -- около 1000 плавок
)
INSERT INTO heats (
    heat_id,
    furnace_id,
    heat_start_time,
    heat_end_time,
    concentrate_moisture_pct,
    blast_rate_nm3_h,
    off_gas_temperature_c,
    wall_temperature_c,
    roof_temperature_c,
    overheating_flag,
    overheating_zone,
    wear_rate_mm_per_day
)
SELECT
    n AS heat_id,
    1 AS furnace_id,

    -- дата плавки: случайный день в диапазоне 2022-01-01 .. 2024-12-31
    datetime(
        date('2022-01-01', printf('+%d day', abs(random()) % 1095)) || ' 08:00:00'
    ) AS heat_start_time,
    datetime(
        date('2022-01-01', printf('+%d day', abs(random()) % 1095)) || ' 12:00:00'
    ) AS heat_end_time,

    -- влажность концентрата: примерно 8.5–12.0 %
    8.5 + (abs(random()) % 35) / 10.0 AS concentrate_moisture_pct,

    -- расход дутья: 24 000 – 33 000 нм3/ч
    24000.0 + (abs(random()) % 9000) AS blast_rate_nm3_h,

    -- температура отходящих газов: 1040–1200 °C
    1040.0 + (abs(random()) % 160) AS off_gas_temperature_c,

    -- температура стен: 1160–1260 °C
    1160.0 + (abs(random()) % 100) AS wall_temperature_c,

    -- температура свода: 1130–1230 °C
    1130.0 + (abs(random()) % 100) AS roof_temperature_c,

    -- флаг перегрева: примерно 10 % плавок с перегревом
    CASE
        WHEN (abs(random()) % 100) < 10 THEN 1
        ELSE 0
    END AS overheating_flag,

    -- зона перегрева, если перегрев есть
    CASE
        WHEN (abs(random()) % 100) < 10 THEN 'upper side-wall zone'
        ELSE NULL
    END AS overheating_zone,

    -- скорость износа футеровки: 0.20–0.50 мм/сутки
    0.20 + (abs(random()) % 30) / 100.0 AS wear_rate_mm_per_day
FROM seq;

--------------------------------------------------
-- 3. Анализ штейна для каждой плавки
--------------------------------------------------

WITH RECURSIVE seq_matte(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1
    FROM seq_matte
    WHERE n < 1000
)
INSERT INTO matte_analysis (
    matte_analysis_id,
    heat_id,
    cu_matte_pct,
    fe_matte_pct,
    s_matte_pct,
    matte_mass_t
)
SELECT
    n AS matte_analysis_id,
    n AS heat_id,

    -- Cu в штейне: примерно 60.5–63.5 %
    61.5 + (abs(random()) % 30) / 10.0 AS cu_matte_pct,

    -- Fe в штейне: 12.5–14.5 %
    12.5 + (abs(random()) % 20) / 10.0 AS fe_matte_pct,

    -- S в штейне: 21.0–23.0 %
    21.0 + (abs(random()) % 20) / 10.0 AS s_matte_pct,

    -- масса штейна: 140–160 т
    140.0 + (abs(random()) % 21) AS matte_mass_t
FROM seq_matte;

--------------------------------------------------
-- 4. Анализ шлака для каждой плавки
--------------------------------------------------

WITH RECURSIVE seq_slag(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1
    FROM seq_slag
    WHERE n < 1000
)
INSERT INTO slag_analysis (
    slag_analysis_id,
    heat_id,
    cu_slag_pct,
    fe_slag_pct,
    feo_pct,
    fe3o4_pct,
    fluxes_t,
    slag_mass_t
)
SELECT
    n AS slag_analysis_id,
    n AS heat_id,

    -- Cu в шлаке: примерно 0.70–1.20 %
    0.70 + (abs(random()) % 51) / 100.0 AS cu_slag_pct,

    -- Fe в шлаке: 28–32 %
    28.0 + (abs(random()) % 41) / 10.0 AS fe_slag_pct,

    -- FeO: 22–26 %
    22.0 + (abs(random()) % 41) / 10.0 AS feo_pct,

    -- Fe3O4: 8–10 %
    8.0 + (abs(random()) % 21) / 10.0 AS fe3o4_pct,

    -- шлакообразующие: 18–24 т
    18.0 + (abs(random()) % 7) AS fluxes_t,

    -- масса шлака: 210–240 т
    210.0 + (abs(random()) % 31) AS slag_mass_t
FROM seq_slag;

COMMIT;
