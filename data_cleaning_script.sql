--Creating all required tables for analysis

create table crm.CUST_AZ12 ( 
	cid varchar,
	bdate date,
	gen varchar
	);


create table crm.LOC_A101 ( 
	cid varchar,
	cntry varchar
);

create table crm.PX_CAT_G1V2( 
	id varchar,
	cat varchar,
	subcat varchar,
	maintenance varchar
);



-- Data was loaded manually, checking each table before cleaning
	
	select *
	from crm.LOC_A101;
	
	select *
	from crm.CUST_AZ12;
	
	select *
	from crm.PX_CAT_G1V2;
	
	select *
	from crm.cust_info;
	
	select *
	from crm.prd_info;
	
	select *
	from crm.sales_details;
	

-- cleaning cst_info_table
select 
	*
from crm.cust_info;

--Expectations
--1. Check for duplicate
--2. Check if cust_id is null

select 
	cst_id,
	count(*) as no_of_row 
from crm.cust_info 
group by cst_id
having count(*) >1;

select 
	*
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
)
where row_number =1;

select 	
	*
from crm.cust_info 
where cst_id is null;

select 
	*
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
where cst_id is not null
)
where row_number =1;

--3. cst -key does not have duplicates

with temp_table as (
select 
	*
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
where cst_id is not null
)
where row_number =1
)
select 
	cst_key,
	count(*) as no_of_row 
from temp_table 
group by cst_key
having count(*) >1;

-- 4. cst_firstname should not have white space (extra space)

select 
	cst_firstname
from  crm.cust_info
where cst_firstname != trim(cst_firstname);

select 
	trim (cst_firstname)
from  crm.cust_info;

select 
	cst_id,
	cst_key,
	trim (cst_firstname) as cst_firstname,
	trim (cst_lastname) as cst_lastname
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
where cst_id is not null
)
where row_number =1;

--replacing letters with words 

select 
	*
from crm.cust_info;

select 
	case 
		when cst_marital_status = 'M' then 'Married'
		when cst_marital_status = 'S' then 'Single'
		else 'n/a'
	end as cst_marital_status;



select 
	cst_id,
	cst_key,
	trim (cst_firstname) as cst_firstname,
	trim (cst_lastname) as cst_lastname,
	case 
		when cst_marital_status = 'M' then 'Married'
		when cst_marital_status = 'S' then 'Single'
		else 'n/a'
	end as cst_marital_status
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
where cst_id is not null
)
where row_number =1;

-- 5. Expectation: Gender should contain male and female else n/a

select 
	case 
		when cst_gndr= 'M' then 'Male'
		when cst_gndr= 'F' then 'Female'
		else 'n/a'
	end as cst_gndr
from crm.cust_info;

select 
	cst_id,
	cst_key,
	trim (cst_firstname) as cst_firstname,
	trim (cst_lastname) as cst_lastname,
	case 
		when cst_marital_status = 'M' then 'Married'
		when cst_marital_status = 'S' then 'Single'
		else 'n/a'
	end as cst_marital_status,
	case 
		when  upper(cst_gndr)= 'M' then 'Male'
		when upper(cst_gndr)= 'F' then 'Female'
		else 'n/a'
	end as cst_gndr,
	cst_create_date
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
where cst_id is not null
)
where row_number =1;

select 
	cst_create_date
from  crm.cust_info
where  cst_create_date < '2025-01-01';



-- cleaning prod_info_table

select 
	*
from crm.prd_info;

select 
	prd_id,
	count (*) as no_of_rows
from crm.prd_info
group by crm.prd_info.prd_id 
having count (*) > 1;

select 
	prd_id
from crm.prd_info
where prd_id is null;

select 
	prd_key,
	count (*) as no_of_rows
from crm.prd_info
group by crm.prd_info.prd_key 
having count (*) > 1;

select 
	prd_key
from crm.prd_info
where prd_key is null;

select 
	*
from crm.prd_info
where prd_key = 'CO-RF-FR-R38B-52';

select 
	replace(substring (prd_key, 1, 5), '-', '_') as cat_id,
	replace(substring (prd_key, 7, length(prd_key)), '-', '_') as prd_key,
	coalesce(prd_cost, 0) as  prd_cost,
	case 
		when upper(trim(prd_line)) = 'M' then 'Mountain'
		when upper(trim(prd_line))= 'R' then 'Road'
		when upper(trim(prd_line)) = 'S' then 'Other Sales'
		when upper(trim(prd_line)) = 'T' then 'Touring'
		else 'n/a'
	end as prd_line,
	prd_start_dt,
	lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt
from crm.prd_info;


select 
	prd_id
from crm.prd_info
where prd_cost < 0;


select 
coalesce(prd_cost, 0) as  prd_cost
from crm.prd_info;


select 
	distinct(prd_line)
	from crm.prd_info;

select 
	case 
		when upper(trim(prd_line)) = 'M' then 'Mountain'
		when upper(trim(prd_line))= 'R' then 'Road'
		when upper(trim(prd_line)) = 'S' then 'Other Sales'
		when upper(trim(prd_line)) = 'T' then 'Touring'
		else 'n/a'
	end as prd_line
from crm.prd_info;

select 
	*
from crm.prd_info
where prd_start_dt is null;

select 
	*
from crm.prd_info
where prd_start_dt > prd_end_dt;

select 
	*,
	lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt
from crm.prd_info;

--cleaning sales detail table

select *
	from crm.sales_details;

select 
	sls_ord_num,
	count (*) as row_no
from crm.sales_details
group by sls_ord_num
having count(*) >1;

select 
	*
from crm.sales_details sd
where sd.sls_ord_num = 'SO67487' ;

