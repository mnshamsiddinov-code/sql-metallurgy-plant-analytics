------------------------------------------------------------
-- 02_insert_synthetic_data.sql
-- Generate synthetic dataset for Vanyukov furnace (SQL Server)
-- Uses database: VanyukovFurnaceAnalytics
------------------------------------------------------------

-- USE VanyukovFurnaceAnalytics;
-- GO

SET NOCOUNT ON;

------------------------------------------------------------
-- 0. Очистка таблиц и сброс IDENTITY
------------------------------------------------------------
DELETE FROM dbo.slag_analysis;
DELETE FROM dbo.matte_analysis;
DELETE FROM dbo.heats;
DELETE FROM dbo.furnaces;

-- Сброс IDENTITY-счётчиков
IF OBJECT_ID('dbo.slag_analysis', 'U') IS NOT NULL
    DBCC CHECKIDENT ('dbo.slag_analysis', RESEED, 0);
IF OBJECT_ID('dbo.matte_analysis', 'U') IS NOT NULL
    DBCC CHECKIDENT ('dbo.matte_analysis', RESEED, 0);
IF OBJECT_ID('dbo.heats', 'U') IS NOT NULL
    DBCC CHECKIDENT ('dbo.heats', RESEED, 0);
IF OBJECT_ID('dbo.furnaces', 'U') IS NOT NULL
    DBCC CHECKIDENT ('dbo.furnaces', RESEED, 0);
GO

------------------------------------------------------------
-- 1. Одна печь Ванюкова
------------------------------------------------------------
INSERT INTO dbo.furnaces (furnace_name, location, startup_date, status)
VALUES (N'Vanyukov Furnace #1', N'Copper Smelter A', '2022-01-01', N'active');
GO

------------------------------------------------------------
-- 2. Генерация 1000 плавок в heats
-- Одна плавка в день, начиная с 2022-01-01
------------------------------------------------------------
;WITH Numbers AS (
    SELECT 0 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 999      -- 0..999 = 1000 строк
)
INSERT INTO dbo.heats (
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
    1 AS furnace_id,

    -- старт плавки: каждый день в 08:00
    DATEADD(HOUR, 8, DATEADD(DAY, n, CAST('2022-01-01' AS DATETIME2))) AS heat_start_time,

    -- окончание плавки: тот же день в 12:00
    DATEADD(HOUR, 12, DATEADD(DAY, n, CAST('2022-01-01' AS DATETIME2))) AS heat_end_time,

    -- влажность концентрата: 8.5–12.0 %
    8.5 + (ABS(CHECKSUM(NEWID())) % 36) / 10.0 AS concentrate_moisture_pct,

    -- расход дутья: 24 000 – 33 000 нм3/ч
    24000.0 + (ABS(CHECKSUM(NEWID())) % 9001) AS blast_rate_nm3_h,

    -- температура отходящих газов: 1040–1200 °C
    1040.0 + (ABS(CHECKSUM(NEWID())) % 161) AS off_gas_temperature_c,

    -- температура стен: 1160–1260 °C
    1160.0 + (ABS(CHECKSUM(NEWID())) % 101) AS wall_temperature_c,

    -- температура свода: 1130–1230 °C
    1130.0 + (ABS(CHECKSUM(NEWID())) % 101) AS roof_temperature_c,

    -- перегрев ~10% плавок
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 100) < 10 THEN 1 ELSE 0 END AS overheating_flag,

    CASE 
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 10 THEN N'upper side-wall zone'
        ELSE NULL
    END AS overheating_zone,

    -- скорость износа: 0.20–0.50 мм/сутки
    0.20 + (ABS(CHECKSUM(NEWID())) % 31) / 100.0 AS wear_rate_mm_per_day
FROM Numbers
OPTION (MAXRECURSION 0);
GO

------------------------------------------------------------
-- 3. Анализ штейна: по одной записи на каждую плавку
------------------------------------------------------------
INSERT INTO dbo.matte_analysis (
    heat_id,
    cu_matte_pct,
    fe_matte_pct,
    s_matte_pct,
    matte_mass_t
)
SELECT
    h.heat_id,
    -- Cu в штейне: 60.5–63.5 %
    60.5 + (ABS(CHECKSUM(NEWID())) % 31) / 10.0 AS cu_matte_pct,
    -- Fe в штейне: 12.5–14.5 %
    12.5 + (ABS(CHECKSUM(NEWID())) % 21) / 10.0 AS fe_matte_pct,
    -- S в штейне: 21.0–23.0 %
    21.0 + (ABS(CHECKSUM(NEWID())) % 21) / 10.0 AS s_matte_pct,
    -- масса штейна: 140–160 т
    140.0 + (ABS(CHECKSUM(NEWID())) % 21) AS matte_mass_t
FROM dbo.heats AS h;
GO

------------------------------------------------------------
-- 4. Анализ шлака: по одной записи на каждую плавку
------------------------------------------------------------
INSERT INTO dbo.slag_analysis (
    heat_id,
    cu_slag_pct,
    fe_slag_pct,
    feo_pct,
    fe3o4_pct,
    fluxes_t,
    slag_mass_t
)
SELECT
    h.heat_id,
    -- Cu в шлаке: 0.70–1.20 %
    0.70 + (ABS(CHECKSUM(NEWID())) % 51) / 100.0 AS cu_slag_pct,
    -- Fe в шлаке: 28–32 %
    28.0 + (ABS(CHECKSUM(NEWID())) % 41) / 10.0 AS fe_slag_pct,
    -- FeO: 22–26 %
    22.0 + (ABS(CHECKSUM(NEWID())) % 41) / 10.0 AS feo_pct,
    -- Fe3O4: 8–10 %
    8.0 + (ABS(CHECKSUM(NEWID())) % 21) / 10.0 AS fe3o4_pct,
    -- флюсы: 18–24 т
    18.0 + (ABS(CHECKSUM(NEWID())) % 7) AS fluxes_t,
    -- шлак: 210–240 т
    210.0 + (ABS(CHECKSUM(NEWID())) % 31) AS slag_mass_t
FROM dbo.heats AS h;
GO

------------------------------------------------------------
-- 5. Быстрая проверка
------------------------------------------------------------
SELECT COUNT(*) AS furnace_count FROM dbo.furnaces;
SELECT COUNT(*) AS heat_count     FROM dbo.heats;
SELECT COUNT(*) AS matte_count    FROM dbo.matte_analysis;
SELECT COUNT(*) AS slag_count     FROM dbo.slag_analysis;
GO
