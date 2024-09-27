SELECT COUNT(drug_name) 
FROM drug
--3425

SELECT COUNT( DISTINCT drug_name) 
FROM drug
--3253
	
SELECT COUNT(npi)
FROM prescription 
--656058

SELECT COUNT(DISTINCT npi)
FROM prescription
--20592

SELECT COUNT(DISTINCT specialty_description) FROM prescriber
--107
	
SELECT COUNT(specialty_description) FROM prescriber
--25050
	
--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	
SELECT npi, SUM(total_claim_count) AS total_claims
FROM  prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1;

-- 1881634483 As npi with 99707 total_claims

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT specialty_description,
	   nppes_provider_first_name,
       nppes_provider_last_org_name,
	   SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription 
USING(npi)
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name, specialty_description
ORDER BY total_claims DESC NULLS LAST
LIMIT 1;
--Family practice AS specialty_description
--BRUCE PENDLEY As nppes first and last name with 99707 total_claims

--2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT DISTINCT specialty_description,
	   SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription 
USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC 
LIMIT 1;
--Family Practice with  9752347(total_claims)

--2b. Which specialty had the most total number of claims for opioids?

SELECT DISTINCT specialty_description,
	   SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription 
USING(npi)
INNER JOIN drug 
USING(drug_name)
WHERE opioid_drug_flag ='Y'
GROUP BY specialty_description
ORDER BY total_claims DESC 
LIMIT 1;
--Nurse Practitioner with 900845 total_claims

--2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description
FROM prescriber
LEFT JOIN prescription 
USING(npi)
GROUP BY specialty_description
HAVING COUNT(total_claim_count)='0'
--15 Rows

--2d.**Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, 
--report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

SELECT specialty_description,
ROUND(SUM(CASE WHEN opioid_drug_flag='Y' THEN total_claim_count END)/SUM(total_claim_count)*100,2) AS opioids_percentage
FROM prescriber
INNER  JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
GROUP BY specialty_description
ORDER BY opioids_percentage DESC NULLS LAST;

	
--3a. Which drug (generic_name) had the highest total drug cost?
	
SELECT generic_name,SUM(total_drug_cost)::money AS highest_total_drug_cost
FROM prescription 
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY highest_total_drug_cost DESC
LIMIT 1;

--INSULIN GLARGINE,HUM.REC.ANLOG $104,264,066.35 with highest_total_drug_cost	

--3b. Which drug (generic_name) has the hightest total cost per day? 
--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
	
SELECT generic_name,ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2)::money AS highest_total_cost_per_day
FROM drug
INNER JOIN prescription 
USING(drug_name)
GROUP BY generic_name
ORDER BY highest_total_cost_per_day DESC
LIMIT 1;	
--C1 ESTERASE INHIBITOR with $3,495.22 highest_toatall_cost-per_day
	
--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for 
--drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', 
--and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this.
--See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' 
ELSE 'neither'
END AS drug_type
FROM drug;


--4b.Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
--Hint: Format the total costs as MONEY for easier comparision.

SELECT SUM(total_drug_cost)::MONEY AS total_cost,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' 
ELSE 'neither'
END AS drug_type
FROM drug
INNER JOIN prescription 
USING (drug_name)
WHERE opioid_drug_flag = 'Y' OR antibiotic_drug_flag = 'Y'
GROUP BY drug.opioid_drug_flag,drug.antibiotic_drug_flag
ORDER BY total_cost DESC;
--More spent on opioids than antibiotic


WITH drug_type AS (SELECT drug_name,
				   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
   				   WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' 
				   ELSE 'neither'
				   END AS drug_type FROM drug)

SELECT drug_type,SUM(total_drug_cost)::money AS total_cost FROM drug_type
INNER JOIN prescription USING(drug_name)
GROUP BY drug_type.drug_type
ORDER BY total_cost;
--More spent on opioids than antibiotic
	
--5a.How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
	
SELECT COUNT(DISTINCT cbsaname) AS CBSAs_Tennessee FROM cbsa
WHERE cbsaname LIKE '%TN%'
--10 CBSAS are in Tennessee
		
--5b.Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
(SELECT cbsaname,SUM(population) AS largest_combined_population
FROM cbsa
INNER JOIN fips_county
USING(fipscounty)
INNER JOIN population 
USING(fipscounty)
GROUP BY cbsaname
ORDER BY largest_combined_population DESC
LIMIT 1)
UNION
(SELECT cbsaname,SUM(population) AS min_population
FROM cbsa
INNER JOIN fips_county
USING(fipscounty)
INNER JOIN population 
USING(fipscounty)
GROUP BY cbsaname
ORDER BY min_population
LIMIT 1)
ORDER BY largest_combined_population DESC;

--Nashville-Davidson-Murfreesboro-Franklin,TN has 1830410 largest_combined_populationm
--Morristown,TN has 116352 as smallest population

--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population

SELECT county,population
FROM fips_county
INNER JOIN population 
USING(fipscounty)
WHERE fipscounty NOT IN (SELECT fipscounty FROM cbsa)
GROUP BY county
ORDER BY max_pop DESC
LIMIT 1;
--SEVIER county with 95523 total_population

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name,total_claim_count AS total_claims 
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count >3000
GROUP BY drug_name,total_claim_count
ORDER BY total_claims DESC;
--9Rows


SELECT drug_name,SUM(total_claim_count) AS total_claim_count
FROM prescription
GROUP BY drug_name,total_claim_count
HAVING SUM(total_claim_count)>=3000
ORDER BY total_claim_count	DESC;
--152 ROWS

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name,total_claim_count AS total_claims,opioid_drug_flag
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count >3000
GROUP BY drug_name,opioid_drug_flag,total_claims
ORDER BY total_claims DESC;

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name,total_claim_count AS total_claims,opioid_drug_flag,
	   CONCAT( nppes_provider_first_name,' ',nppes_provider_last_org_name )AS first_and_last_name
FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count >3000
GROUP BY drug_name,opioid_drug_flag,total_claims,first_and_last_name
ORDER BY total_claims DESC;


--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the 
--number of claims they had for each opioid.**Hint:** The results from all 3 parts will have 637 rows.
--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
--where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. 
--You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT npi,drug_name 
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
  AND nppes_provider_city = 'NASHVILLE' 
  AND opioid_drug_flag = 'Y'
GROUP BY npi,drug_name;
--637 ROWS

--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims.
--You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT npi,drug.drug_name,total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING(npi,drug_name)
WHERE specialty_description='Pain Management' AND nppes_provider_city='NASHVILLE' AND opioid_drug_flag='Y'
GROUP BY npi,drug.drug_name,total_claim_count
--637 ROWS
	
--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
	
SELECT npi,drug.drug_name,COALESCE(total_claim_count,0) AS total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING(npi,drug_name)
WHERE specialty_description='Pain Management' AND nppes_provider_city='NASHVILLE' AND opioid_drug_flag='Y'
GROUP BY npi,drug.drug_name,total_claim_count	



