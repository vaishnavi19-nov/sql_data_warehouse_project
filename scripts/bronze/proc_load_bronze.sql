/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;

		BEGIN TRY
		PRINT '==========================';
		PRINT 'LOADING THE BRONZE LAYER';
		PRINT '==========================';

		PRINT '-------------------------------';
		PRINT 'Loading the CRM Tables';
		PRINT '-------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING THE TABLE: bronze.crm_cust_info';
		--1st table
		TRUNCATE TABLE bronze.crm_cust_info
		PRINT '>> INSERTING THE DATA INTO: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\LENOVO\Downloads\warehouse project zip\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2, 
			FIELDTERMINATOR =  ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + cast(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT '-----------------------------'



		--2nd table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING THE TABLE: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '>> INSERTING THE DATA INTO: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\LENOVO\Downloads\warehouse project zip\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2, 
			FIELDTERMINATOR =  ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + cast(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT '-----------------------------'



		--3rd table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING THE TABLE: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '>> INSERTING THE DATA INTO: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\LENOVO\Downloads\warehouse project zip\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2, 
			FIELDTERMINATOR =  ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + cast(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT '-----------------------------'

		--4th table
		SET @start_time = GETDATE();
		PRINT '-------------------------------';
		PRINT 'Loading the ERP Tables';
		PRINT '-------------------------------';
		PRINT '>> TRUNCATING THE TABLE: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT '>> INSERTING THE DATA INTO: bronze.erp_cust_az12';

		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\LENOVO\Downloads\warehouse project zip\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH
		(
			FIRSTROW = 2, 
			FIELDTERMINATOR =  ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + cast(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT '-----------------------------'

		--5th table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING THE TABLE: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT '>> INSERTING THE DATA INTO: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\LENOVO\Downloads\warehouse project zip\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH
		(
			FIRSTROW = 2, 
			FIELDTERMINATOR =  ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + cast(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT '-----------------------------'

		--6th table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING THE TABLE: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>> INSERTING THE DATA INTO: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\LENOVO\Downloads\warehouse project zip\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH
		(
			FIRSTROW = 2, 
			FIELDTERMINATOR =  ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + cast(DATEDIFF(second,@start_time,@end_time) as nvarchar) + 'seconds';
		PRINT '-----------------------------'
	END TRY 
		BEGIN CATCH
		PRINT '===========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
	END CATCH
END
