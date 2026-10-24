-----------------------------------------------------------------------
-- GENERATING [gold].[dim_customers] VIEW 
-----------------------------------------------------------------------
IF OBJECT_ID('[gold].[dim_customers]','v') IS NOT NULL
	DROP VIEW [gold].[dim_customers]
GO
CREATE VIEW gold.dim_customers as 
SELECT 
ROW_NUMBER() OVER(order by cst_id asc) AS id,
cust.cst_id as customer_id,
cust.cst_key as customer_number,
cust.cst_firstname as first_name,
cust.cst_lastname as last_name,
cust.cst_marital_status as marital_status,
case
	when cst_gndr!='n/a' then cst_gndr
	else coalesce(gen,'n/a')
end gender,
az.bdate as birth_date,
a.cntry as country,
a.dwh_create_date as last_updated
FROM silver.crm_cust_info AS cust
LEFT JOIN silver.erp_cust_az12 as az
ON cust.cst_key=az.cid
LEFT JOIN silver.erp_loc_a101 as a
ON a.cid=cust.cst_key

GO 
-----------------------------------------------------------------------
-- GENERATING gold.dim_products VIEW 
-----------------------------------------------------------------------
IF OBJECT_ID('gold.dim_products','v') IS NOT NULL
	DROP VIEW gold.dim_products
GO
CREATE VIEW gold.dim_products as
select
ROW_NUMBER() OVER(ORDER BY prd.prd_id ASC) AS product_key,
prd.prd_id as product_id,
prd.prd_key as product_number ,
prd.prd_nm as product_name,
prd.cat_id as category_id,
dt.cat as category,
dt.subcat as sub_category ,
prd.prd_cost as product_cost,
prd.prd_line as prd_line,
dt.maintenance as maintenance,
prd.prd_start_dt as start_date,
dt.dwh_create_date as last_updated
from silver.crm_prd_info as prd
left join silver.erp_px_cat_g1v2 as dt
on prd.cat_id=dt.id 
-----------------------------------------------------------------------
-- GENERATING gold.fact_sales VIEW 
-----------------------------------------------------------------------
GO
IF OBJECT_ID('gold.fact_sales','v') IS NOT NULL
	DROP VIEW gold.fact_sales
GO
create view gold.fact_sales as 
select 
sls_ord_num as order_number,
cust.id as cutomer_id,
prd.product_key as product_id,
sls_order_dt as order_date,
sls_ship_dt as shipping_date,
sls_due_dt as due_date,
sls_sales as total_cost,
sls_quantity as quantiy,
sls_price as price,
dwh_create_date as last_updated
from [silver].[crm_sales_details] as fac
left join  [gold].[dim_customers] as cust
on cust.customer_id=fac.sls_cust_id
left join  [gold].[dim_products] as prd
on prd.product_number=fac.sls_prd_key
