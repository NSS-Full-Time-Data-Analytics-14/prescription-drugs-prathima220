--1. How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT DISTINCT npi 
FROM prescriber
EXCEPT 
SELECT DISTINCT npi
FROM prescription;


SELECT COUNT(DISTINCT npi)
FROM prescriber
WHERE npi NOT IN (SELECT DISTINCT npi FROM prescription)

SELECT COUNT(npi) FROM 
prescriber
LEFT JOIN prescription USING(npi)
WHERE prescription.npi IS NULL;


--2a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT generic_name,COUNT(*) AS drug_count
FROM prescriber
INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description ILIKE 'Family Practice'
GROUP BY generic_name
ORDER BY drug_count DESC
LIMIT 5;

--2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name,COUNT(*) AS drug_count
FROM prescriber
INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description ILIKE 'Cardiology'
GROUP BY generic_name
ORDER BY drug_count DESC
LIMIT 5;

--2c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists?
--Combine what you did for parts a and b into a single query to answer this question.

(SELECT generic_name,COUNT(*) AS drug_count
FROM prescriber
INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description ILIKE 'Family Practice'
GROUP BY generic_name
ORDER BY drug_count DESC
)
UNION
(SELECT generic_name,COUNT(*) AS drug_count
FROM prescriber
INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description ILIKE 'Cardiology'
GROUP BY generic_name
ORDER BY drug_count DESC
)
ORDER BY drug_count DESC
LIMIT 5;


--3.Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--a.First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. 
--Report the npi, the total number of claims, and include a column showing the city.

SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5;

--3b.Now, report the same for Memphis.

SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5;



SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5;

--3c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

(SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5)
UNION
(SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5)
UNION
(SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5)
UNION
(SELECT npi,CONCAT(nppes_provider_first_name,' ',nppes_provider_last_org_name) AS prescriber 
	,SUM(total_claim_count) AS total_number_of_claims
	,nppes_provider_city AS city
FROM prescriber 
INNER JOIN prescription USING(npi)
WHERE nppes_provider_city = 'KNOXVILLE'
GROUP BY npi,prescriber,city
ORDER BY total_number_of_claims DESC
LIMIT 5)
ORDER BY total_number_of_claims DESC;

--4.Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

SELECT county,overdose_deaths 
FROM overdose_deaths 
INNER JOIN fips_county
ON overdose_deaths.fipscounty=fips_county.fipscounty::numeric
WHERE overdose_deaths >(SELECT AVG(overdose_deaths) FROM overdose_deaths)
GROUP BY county,overdose_deaths
ORDER BY overdose_deaths DESC;

--5a. Write a query that finds the total population of Tennessee.

SELECT SUM(population) AS total_population_of_Tennessee
FROM population
INNER JOIN fips_county USING(fipscounty)
WHERE state ILIKE 'TN';

--5b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, 
--and the percentage of the total population of Tennessee that is contained in that county.

SELECT county,population,ROUND((population/(SELECT SUM(population) FROM population)),2) AS poulation_percentage_in_tennessee
FROM population
INNER JOIN fips_county USING(fipscounty)
GROUP BY county,population
ORDER BY poulation_percentage_in_tennessee DESC;