select 
	*
from crm.sales_details sd
where sd.sls_ord_num is null;


select 
	*
from crm.sales_details 
where sls_prd_key not in (
select 
	substring (prd_key, 7, length(prd_key)) as prd_key
from crm.prd_info
);
 
select 
	*
from crm.sales_details 
where sls_cust_id not in (
select 
	cst_id
from crm.cust_info
);

select 
	*
from crm.sales_details 
where length(cast(sls_order_dt as varchar)) != 8;

select 
	case
		when cast(sls_order_dt as int)= 0 or length(cast(sls_order_dt as varchar)) != 8 then null 
		else cast(cast(sls_order_dt as varchar) as date)
	end as sls_order_dt
	from crm.sales_details;
	
select 
	case
		when cast(sls_ship_dt as int)= 0 or length(cast(sls_ship_dt as varchar)) != 8 then null 
		else cast(cast(sls_ship_dt as varchar) as date)
	end as sls_ship_dt
	from crm.sales_details;

	
select
	case
		when cast(sls_due_dt as int)= 0 or length(cast(sls_due_dt as varchar)) != 8 then null 
		else cast(cast(sls_due_dt as varchar) as date)
	end as sls_due_dt
	from crm.sales_details;
 
select 
	*
from crm.sales_details
where sls_sales is null or sls_sales <= 0;

select 
	*
from crm.sales_details
where sls_sales !=  (sls_quantity * ABS(sls_price));

select 
	case 
		when sls_sales is null or sls_sales <= 0 or sls_sales !=  (sls_quantity * ABS(sls_price))
			then sls_quantity * ABS(sls_price)
		else sls_sales
	end as sls_sales
	from crm.sales_details;
	
select 
	case 
		when sls_price is null or sls_price <=0 or sls_price !=  (sls_sales/sls_quantity)
			then sls_sales/ coalesce(sls_quantity, 0)
		else sls_price
	end as sls_price
	from crm.sales_details;
	
--cleaning CUST_AZ12 table
	
	select 
		case 
			when upper(gen) = 'M' then 'Male'
			when upper(gen) = 'F' then 'Female'
			else gen
		end as gen
	from crm.CUST_AZ12;
		
	select 
		min(bdate) as earliest ,
		max(bdate) as latest
	from crm.CUST_AZ12;
	
	select * 
	from crm.CUST_AZ12
		where bdate = '9999-11-20'; 
	
	
	select 
		case 
			when bdate > current_date then null
			else bdate
		end as bdate
	from crm.CUST_AZ12;
	
	
	
	--Creating new schema and tables for cleaned data
	create schema ccrm;
	
	create table ccrm.sales_details as 
	select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case
		when cast(sls_order_dt as int)= 0 or length(cast(sls_order_dt as varchar)) != 8 then null 
		else cast(cast(sls_order_dt as varchar) as date)
	end as sls_order_dt,
	case
		when cast(sls_ship_dt as int)= 0 or length(cast(sls_ship_dt as varchar)) != 8 then null 
		else cast(cast(sls_ship_dt as varchar) as date)
	end as sls_ship_dt,
	case
		when cast(sls_due_dt as int)= 0 or length(cast(sls_due_dt as varchar)) != 8 then null 
		else cast(cast(sls_due_dt as varchar) as date)
	end as sls_due_dt,
	case 
		when sls_sales is null or sls_sales <= 0 or sls_sales !=  (sls_quantity * ABS(sls_price))
			then sls_quantity * ABS(sls_price)
		else sls_sales
	end as sls_sales,
	sls_quantity,
	case 
		when sls_price is null or sls_price <=0 or sls_price !=  (sls_sales/sls_quantity)
			then sls_sales/ coalesce(sls_quantity, 0)
		else sls_price
	end as sls_price
	from crm.sales_details;
	
create table ccrm.cst_info as
select 
	cst_id,
	cst_key,
	trim (cst_firstname) as cst_firstname,
	trim (cst_lastname) as cst_lastname,
	case 
		when cst_marital_status = 'M' then 'Married'
		when cst_marital_status = 'S' then 'Single'
		else 'n/a'
	end as cst_marital_status,
	case 
		when  upper(cst_gndr)= 'M' then 'Male'
		when upper(cst_gndr)= 'F' then 'Female'
		else 'n/a'
	end as cst_gndr,
	cst_create_date
from ( 
select 
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as row_number
from  crm.cust_info
where cst_id is not null
)
where row_number =1;




create table ccrm.prd_info as
select 
	prd_id,
	replace(substring (prd_key, 1, 5), '-', '_') as cat_id,
	replace(substring (prd_key, 7, length(prd_key)), '-', '_') as prd_key,
	prd_nm,
	coalesce(prd_cost, 0) as  prd_cost,
	case 
		when upper(trim(prd_line)) = 'M' then 'Mountain'
		when upper(trim(prd_line))= 'R' then 'Road'
		when upper(trim(prd_line)) = 'S' then 'Other Sales'
		when upper(trim(prd_line)) = 'T' then 'Touring'
		else 'n/a'
	end as prd_line,
	prd_start_dt,
	lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt
from crm.prd_info;





create table ccrm.CUST_AZ12 as
select 
	cid,
		case 
			when bdate > current_date then null
			else bdate
		end as bdate,
		case 
			when upper(gen) = 'M' then 'Male'
			when upper(gen) = 'F' then 'Female'
			else gen
		end as gen
	from crm.CUST_AZ12;


create table ccrm.LOC_A101(
	cid varchar,
	cntry varchar
);

create table ccrm.PX_CAT_G1V2(
	id varchar,
	cat varchar,
	subcat varchar,
	maintenance varchar
);





