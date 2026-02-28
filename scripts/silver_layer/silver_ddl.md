CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        -------------------------------------------------
        -- Loading CRM Tables
        -------------------------------------------------

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        -------------------------------------------------
        -- 1️⃣ silver.crm_cust_info
        -------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM
        (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- 2️⃣ silver.crm_prd_info
        -------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info
        (
            cst_prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start,
            prd_end_dt
        )
        SELECT
            cst_prd_id,
            REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
            SUBSTRING(prd_key,7,LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost,0),
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start AS DATE),
            CAST(
                DATEADD(
                    DAY,
                    -1,
                    LEAD(prd_start) OVER (PARTITION BY prd_key ORDER BY prd_start)
                )
                AS DATE
            )
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- 3️⃣ silver.crm_sales_details
        -------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details
        (
            cst_sls_ord_num,
            cst_sls_prd_key,
            cst_sls_cust_id,
            cst_sls_order_dt,
            cst_sls_ship_dt,
            cst_sls_due_dt,
            cst_sls_sales,
            cst_sls_quantity,
            cst_sls_price
        )
        SELECT
            cst_sls_ord_num,
            cst_sls_prd_key,
            cst_sls_cust_id,

            CASE
                WHEN cst_sls_order_dt = 0 OR LEN(cst_sls_order_dt) <> 8 THEN NULL
                ELSE CAST(CAST(cst_sls_order_dt AS VARCHAR(8)) AS DATE)
            END,

            CASE
                WHEN cst_sls_ship_dt = 0 OR LEN(cst_sls_ship_dt) <> 8 THEN NULL
                ELSE CAST(CAST(cst_sls_ship_dt AS VARCHAR(8)) AS DATE)
            END,

            CASE
                WHEN cst_sls_due_dt = 0 OR LEN(cst_sls_due_dt) <> 8 THEN NULL
                ELSE CAST(CAST(cst_sls_due_dt AS VARCHAR(8)) AS DATE)
            END,

            CASE
                WHEN cst_sls_sales IS NULL
                     OR cst_sls_sales <= 0
                     OR cst_sls_sales <> cst_sls_quantity * ABS(cst_sls_price)
                THEN cst_sls_quantity * ABS(cst_sls_price)
                ELSE cst_sls_sales
            END,

            cst_sls_quantity,

            CASE
                WHEN cst_sls_price IS NULL OR cst_sls_price <= 0
                THEN cst_sls_sales / NULLIF(cst_sls_quantity,0)
                ELSE cst_sls_price
            END

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- 4️⃣ silver.erp_cust_az12
        -------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12
        (
            erp_cid,
            erp_bdate,
            erp_gen
        )
        SELECT
            CASE
                WHEN erp_cid LIKE 'NAS%' THEN SUBSTRING(erp_cid,4,LEN(erp_cid))
                ELSE erp_cid
            END,
            CASE
                WHEN erp_bdate > GETDATE() THEN NULL
                ELSE erp_bdate
            END,
            CASE
                WHEN UPPER(TRIM(erp_gen)) IN ('F','FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(erp_gen)) IN ('M','MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- ERP Tables
        -------------------------------------------------

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        -------------------------------------------------
        -- 5️⃣ silver.erp_loc_a101
        -------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101
        (
            erp_cid,
            erp_cntry
        )
        SELECT
            REPLACE(erp_cid,'-',''),
            CASE
                WHEN TRIM(erp_cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(erp_cntry) IN ('US','USA') THEN 'United States'
                WHEN erp_cntry IS NULL OR TRIM(erp_cntry) = '' THEN 'n/a'
                ELSE TRIM(erp_cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- 6️⃣ silver.erp_px_cat_g1v2
        -------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2
        (
            erp_id,
            erp_cat,
            erp_subcat,
            erp_maintainance
        )
        SELECT
            erp_id,
            erp_cat,
            erp_subcat,
            erp_maintainance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- Batch Completed
        -------------------------------------------------

        SET @batch_end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT 'Total Load Duration: ' 
              + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)
              + ' seconds';
        PRINT '==========================================';

    END TRY

    BEGIN CATCH

        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';

    END CATCH
END;
