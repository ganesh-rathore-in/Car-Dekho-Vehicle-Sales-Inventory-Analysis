 
-- 11. Find the top 5 years with highest number of cars sold
SELECT 
    year, 
    COUNT(*) AS total_cars,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM car_dekho) * 100, 2) AS percentage
FROM car_dekho
GROUP BY year
ORDER BY total_cars DESC
LIMIT 5;

-- 12. Fuel type distribution with percentage
SELECT 
    fuel, 
    COUNT(*) AS total_cars,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM car_dekho) * 100, 2) AS percentage
FROM car_dekho
GROUP BY fuel
ORDER BY total_cars DESC;

-- 13. Year-over-year growth rate calculation
WITH yearly_counts AS (
    SELECT 
        year, 
        COUNT(*) AS car_count
    FROM car_dekho
    GROUP BY year
)
SELECT 
    year,
    car_count,
    LAG(car_count, 1) OVER (ORDER BY year) AS previous_year_count,
    ROUND((car_count - LAG(car_count, 1) OVER (ORDER BY year)) / 
          NULLIF(LAG(car_count, 1) OVER (ORDER BY year), 0) * 100, 2) AS growth_percentage
FROM yearly_counts
ORDER BY year;

-- 14. Find the most popular fuel type for each year
-- Alternative: Using a Subquery
SELECT 
    year,
    fuel,
    fuel_count
FROM (
    SELECT 
        year,
        fuel,
        COUNT(*) AS fuel_count,
        RANK() OVER (PARTITION BY year ORDER BY COUNT(*) DESC) as fuel_rank
    FROM car_dekho
    GROUP BY year, fuel
) AS subquery
WHERE fuel_rank = 1
ORDER BY year;

-- 15. Identify years with consistent growth (no decline for 3+ years)
WITH yearly_trend AS (
    SELECT 
        year,
        COUNT(*) AS car_count,
        LAG(COUNT(*), 1) OVER (ORDER BY year) AS prev_count,
        CASE 
            WHEN COUNT(*) > LAG(COUNT(*), 1) OVER (ORDER BY year) THEN 'Growth'
            WHEN COUNT(*) < LAG(COUNT(*), 1) OVER (ORDER BY year) THEN 'Decline'
            ELSE 'Flat'
        END AS trend
    FROM car_dekho
    GROUP BY year
)
SELECT * FROM yearly_trend
ORDER BY year;

-- 16. Cumulative sales over years (running total)
SELECT 
    year,
    COUNT(*) AS yearly_sales,
    SUM(COUNT(*)) OVER (ORDER BY year) AS cumulative_sales
FROM car_dekho
GROUP BY year
ORDER BY year;

-- 17. Find fuel type that showed maximum growth in recent years (2020-2023)
WITH fuel_yearly AS (
    SELECT 
        fuel,
        year,
        COUNT(*) AS fuel_count
    FROM car_dekho
    WHERE year BETWEEN 2020 AND 2023
    GROUP BY fuel, year
),
fuel_growth AS (
    SELECT 
        fuel,
        MAX(CASE WHEN year = 2020 THEN fuel_count END) AS sales_2020,
        MAX(CASE WHEN year = 2023 THEN fuel_count END) AS sales_2023,
        (MAX(CASE WHEN year = 2023 THEN fuel_count END) - 
         MAX(CASE WHEN year = 2020 THEN fuel_count END)) AS growth
    FROM fuel_yearly
    GROUP BY fuel
)
SELECT 
    fuel,
    sales_2020,
    sales_2023,
    growth,
    ROUND(growth / NULLIF(sales_2020, 0) * 100, 2) AS growth_percentage
FROM fuel_growth
WHERE sales_2020 IS NOT NULL AND sales_2023 IS NOT NULL
ORDER BY growth DESC;

-- 18. Find years where car sales were above the overall average
SELECT 
    year,
    COUNT(*) AS car_count,
    ROUND(AVG(COUNT(*)) OVER (), 0) AS overall_avg
FROM car_dekho
GROUP BY year
HAVING car_count > (SELECT AVG(car_count) FROM (SELECT COUNT(*) AS car_count FROM car_dekho GROUP BY year) AS avg_table)
ORDER BY car_count DESC;

