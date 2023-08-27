USE NashvilleHousingPortfolioProject
GO


SELECT * 
FROM NashvilleHousing nh


--Standardize Date Format

--UPDATE nh
--SET nh.SaleDate = CONVERT(DATE, nh.SaleDate)
SELECT nh.SaleDate, CONVERT(DATE, nh.SaleDate)
FROM NashvilleHousing nh


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT nh.SaleDateConverted
FROM NashvilleHousing nh


--Populate Propery Address Data

--UPDATE nh
--SET nh.PropertyAddress = nh1.PropertyAddress
SELECT nh.PropertyAddress, nh1.PropertyAddress
FROM NashvilleHousing nh
INNER JOIN NashvilleHousing nh1
ON nh.ParcelID = nh1.ParcelID
AND nh.[UniqueID ] <> nh1.[UniqueID ]
WHERE nh.PropertyAddress IS NULL


--Breaking out Address into Individual Columns (Address, City, State)

--PropertyAddress with LEFT, CHARINDEX, SUBSTRING
SELECT nh.PropertyAddress, CHARINDEX(',', nh.PropertyAddress) 
,LEFT(nh.PropertyAddress, CHARINDEX(',', nh.PropertyAddress) -1) AS Address 
,SUBSTRING(nh.PropertyAddress, CHARINDEX(',', nh.PropertyAddress) +1, LEN(nh.PropertyAddress) - CHARINDEX(',', nh.PropertyAddress) +1) AS City
FROM NashvilleHousing nh


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) +1)

SELECT nh.PropertyAddress, nh.PropertySplitAddress, nh.PropertySplitCity
FROM NashvilleHousing nh


--OwnerAddress with PARSENAME and REPLACE
SELECT nh.OwnerAddress
,REPLACE(nh.OwnerAddress, ',', '.')
,PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress
,PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 2) AS OwnerSplitCity
,PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing nh

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
OwnerSplitCity NVARCHAR(255),
OwnerSplitState NVARCHAR(255)

--UPDATE nh
--SET nh.OwnerSplitAddress = PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 3),
--nh.OwnerSplitCity = PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 2),
--nh.OwnerSplitState = PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 1)
SELECT nh.OwnerAddress
,REPLACE(nh.OwnerAddress, ',', '.')
,PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress
,nh.OwnerSplitAddress
,PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 2) AS OwnerSplitCity
,nh.OwnerSplitCity
,PARSENAME(REPLACE(nh.OwnerAddress, ',', '.'), 1) AS OwnerSplitState
,nh.OwnerSplitState
FROM NashvilleHousing nh


--Change Y and N to Yes and No in 'Sold as Vacant' field

--UPDATE nh
--SET nh.SoldAsVacant = 
--	 CASE WHEN nh.SoldAsVacant = 'Y' THEN 'Yes'
--	 WHEN nh.SoldAsVacant =  'N' THEN 'No'
--	 END
SELECT nh.SoldAsVacant,
CASE WHEN nh.SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN nh.SoldAsVacant =  'N' THEN 'No'
	 END
FROM NashvilleHousing nh
WHERE nh.SoldAsVacant NOT IN (
'Yes',
'No')

SELECT nh.SoldAsVacant, COUNT(*)
FROM NashvilleHousing nh
GROUP BY nh.SoldAsVacant


--Remove Duplicates

WITH cte AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY nh.ParcelID,
								   nh.PropertyAddress,
								   nh.SalePrice,
								   nh.SaleDate,
								   nh.LegalReference
								   ORDER BY nh.UniqueID) AS RowNum
FROM NashvilleHousing nh)

--DELETE c
SELECT * 
FROM cte c
WHERE c.RowNum > 1 


--Delete Unused Columns

SELECT *
FROM NashvilleHousing nh

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate