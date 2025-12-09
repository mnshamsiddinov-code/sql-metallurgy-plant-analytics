-- Query 01: Top 20 heats with highest copper losses in slag
-- Description:
--   Identifies the heats with the highest Cu in slag, including
--   key process parameters (blast rate, gas temperature)
-- Purpose:
--   Used to detect problematic operating regimes with increased
--   copper losses and analyze their technological causes.
------------------------------------------------------------

SELECT TOP 20 
    h.heat_id,
    h.heat_start_time,
    sa.cu_slag_pct,
    sa.fe_slag_pct,
    sa.feo_pct,
    sa.fe3o4_pct,
    h.blast_rate_nm3_h,
    h.off_gas_temperature_c
FROM slag_analysis sa
LEFT JOIN heats h
    ON sa.heat_id = h.heat_id
ORDER BY sa.cu_slag_pct DESC;

------------------------------------------------------------
-- Query 02: Effect of blast rate on off-gas temperature
-- Description:
--   Groups heats into blast rate ranges and calculates the
--   average off-gas temperature and number of heats per range.
-- Purpose:
--   Used to understand how different blast rate operating
--   regimes affect furnace thermal behavior and gas temperature.
------------------------------------------------------------

SELECT
    CASE 
        WHEN blast_rate_nm3_h < 26000 THEN '<26000'
        WHEN blast_rate_nm3_h BETWEEN 26000 AND 27999 THEN '26000–27999'
        WHEN blast_rate_nm3_h BETWEEN 28000 AND 29999 THEN '28000–29999'
        ELSE '>=30000'
    END AS blast_rate_range,
    ROUND(AVG(off_gas_temperature_c)) AS avg_off_gas_temperature,
    COUNT(*) AS heat_count
FROM heats
GROUP BY
    CASE 
        WHEN blast_rate_nm3_h < 26000 THEN '<26000'
        WHEN blast_rate_nm3_h BETWEEN 26000 AND 27999 THEN '26000–27999'
        WHEN blast_rate_nm3_h BETWEEN 28000 AND 29999 THEN '28000–29999'
        ELSE '>=30000'
    END
ORDER BY
    MIN(blast_rate_nm3_h);

------------------------------------------------------------
-- Query 03: Effect of concentrate moisture on off-gas temperature
-- Description:
--   Groups heats by concentrate moisture ranges and calculates
--   the average off-gas temperature and number of heats per range.
-- Purpose:
--   Used to evaluate how feed moisture influences furnace thermal
--   behavior and off-gas temperature.
------------------------------------------------------------

SELECT 
    CASE
        WHEN concentrate_moisture_pct < 9.0 THEN '<9.0%'
        WHEN concentrate_moisture_pct BETWEEN 9.0 AND 9.99 THEN '9.0–10.0%'
        WHEN concentrate_moisture_pct BETWEEN 10.0 AND 10.99 THEN '10.0–11.0%'
        ELSE '>11.0%'
    END AS moisture_range,
    ROUND(AVG(off_gas_temperature_c), 2) AS avg_off_gas_temperature,
    COUNT(*) AS heat_count
FROM heats
GROUP BY
    CASE
        WHEN concentrate_moisture_pct < 9.0 THEN '<9.0%'
        WHEN concentrate_moisture_pct BETWEEN 9.0 AND 9.99 THEN '9.0–10.0%'
        WHEN concentrate_moisture_pct BETWEEN 10.0 AND 10.99 THEN '10.0–11.0%'
        ELSE '>11.0%'
    END
ORDER BY 
    MIN(concentrate_moisture_pct);

------------------------------------------------------------
-- Query 04: Dangerous heats with high Cu losses and overheating
-- Description:
--   Identifies heats that simultaneously show high copper
--   losses in slag and furnace overheating conditions.
-- Purpose:
--   Used to detect unstable and potentially hazardous
--   operating regimes where both slag losses and thermal
--   stress on the furnace lining increase.
------------------------------------------------------------

SELECT 
    h.heat_id,
    h.heat_start_time,
    sa.cu_slag_pct,
    h.wall_temperature_c,
    h.roof_temperature_c,
    h.blast_rate_nm3_h
