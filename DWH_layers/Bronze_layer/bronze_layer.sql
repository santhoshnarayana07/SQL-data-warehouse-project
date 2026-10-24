CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN  
	DECLARE @start_time DATETIME
	DECLARE @end_time DATETIME
	DECLARE @b_s_time DATETIME
	DECLARE @b_e_time DATETIME
	BEGIN TRY
		
		SET @b_s_time=GETDATE()
		print('=================================')
		print('Loading Bronze Laye...')
		print('=================================')

		print('---------------------------------')
		print('Extracting CRM Date')
		print('---------------------------------')

		SET @start_time=GETDATE()

		PRINT('>>Truncating Tabel :bronze.crm_cust_info ')
		TRUNCATE TABLE bronze.crm_cust_info;
		
		PRINT('>> Inserting data  :bronze.crm_cust_info ')
		BULK INSERT  bronze.crm_cust_info
		from 'C:\Users\santh\Desktop\data_warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT('>> DURATION '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS')
		print('-------------------')
		SET @start_time=GETDATE()
		PRINT('>>Truncating Tabel :bronze.crm_prd_info ')
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT('>> Inserting data  :bronze.crm_prd_info ')
		BULK INSERT bronze.crm_prd_info
		from 'C:\Users\santh\Desktop\data_warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		)
		SET @end_time=GETDATE()
		PRINT('>> DURATION '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS')
		print('-------------------')

		SET @start_time=GETDATE()
		PRINT('>>Truncating Tabel :bronze.crm_sales_details ')
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT('>> Inserting data  :bronze.crm_sales_details ')
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\santh\Desktop\data_warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW =2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT('>> DURATION '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS')
		print('-------------------')

		print('---------------------------------')
		print('Extracting ERP Date')
		print('---------------------------------')
	
		SET @start_time=GETDATE()
		PRINT('>>Truncating Tabel :bronze.erp_cust_az12 ')
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT('>> Inserting data  :bronze.erp_cust_az12 ')
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\santh\Desktop\data_warehouse\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time=GETDATE()
		PRINT('>> DURATION '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS')
		print('-------------------')
		
		SET @start_time=GETDATE()
		PRINT('>>Truncating Tabel :bronze.erp_loc_a101 ')
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT('>> Inserting data  :bronze.erp_loc_a101 ')
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\santh\Desktop\data_warehouse\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT('>> DURATION '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS')
		print('-------------------')

		SET @start_time=GETDATE()
		PRINT('>>Truncating Tabel :bronze.erp_px_cat_g1v2 ')
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT('>> Inserting data  :bronze.erp_px_cat_g1v2 ')
		BULK INSERT  bronze.erp_px_cat_g1v2
		FROM 'C:\Users\santh\Desktop\data_warehouse\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE()
		PRINT('>> DURATION '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' SECONDS')
		print('-------------------')
		SET @b_e_time = GETDATE()
		print('=================================')
		print('Loading Bronze Layer Compleate ')
		PRINT('TOTAL TIME FOR BRONZE : '+CAST( DATEDIFF(SECOND,@b_s_time,@b_e_time) AS NVARCHAR)+ ' SECONDS')
		print('=================================')


	END TRY
	BEGIN CATCH
		PRINT('=============================================')
		PRINT('ERROR OCCURED DURING LOADING BRONZE LAYER ')
		PRINT('ERROR MESSAGE :'+ERROR_MESSAGE())
		PRINT('ERROR MESSAGE :'+ CAST ( ERROR_NUMBER() AS NVARCHAR))
		PRINT('ERROR MESSAGE :'+CAST(ERROR_STATE() AS NVARCHAR ))
		PRINT('=============================================')
	END CATCH
END