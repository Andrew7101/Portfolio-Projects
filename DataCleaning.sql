/*

Cleaning Data in SQL Queries

*/


Select *
From housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, '%m/%d/%Y');

ALTER TABLE housing
ADD COLUMN SaleDateConverted DATE;

UPDATE housing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%m/%d/%Y');



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From housing
order by ParcelID;


-- SELECT query
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress) AS MergedAddress
FROM housing a
JOIN housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- UPDATE query
UPDATE housing a
JOIN housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From housing;
-- Where PropertyAddress is null
-- order by ParcelID

SELECT
SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 2) AS RemainingAddress
FROM housing;


ALTER TABLE housing
Add PropertySplitAddress Nvarchar(255);

Update housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);


ALTER TABLE housing
Add PropertySplitCity Nvarchar(255);

Update housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 2);



Select *
From housing;


Select OwnerAddress
From housing;


SELECT
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1)
FROM PortfolioProject.NashvilleHousing;



ALTER TABLE housing
Add OwnerSplitAddress Nvarchar(255);

Update housing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1);


ALTER TABLE housing
Add OwnerSplitCity Nvarchar(255);

Update housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1);


ALTER TABLE housing
Add OwnerSplitState Nvarchar(255);

Update housing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1);



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From housing
Group by SoldAsVacant
order by 2;


SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS UpdatedSoldAsVacant
FROM housing;


UPDATE housing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM housing
) AS RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


Select *
From housing;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

Select *
From housing;







