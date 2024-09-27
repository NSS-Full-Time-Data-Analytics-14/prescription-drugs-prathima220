--1.Write a query which returns the total number of claims for these two groups. Your output should look like this: 
SELECT specialty_description,SUM(total_claim_count) AS number_of_claims 
FROM prescriber
INNER JOIN prescription USING(npi)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management')
GROUP BY specialty_description
;

--2.Now, let's say that we want our output to also include the total number of claims between these two groups. 
--Combine two queries with the UNION keyword to accomplish this. Your output should look like this:
SELECT NULL AS specialty_description,
	SUM(total_claim_count) AS number_of_claims 
FROM prescriber INNER JOIN prescription USING(npi)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management')
UNION 
SELECT specialty_description,
	SUM(total_claim_count) AS number_of_claims 
FROM prescriber
INNER JOIN prescription USING(npi)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management')
GROUP BY specialty_description
;



--3. Now, instead of using UNION, make use of GROUPING SETS (https://www.postgresql.org/docs/10/queries-table-expressions.html#QUERIES-GROUPING-SETS) to achieve the same output.

SELECT specialty_description,
	SUM(total_claim_count) AS number_of_claims 
FROM prescriber INNER JOIN prescription USING(npi)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management')
GROUP BY GROUPING SETS(specialty_description,())
;	
--4. In addition to comparing the total number of prescriptions by specialty, let's also bring in information about the number of opioid vs. non-opioid claims by these two specialties. Modify your query (still making use of 
--GROUPING SETS so that your output also shows the total number of opioid claims vs. non-opioid claims by these two specialites:

SELECT specialty_description,
	opioid_drug_flag,
	SUM(total_claim_count) AS number_of_claims	
FROM prescriber INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management') 
GROUP BY GROUPING SETS(specialty_description,(),(opioid_drug_flag))
;

-----------------------------------

SELECT specialty_description,
	opioid_drug_flag,
	SUM(total_claim_count) AS number_of_claims	
FROM prescriber INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management') 
GROUP BY GROUPING SETS(specialty_description),(specialty_description,opioid_drug_flag)
;
-------------------

--5. Modify your query by replacing the GROUPING SETS with ROLLUP(opioid_drug_flag, specialty_description). 
--How is the result different from the output from the previous query?


SELECT specialty_description,
	opioid_drug_flag,
	SUM(total_claim_count) AS number_of_claims	
FROM prescriber INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management') 
GROUP BY ROLLUP(specialty_description,opioid_drug_flag)
;

--6. Switch the order of the variables inside the ROLLUP. That is, use ROLLUP(specialty_description, opioid_drug_flag).
--How does this change the result?
SELECT specialty_description,
	opioid_drug_flag,
	SUM(total_claim_count) AS number_of_claims	
FROM prescriber INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management') 
GROUP BY ROLLUP(opioid_drug_flag,specialty_description)
;
--7. Finally, change your query to use the CUBE function instead of ROLLUP. How does this impact the output?
SELECT specialty_description,
	opioid_drug_flag,
	SUM(total_claim_count) AS number_of_claims	
FROM prescriber INNER JOIN prescription USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description IN ('Interventional Pain Management','Pain Management') 
GROUP BY CUBE(opioid_drug_flag,specialty_description)
;
--8.. In this question, your goal is to create a pivot table showing for each of the 
--4 largest cities in Tennessee (Nashville, Memphis, Knoxville, and Chattanooga), the total claim count for each of 
--six common types of opioids: Hydrocodone, Oxycodone, Oxymorphone, Morphine, Codeine, and Fentanyl. 
--For the purpose of this question, we will put a drug into one of the six listed categories if it has the category name as part of its generic name. 
--For example, we could count both of "ACETAMINOPHEN WITH CODEINE" and "CODEINE SULFATE" as being "CODEINE" for the purposes of this question.


SELECT nppes_provider_city,--SUM(total_claim_count) AS total_claim_count,
   SUM(CASE WHEN generic_name ILIKE '%Hydrocodone%' THEN total_claim_count ELSE 0 END) AS Hydrocodone,
    SUM(CASE WHEN generic_name ILIKE '%Oxycodone%' THEN total_claim_count ELSE 0 END) AS Oxycodone,
   SUM(CASE WHEN generic_name ILIKE '%Oxymorphone%' THEN total_claim_count ELSE 0 END) AS Oxymorphone,
   SUM(CASE WHEN generic_name ILIKE '%Morphine%' THEN total_claim_count ELSE 0 END) AS Morphine,
   SUM(CASE WHEN generic_name ILIKE '%Codeine%' THEN total_claim_count ELSE 0 END) AS Codeine,
    SUM(CASE WHEN generic_name ILIKE '%Fentanyl%' THEN total_claim_count ELSE 0 END) AS Fentanyl
FROM 
    drug INNER JOIN prescription USING(drug_name)
	INNER JOIN prescriber USING(npi)
WHERE 
    nppes_provider_city IN ('NASHVILLE', 'MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
GROUP BY 
    nppes_provider_city;

-----------------------------------------------------------------
SELECT *
FROM crosstab(
    $$
    SELECT 
        nppes_provider_city AS city,
        CASE 
            WHEN generic_name ILIKE '%codeine%' THEN 'codeine'
            WHEN generic_name ILIKE '%fentanyl%' THEN 'fentanyl'
            WHEN generic_name ILIKE '%hydrocodone%' THEN 'hydrocodone'
            WHEN generic_name ILIKE '%morphine%' THEN 'morphine'
            WHEN generic_name ILIKE '%oxycodone%' THEN 'oxycodone'
            WHEN generic_name ILIKE '%oxymorphone%' THEN 'oxymorphone' 
        END AS drug_category,
        SUM(total_claim_count)::int AS total_claims
    FROM 
        prescription
	INNER JOIN 
        prescriber USING (npi)
    INNER JOIN 
        drug USING (drug_name)
    WHERE 
        nppes_provider_city in ('NASHVILLE','MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
    GROUP BY 
        city, drug_category
    ORDER BY 
        city
    $$
) AS well_done(
    city TEXT,
    codeine INT,
    fentanyl INT,
    hydrocodone INT,
    morphine INT,
    oxycodone INT,
    oxymorphone INT
);

CREATE EXTENSION tablefunc;













