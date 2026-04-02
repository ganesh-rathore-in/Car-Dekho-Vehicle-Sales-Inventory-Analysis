 
USE car_dekho;
 
-- Q1. View all records in the dataset
SELECT * FROM car_dekho;

-- Q2. Count total number of cars in the database
SELECT COUNT(*) AS total_cars FROM car_dekho;

 
-- Q3. How many cars are available in 2023?
SELECT COUNT(*) AS cars_available_2023
FROM car_dekho
WHERE year = 2023;

-- Q4. How many cars are available in 2020, 2021, and 2022? (Individual counts)
SELECT COUNT(*) AS cars_available_2020 FROM car_dekho WHERE year = 2020;
SELECT COUNT(*) AS cars_available_2021 FROM car_dekho WHERE year = 2021;
SELECT COUNT(*) AS cars_available_2022 FROM car_dekho WHERE year = 2022;

-- Q5. How many cars are available in 2020, 2021, and 2022? (Grouped view)
SELECT 
    year, 
    COUNT(*) AS cars_available
FROM car_dekho
WHERE year IN (2020, 2021, 2022)
GROUP BY year
ORDER BY year;

-- Q6. Print total cars count for each year (Full yearly trend)
SELECT 
    year, 
    COUNT(*) AS total_cars
FROM car_dekho
GROUP BY year
ORDER BY year;

 

-- Q7. How many Diesel cars were sold in 2020?
SELECT COUNT(*) AS diesel_cars_2020
FROM car_dekho
WHERE year = 2020 AND fuel = 'Diesel';

-- Q8. How many Petrol cars were sold in 2020?
SELECT COUNT(*) AS petrol_cars_2020
FROM car_dekho
WHERE year = 2020 AND fuel = 'Petrol';

-- Q9. Year-wise breakdown of Diesel cars sold
SELECT 
    year, 
    COUNT(*) AS diesel_cars
FROM car_dekho
WHERE fuel = 'Diesel'
GROUP BY year
ORDER BY year;

-- Q10. Year-wise breakdown of Petrol cars sold
SELECT 
    year, 
    COUNT(*) AS petrol_cars
FROM car_dekho
WHERE fuel = 'Petrol'
GROUP BY year
ORDER BY year;

-- Q11. Year-wise breakdown of CNG cars sold
SELECT 
    year, 
    COUNT(*) AS cng_cars
FROM car_dekho
WHERE fuel = 'CNG'
GROUP BY year
ORDER BY year;


 
-- Q12. Which years had more than 100 car sales?
SELECT 
    year, 
    COUNT(*) AS total_cars
FROM car_dekho
GROUP BY year
HAVING COUNT(*) > 100
ORDER BY total_cars DESC;

-- Q13. Which years had less than 50 car sales? (For identifying weak periods)
SELECT 
    year, 
    COUNT(*) AS total_cars
FROM car_dekho
GROUP BY year
HAVING COUNT(*) < 50
ORDER BY total_cars ASC;

 
-- Q14. Total car count between 2015 and 2023
SELECT COUNT(*) AS cars_2015_to_2023
FROM car_dekho
WHERE year BETWEEN 2015 AND 2023;

-- Q15. Complete list of all car details between 2015 and 2023
SELECT *
FROM car_dekho
WHERE year BETWEEN 2015 AND 2023
ORDER BY year, name;

 
-- END OF ANALYSIS
 