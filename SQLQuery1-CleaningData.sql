--Data Cleaning Portfolio || Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProjectCovid.dbo.NashvilleHousing

--Standardize date format datetime -> date

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProjectCovid.dbo.NashvilleHousing

UPDATE NashvilleHousing SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing add SaleDateConverted Date;

UPDATE NashvilleHousing SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProjectCovid.dbo.NashvilleHousing

--Populate property address data who's NULL
--Populate using ParcelID because PropertyAddress = NULL has the same ParcelID with <> NULL
--We doing self join to do that
SELECT *
FROM PortfolioProjectCovid.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjectCovid.dbo.NashvilleHousing AS a
JOIN PortfolioProjectCovid.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjectCovid.dbo.NashvilleHousing AS a
JOIN PortfolioProjectCovid.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


--Breaking out Address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProjectCovid.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) AS City
FROM PortfolioProjectCovid.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

ALTER TABLE NashvilleHousing add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


SELECT *
FROM PortfolioProjectCovid.dbo.NashvilleHousing



--Cleaning NULL value in OwnerAddress with using alternate SUBSTRING (easier)
SELECT OwnerAddress
FROM PortfolioProjectCovid.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjectCovid.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProjectCovid.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "SoldAsVacant" field because some of them is just N or Y
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjectCovid.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProjectCovid.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END


--Remove duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY
										UniqueID
										) AS row_num

FROM PortfolioProjectCovid.dbo.NashvilleHousing
--ORDER BY ParcelID
)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--Delete unused columns if consume disk and memoy, or we can just filter it in BI tools
--In this query im not gonna do it, but just in case

--SELECT *
--FROM PortfolioProjectCovid.dbo.NashvilleHousing

--ALTER TABLE PortfolioProjectCovid.dbo.NashvilleHousing
--DROP COLUMN OwnerAddress, PropertyAddress, SaleDate