Select *
From NashvilleHousing
---------------------------------------------------

-- Standardizing the Date Format in SaleDate coloumn

Select SaleDate
From NashvilleHousing

Select SaleDate, CONVERT(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
--It didn't work for some reason

--New aproach
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From NashvilleHousing
---------------------------------------------------

--Populating Property Address Data

Select PropertyAddress
From NashvilleHousing

Select *
From NashvilleHousing
Where PropertyAddress is null

Select PropertyAddress, ParcelID
From NashvilleHousing
--OR
Select *
From NashvilleHousing
Order by ParcelID

--ParcelID is same for same addresses and UniqueID is different for each

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

--Check to see if any data with PropertyAddress with NULL is present
Select *
From NashvilleHousing
Where PropertyAddress is null
---------------------------------------------------

--Breaking out the address into individual columns

Select PropertyAddress
From NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)) Address
From NashvilleHousing

--To remove ","
SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) Address
From NashvilleHousing

--Breaking after comma
SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) as Address
From NashvilleHousing

--Adding new columns in Table

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))

Select *
From NashvilleHousing

--Dealing with Owner Address

Select OwnerAddress
From NashvilleHousing

--Using new easier approach
Select 
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)
---------------------------------------------------

-- Changing Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant) , Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
---------------------------------------------------

--Removing Duplicates

--Looking for how many duplicates are there (Extra Optional Step)
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID) row_num
From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by ParcelID

--Deleting the Duplicates (Required step)
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID) row_num
From NashvilleHousing

)
DELETE
From RowNumCTE
Where row_num > 1
---------------------------------------------------

--Deleting Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From NashvilleHousing
---------------------------------------------------