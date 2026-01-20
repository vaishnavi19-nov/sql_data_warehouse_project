/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_id('bronze.crm_cust_info', 'U') IS NOT NULL 
DROP TABLE bronze.crm_cust_info
GO
CREATE TABLE bronze.crm_cust_info
(
	cst_id INT,
	cst_key NVARchar(50),
	cst_firstname NVARCHAR(50),
	cst_lastname Nvarchar(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO

IF OBJECT_id('bronze.crm_prd_info', 'U') IS NOT NULL 
DROP TABLE bronze.crm_prd_info
 GO
CREATE TABLE bronze.crm_prd_info
(
  cst_prd_id INT ,
  prd_key NVARCHAR(50),
  prd_nm NVARCHAR(50),
  prd_cost INT,
  prd_line VARCHAR(20),
  prd_start DATE,
  prd_end_dt DATE
);
GO

IF OBJECT_id('bronze.crm_sales_details', 'U') IS NOT NULL 
DROP TABLE bronze.crm_sales_details
  GO
CREATE TABLE bronze.crm_sales_details
(
	cst_sls_ord_num NVARCHAR(20),
	cst_sls_prd_key NVARCHAR(20),
	cst_sls_cust_id INT,
	cst_sls_order_dt INT,
	cst_sls_ship_dt INT,
	cst_sls_due_dt INT,
	cst_sls_sales INT,
	cst_sls_quantity INT,
	cst_sls_price INT
);
GO

IF OBJECT_id('bronze.erp_cust_az12', 'U') IS NOT NULL 
DROP TABLE bronze.erp_cust_az12
GO
CREATE TABLE bronze.erp_cust_az12
(
	erp_cid NVARCHAR(20),
	erp_bdate date ,
	erp_gen VARCHAR(10)
);
GO

IF OBJECT_id('bronze.erp_loc_a101', 'U') IS NOT NULL 
DROP TABLE bronze.erp_loc_a101
GO
CREATE TABLE bronze.erp_loc_a101
(
erp_cid NVARCHAR(20),
erp_cntry VARCHAR(25)
);
GO


IF OBJECT_id('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL 
DROP TABLE bronze.erp_px_cat_g1v2
GO
CREATE TABLE bronze.erp_px_cat_g1v2
(
	erp_id VARCHAR(20),
	erp_cat VARCHAR(20),
	erp_subcat VARCHAR(20),
	erp_maintainance VARCHAR(20)
);
GO