-- 19. Create a summary view for quick reporting
CREATE VIEW car_sales_summary AS
SELECT 
    year,
    COUNT(*) AS total_cars,
    SUM(CASE WHEN fuel = 'Petrol' THEN 1 ELSE 0 END) AS petrol_cars,
    SUM(CASE WHEN fuel = 'Diesel' THEN 1 ELSE 0 END) AS diesel_cars,
    SUM(CASE WHEN fuel = 'CNG' THEN 1 ELSE 0 END) AS cng_cars,
    ROUND(SUM(CASE WHEN fuel = 'Petrol' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS petrol_percentage,
    ROUND(SUM(CASE WHEN fuel = 'Diesel' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS diesel_percentage
FROM car_dekho
GROUP BY year
ORDER BY year;

-- Query the view
SELECT * FROM car_sales_summary;

-- 20. Find the most consistent fuel type (least variation across years)
WITH fuel_variation AS (
    SELECT 
        fuel,
        STDDEV(count_per_year) AS variation
    FROM (
        SELECT 
            fuel,
            year,
            COUNT(*) AS count_per_year
        FROM car_dekho
        GROUP BY fuel, year
    ) AS fuel_yearly
    GROUP BY fuel
)
SELECT 
    fuel,
    ROUND(variation, 2) AS std_deviation,
    CASE 
        WHEN variation = (SELECT MIN(variation) FROM fuel_variation) THEN 'Most Consistent'
        WHEN variation = (SELECT MAX(variation) FROM fuel_variation) THEN 'Most Volatile'
        ELSE 'Moderate'
    END AS consistency_rating
FROM fuel_variation
ORDER BY variation;

-- 21. Market share analysis by fuel type over years (Pivot style)
SELECT 
    year,
    COUNT(*) AS total_cars,
    CONCAT(ROUND(SUM(CASE WHEN fuel = 'Petrol' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS petrol_share,
    CONCAT(ROUND(SUM(CASE WHEN fuel = 'Diesel' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS diesel_share,
    CONCAT(ROUND(SUM(CASE WHEN fuel = 'CNG' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS cng_share
FROM car_dekho
GROUP BY year
ORDER BY year;

-- 22. Identify years with significant fuel preference shift
WITH fuel_share AS (
    SELECT 
        year,
        SUM(CASE WHEN fuel = 'Petrol' THEN 1 ELSE 0 END) / COUNT(*) AS petrol_ratio,
        SUM(CASE WHEN fuel = 'Diesel' THEN 1 ELSE 0 END) / COUNT(*) AS diesel_ratio
    FROM car_dekho
    GROUP BY year
)
SELECT 
    year,
    ROUND(petrol_ratio * 100, 2) AS petrol_percentage,
    ROUND(diesel_ratio * 100, 2) AS diesel_percentage,
    ROUND((petrol_ratio - LAG(petrol_ratio, 1) OVER (ORDER BY year)) * 100, 2) AS petrol_shift,
    ROUND((diesel_ratio - LAG(diesel_ratio, 1) OVER (ORDER BY year)) * 100, 2) AS diesel_shift
FROM fuel_share
ORDER BY year;

-- 23. Create a stored procedure for year-wise report
DELIMITER //
CREATE PROCEDURE GetYearlyReport(IN start_year INT, IN end_year INT)
BEGIN
    SELECT 
        year,
        COUNT(*) AS total_cars,
        COUNT(DISTINCT fuel) AS fuel_types_count,
        GROUP_CONCAT(DISTINCT fuel ORDER BY fuel) AS fuel_types
    FROM car_dekho
    WHERE year BETWEEN start_year AND end_year
    GROUP BY year
    ORDER BY year;
END //
DELIMITER ;

-- Call the procedure
CALL GetYearlyReport(2015, 2023);

-- 24. Find years where a new fuel type was introduced
SELECT 
    year,
    fuel
FROM (
    SELECT 
        year,
        fuel,
        ROW_NUMBER() OVER (PARTITION BY fuel ORDER BY year) AS first_appearance
    FROM (
        SELECT DISTINCT year, fuel FROM car_dekho
    ) AS fuel_years
) AS ranked
WHERE first_appearance = 1
ORDER BY year;

-- 25. Seasonality analysis (if month data available, otherwise by year)
-- This demonstrates how to add month column if available
SELECT 
    year,
    COUNT(*) AS total_cars,
    ROUND(AVG(COUNT(*)) OVER (ORDER BY year ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING), 2) AS moving_avg_3_year
FROM car_dekho
GROUP BY year
ORDER BY year;