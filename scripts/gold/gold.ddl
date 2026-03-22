
/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/



-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers as 
select 
	row_number() over (order by cst_id) as customekey,
	ci.cst_id as customer_id ,
	ci.cst_key as customer_number ,
	ci.cst_firstname as first_name ,
	ci.cst_lastname as last_name ,
	la.erp_cntry as country ,
	ci.cst_material_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
	else coalesce(ca.erp_gen,'n/a')
  end as gender,
	ca.erp_bdate as birth_date,
	ci.cst_create_date as  create_date
from silver.crm_cust_info ci
	left join silver.erp_cust_az12 ca
	on ci.cst_key = ca.erp_cid
	left join  silver.erp_loc_a101 la
	on ci.cst_key = la.erp_cid


-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products as 
SELECT 
         ROW_NUMBER() OVER (ORDER BY pn.prd_start,pn.prd_key) as product_key,
         pn.cst_prd_id as product_id,
         pn.prd_key as product_number,
         pn.prd_nm as product_name ,
         pn.cat_id as category_id ,
         pc.erp_cat as category,
         pc.erp_subcat as subcategory,
         pc.erp_maintainance maintenance,
         pn.prd_cost as cost,
         pn.prd_line as product_line,
         pn.prd_start as start_date
  FROM DataWarehouse.silver.crm_prd_info pn 
  left join silver.erp_px_cat_g1v2 pc
  on pn.cat_id = pc.erp_id 

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales as 
SELECT  
       sd.cst_sls_ord_num as order_number,
       pr.product_key,
       cu.customekey as customer_key
      ,sd.cst_sls_order_dt as order_date
      ,sd.cst_sls_ship_dt as  shipping_date
      ,sd.cst_sls_due_dt as due_date
      ,sd.cst_sls_sales as amount 
      ,sd.cst_sls_quantity as quantity 
      ,sd.cst_sls_price as selling_price  
  FROM silver.crm_sales_details sd 
  left join gold.dim_products pr 
  on sd.cst_sls_prd_key = pr.product_number 
  left join gold.dim_customers cu 
  on sd.cst_sls_cust_id = cu.customer_id  

