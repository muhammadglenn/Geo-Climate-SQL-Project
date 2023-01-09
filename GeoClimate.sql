-- Temp Table Total Gas Emission

DROP TABLE IF EXISTS #gas_emission
CREATE TABLE #total_gas_emission(
country varchar(50),
continent varchar(50),
total_gas float)

INSERT INTO #total_gas_emission
SELECT g.country, p.Continent continent, total_co2_ton + total_methane_ton total_gas
FROM PortofolioProject..greenhouse_emission g
JOIN PortofolioProject..world_population p
ON g.country = p.Country

SELECT *
FROM #total_gas_emission

-- Case 1 : Average of total gas each continent

SELECT continent, AVG(total_gas) average_gas, SUM(total_gas) total_gas
FROM #total_gas_emission
GROUP BY continent
Order BY average_gas DESC

-- Temp Table total gas per density category 

DROP TABLE IF EXISTS #density_gas
CREATE TABLE #density_gas(
country varchar(50),
total_gas float,
density_per_km float,
density_cat varchar(50))

INSERT INTO #density_gas
SELECT p.Country, total_co2_ton + total_methane_ton total_gas, p.[Density_per km²],
	   CASE
	   WHEN p.[Density_per km²] < 38.41 THEN 'Low'
	   WHEN p.[Density_per km²] < 95.34 THEN 'Average'
	   WHEN p.[Density_per km²] < 238.93 THEN 'High'
	   ELSE 'Very High'
	   END AS density_cat
FROM PortofolioProject..world_population p
JOIN PortofolioProject..greenhouse_emission g
ON p.Country=g.country
ORDER BY [Density_per km²] DESC

SELECT *
FROM #density_gas

-- Case 2: Average total gas each density category

SELECT country, density_cat,
	   AVG(total_gas) OVER (PARTITION BY density_cat) AS Avg_gas
FROM #density_gas

-- Case 3: Find All Country with total co2 greater than average of all country

SELECT country, total_co2_ton
FROM PortofolioProject..greenhouse_emission
WHERE total_co2_ton > (SELECT avg(total_co2_ton)
					   FROM PortofolioProject..greenhouse_emission)
ORDER BY total_co2_ton DESC

-- Case 4: Countries and the average area off all country in their continent

SELECT Country, Continent, [Area_km²], (SELECT (ROUND(AVG([Area_km²]),2))
										FROM PortofolioProject..world_population
										WHERE Continent = p.Continent) avg_area_continent
FROM PortofolioProject..world_population p
ORDER BY Continent, [Area_km²] DESC

-- Case 5: Find All country with Area greater than average area in their continent

SELECT Country, Continent, [Area_km²]
FROM PortofolioProject..world_population p
WHERE [Area_km²] > (SELECT (ROUND(AVG([Area_km²]),2))
				   FROM PortofolioProject..world_population
				   WHERE Continent = p.Continent)
ORDER BY Continent, [Area_km²] DESC

-- Case 6: Find All Country with highest growth rate each continent

SELECT *
FROM PortofolioProject..world_population
WHERE Growth_Rate IN (SELECT MAX(Growth_Rate)
									FROM PortofolioProject..world_population
									GROUP BY Continent)

-- Case 7: Find All country with density per km greater than all african countries

SELECT *
FROM PortofolioProject..world_population
WHERE [Density_per km²] > ALL(SELECT [Density_per km²]
							FROM PortofolioProject..world_population
							WHERE Continent = 'Africa')
ORDER BY [Density_per km²] DESC

-- Case 8: Find All countries with growth rate greater than african countries average

SELECT *
FROM PortofolioProject..world_population
WHERE Growth_Rate > ANY(SELECT AVG(Growth_Rate)
						FROM PortofolioProject..world_population
						WHERE Continent = 'Africa'
						GROUP BY Continent)
ORDER BY Continent, Growth_Rate DESC