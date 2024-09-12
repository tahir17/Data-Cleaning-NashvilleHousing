/*

Cleaning Data in SQL Queries

*/

select * 
from PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, CONVERT(Date, SaleDate) 
from PortfolioProject.dbo.NashvilleHousing

update dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * 
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
     and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
     and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address         
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City       --(-1,+1) to get rid of the ','
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress 
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress,
parsename(REPLACE(OwnerAddress, ',','.'),3) 
,parsename(REPLACE(OwnerAddress, ',','.'),2)
,parsename(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = parsename(REPLACE(OwnerAddress, ',','.'),1)

select * 
from PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE AS(
select *, 
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num >1
--order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select *
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate











-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