FROM heats h
INNER JOIN slag_analysis sa
    ON h.heat_id = sa.heat_id
WHERE 
    sa.cu_slag_pct > 1.0      -- high Cu losses (>1%)
    AND h.overheating_flag = 1  -- overheating detected
ORDER BY 
    sa.cu_slag_pct DESC;

------------------------------------------------------------
-- Query 05: Influence of FeO content on copper losses in slag
-- Description:
--   Groups heats by FeO content in slag and calculates the
--   average copper concentration in slag for each FeO range.
-- Purpose:
--   Used to evaluate how FeO levels affect copper losses and to
--   identify FeO regimes associated with higher Cu losses.
------------------------------------------------------------

SELECT
    CASE
        WHEN feo_pct < 23 THEN '<23.00%'
        WHEN feo_pct BETWEEN 23.00 AND 23.99 THEN '23.00%–24.00%'
        WHEN feo_pct BETWEEN 24.00 AND 24.99 THEN '24.00%–25.00%'
        ELSE '>25.00%'
    END AS feo_range,
    
    ROUND(AVG(cu_slag_pct), 2) AS avg_cu_slag_pct,
    COUNT(*) AS heat_count
FROM slag_analysis
GROUP BY
    CASE
        WHEN feo_pct < 23 THEN '<23.00%'
        WHEN feo_pct BETWEEN 23.00 AND 23.99 THEN '23.00%–24.00%'
        WHEN feo_pct BETWEEN 24.00 AND 24.99 THEN '24.00%–25.00%'
        ELSE '>25.00%'
    END
ORDER BY 
    MIN(feo_pct);

------------------------------------------------------------
-- Query 06: Top heats with largest jump in off-gas temperature
-- Description:
--   Computes the change in off-gas temperature between
--   consecutive heats and identifies heats with the largest
--   positive or negative jumps.
-- Purpose:
--   Used to detect unstable operating periods or potential
--   process upsets where gas temperature changes abruptly.
------------------------------------------------------------

WITH temp_changes AS (
    SELECT 
        heat_id,
        heat_start_time,
        off_gas_temperature_c,
        LAG(off_gas_temperature_c) OVER (ORDER BY heat_start_time) AS prev_off_gas_temp,
        off_gas_temperature_c 
            - LAG(off_gas_temperature_c) OVER (ORDER BY heat_start_time) AS delta_temp
    FROM heats
)
SELECT TOP 20
    heat_id,
    heat_start_time,
    off_gas_temperature_c,
    prev_off_gas_temp,
    delta_temp,
    ABS(delta_temp) AS abs_delta_temp
FROM temp_changes
WHERE prev_off_gas_temp IS NOT NULL
ORDER BY 
    ABS(delta_temp) DESC;
------------------------------------------------------------
-- Query 07: Correlation between FeO and copper losses in slag
-- Description:
--   Calculates Pearson correlation coefficient between FeO (%)
--   and Cu in slag (%). This helps determine whether oxidation
--   state of slag (FeO level) influences copper losses.
--
-- Purpose:
--   Used for statistical process analysis. If correlation is
--   close to zero, FeO does not significantly affect copper
--   losses. If correlation is strongly positive or negative,
--   FeO becomes a key driver of slag copper content.
------------------------------------------------------------

;WITH stats AS (
    SELECT
        AVG(feo_pct)                             AS avg_feo,
        AVG(cu_slag_pct)                         AS avg_cu,
        AVG(feo_pct * cu_slag_pct)               AS avg_feo_cu,
        AVG(feo_pct * feo_pct)                   AS avg_feo_sq,
        AVG(cu_slag_pct * cu_slag_pct)           AS avg_cu_sq
    FROM slag_analysis
    WHERE feo_pct IS NOT NULL
      AND cu_slag_pct IS NOT NULL
)

SELECT
    avg_feo,
    avg_cu,
    (avg_feo_cu - avg_feo * avg_cu) /
    NULLIF(
        SQRT(avg_feo_sq - avg_feo * avg_feo) *
        SQRT(avg_cu_sq - avg_cu * avg_cu),
        0
    ) AS pearson_correlation;

