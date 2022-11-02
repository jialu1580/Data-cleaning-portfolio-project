
------I WANT TO DO DATA CLEANING 

select * 
from dbo.Nashville_Housing_Data

---standardize the date format
select saledatecovert,cast (SaleDate as date)----other method: convert(date,SaleDate)
from dbo.Nashville_Housing_Data

alter table Nashville_Housing_Data
ADD saledatecovert date
update Nashville_Housing_Data
SET saledatecovert =cast (SaleDate as date)



------populate adress����ַ-----�鿴����ʱ������Щ��ַ��null,��parcelid��ͬʱ���ǵĵ�ַҲ��ͬ����unique id û����ͬ�ģ���query �����ȱʧ��adress ��Ϊpercelid��ͬ����adress
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull (a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing_Data a
join Nashville_Housing_Data b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

update a  -----���±��
set PropertyAddress =isnull (a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing_Data a
join Nashville_Housing_Data b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

------breaking address to (address,city,state)


select PropertyAddress
from dbo.Nashville_Housing_Data

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,----SUBSTRING()�������ַ����е�λ�ÿ�ʼ��ȡ����ָ�����ȵ����ַ���
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)-CHARINDEX(',',PropertyAddress) )as city
from dbo.Nashville_Housing_Data


alter table Nashville_Housing_Data
ADD propertysplitadress nvarchar(255)

alter table Nashville_Housing_Data------����һ������Ϊ�Ұ�nvarchar һ��ʼ���ô���Ϊ25
drop column  propertysplitadress 

update Nashville_Housing_Data
SET propertysplitadress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table Nashville_Housing_Data
ADD propertysplitcity nvarchar(255)
update Nashville_Housing_Data
SET propertysplitcity  =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)-CHARINDEX(',',PropertyAddress) )


-----oweraddress----
select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as owneraddress,-----parsename һ���ָ��ַ����ĺ��������ݡ�.����Ϊ�ָ��������ٻ�ȡ�ֽ��Ĳ���
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as ownercity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as ownerstate
from Nashville_Housing_Data




alter table Nashville_Housing_Data
ADD ownersplitaddress nvarchar(255)

update Nashville_Housing_Data
SET ownersplitaddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

alter table Nashville_Housing_Data
ADD ownersplitcity nvarchar(255)

update Nashville_Housing_Data
SET ownersplitcity =PARSENAME(REPLACE(OwnerAddress,',','.'),2) 


alter table Nashville_Housing_Data
ADD ownersplitstate nvarchar(255)

update Nashville_Housing_Data
SET ownersplitstate =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * 
from dbo.Nashville_Housing_Data


------------ change Y/N to yes /no
select distinct SoldAsVacant,count( SoldAsVacant)
from dbo.Nashville_Housing_Data
group by SoldAsVacant
order by 2

select SoldAsVacant,------------------------------case������
case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end
from dbo.Nashville_Housing_Data


update Nashville_Housing_Data
set SoldAsVacant= case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end
from dbo.Nashville_Housing_Data




-----------remove duplicates-----
with rownumCTE as(
select *,
ROW_NUMBER() over(
partition by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference 
order by [UniqueID ]) rownum
from dbo.Nashville_Housing_Data)

select *
from rownumCTE
where rownum >1
--------------------------��ѯ����Ҫ����Щɾ������������дһ�飬����Ĳ�ѯ�����Ҳ���ɾ��
with rownumCTE as(
select *,
ROW_NUMBER() over(
partition by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference 
order by [UniqueID ]) rownum
from dbo.Nashville_Housing_Data)

delete
from rownumCTE
where rownum >1


------------------delete unuse 

select *
from Nashville_Housing_Data

alter table Nashville_Housing_Data
drop column  PropertyAddress,SaleDate,OwnerAddress,TaxDistrict