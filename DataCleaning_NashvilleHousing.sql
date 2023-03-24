/************************************
* Cleaning Data in SQL queries, in Microsoft SQL Server Studio
* Housing data from Nashville
**************************************/

----------------------------------------------------
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;
----------------------------------------------------

-- Standandize Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
	ADD SaleDateConverted Date;
UPDATE NashvilleHousing	
	SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;
----------------------------------------------------

-- Populate Property Address Data


-- Property address in general stay the same
-- We see that property addresses with the same ParcellID are the same
SELECT ParcelID, UniqueID,  PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null;

-- We'll use self-join to fill the address with another record that has the same ParcellID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null
ORDER by a.ParcelID;

UPDATE a 
	SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID];
-- checking to make sure that there is no PropertyAddress with null
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

--------------------------------------------------------------
-- Breaking out Address into individual columns (Address, City, State

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as State
FROM PortfolioProject.dbo.NashvilleHousing;

--update the data tables
ALTER TABLE NashvilleHousing
	ADD PropertyAddressOnly nvarchar(255);
UPDATE NashvilleHousing
	SET PropertyAddressONly = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
	ADD PropertyCityOnly nvarchar(255);
UPDATE NashvilleHousing
	SET PropertyCityOnly = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--use PARSENAME
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;

--update the data tables
ALTER TABLE NashvilleHousing
	ADD OwnerAddressOnly nvarchar(255);
UPDATE NashvilleHousing
	SET OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
	ADD OwnerCityOnly nvarchar(255);
UPDATE NashvilleHousing
	SET OwnerCityOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
	ADD OwnerStateOnly nvarchar(255);
UPDATE NashvilleHousing
SET OwnerStateOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-------------------------------------------------------------
-- Change Y and N in Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant 
ORDER by 2;
--use CASE statement
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END

------------------------------------------------------
-- Remove Duplicates

-- Write a CTE to search for duplicates using ROW_NUMBER

WITH RownNun AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE 
FROM RownNun
WHERE row_num > 1;


--Any duplicates left?

WITH RownNun AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RownNun
WHERE row_num > 1;

---------------------------------------------------------
-- Delete Used Column (not data on raw data tables)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;



