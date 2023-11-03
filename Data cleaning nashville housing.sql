SELECT * FROM CleaningProject.`nashville housing datacleaning`;

SET SQL_SAFE_UPDATES = 0;


#Standardize Date format
SELECT SaleDate, CAST(SaleDate AS DATE) FROM CleaningProject.`nashville housing datacleaning`;
SELECT SaleDate, STR_TO_DATE(SaleDate, '%Y-%m-%d') FROM CleaningProject.`nashville housing datacleaning`;
UPDATE CleaningProject.`nashville housing datacleaning`
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%Y-%m-%d')
WHERE SaleDate = 'June 10, 2014';

#Filling out missing address in our Table where property Address Data is empty
-- to preserve the struture of the Data
Select * FROM CleaningProject.`nashville housing datacleaning`
order by ParcelID;

SELECT * FROM CleaningProject.`nashville housing datacleaning` WHERE PropertyAddress = '';



SELECT A.ParcelID, A.PropertyAddress, 
       B.ParcelID , B.PropertyAddress 
FROM CleaningProject.`nashville housing datacleaning` A
JOIN CleaningProject.`nashville housing datacleaning` B
ON A.ParcelID = B.ParcelID
   AND A.UniqueID <> B.UniqueID
   
  -- updating our property address with empty rows as NO ADDRESS
UPDATE CleaningProject.`nashville housing datacleaning`
SET PropertyAddress = 'No Address' WHERE PropertyAddress = 'DefaultValue';

-- Breaking out all the address into Individual COLUMNS (ADDRESS, CITY, STATE)
-- Shows how to split values  into different columns.

SELECT
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
FROM CleaningProject.`nashville housing datacleaning`;
 
ALTER TABLE CleaningProject.`nashville housing datacleaning`
ADD PropertySplitAddress Varchar(255);

UPDATE CleaningProject.`nashville housing datacleaning`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1)

ALTER TABLE CleaningProject.`nashville housing datacleaning`
ADD PropertySplitCity Varchar(255);

UPDATE CleaningProject.`nashville housing datacleaning`
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress))


SELECT
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1), ',', 1) AS Component1,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS Component2,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -3), ',', 1) AS Component3
FROM CleaningProject.`nashville housing datacleaning`;

ALTER TABLE CleaningProject.`nashville housing datacleaning`
ADD OwnerSplitAddress Varchar(255);

UPDATE CleaningProject.`nashville housing datacleaning`
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1), ',', 1)


ALTER TABLE CleaningProject.`nashville housing datacleaning`
ADD OwnerSplitCity Varchar(255);

UPDATE CleaningProject.`nashville housing datacleaning`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)

ALTER TABLE CleaningProject.`nashville housing datacleaning`
ADD OwnerSplitState Varchar(255);

UPDATE CleaningProject.`nashville housing datacleaning`
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -3), ',', 1)

-- Change Y and N to YES and NO in 'Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM CleaningProject.`nashville housing datacleaning`
Group by SoldAsvacant
order by 2;


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'NO'
       ELSE SoldAsVacant
       END
       FROM CleaningProject.`nashville housing datacleaning`;

UPDATE CleaningProject.`nashville housing datacleaning`
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'NO'
       ELSE SoldAsVacant
       END;
       
-- REMOVE DUPLICATES 
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY `UniqueID`
       ) AS row_num
FROM CleaningProject.`nashville housing datacleaning`
-- ORDER BY ParcelID;
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY `UniqueID`
           ) AS row_num
    FROM CleaningProject.`nashville housing datacleaning`
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;


-- ORDER BY ParcelID;

-- DELETE ALL DUPLICATES
DELETE FROM CleaningProject.`nashville housing datacleaning`
WHERE `UniqueID` IN (
    SELECT `UniqueID`
    FROM (
        SELECT `UniqueID`,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY `UniqueID`
               ) AS row_num
        FROM CleaningProject.`nashville housing datacleaning`
    ) AS RowNumCTE
    WHERE row_num > 1
);

-- DELETE UNUSED COLUMNS

ALTER TABLE CleaningProject.`nashville housing datacleaning`
DROP COLUMN OwnerAddress, DROP COLUMN TaxDistrict, DROP COLUMN PropertyAddress;

                  
