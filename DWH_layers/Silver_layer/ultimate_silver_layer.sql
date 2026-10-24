--
/*
This contails all the code 

--it automatically truncate all the existing data from silver tabel 
-- loads all the clean and transformed data from the bronze to silver
-- all the file's have original name they have in bronze layer

""IMPORTANT "" --> Make sure that you bronze layer is already exist and had all the data 

*/
--exec silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver  AS 
BEGIN 
	DECLARE @start_time DATETIME ,@end_time DATETIME ,@batch_start DATETIME , @batch_end DATETIME
	BEGIN TRY 

		set @batch_start =GETDATE()
		print ('====================================')
		print ('        Loading Silver Layer        ')
		print ('====================================')
		print (' ')
		print ('----------------------------------------')
		print('Loading "silver.crm_cust_info" Table.... ')
		print ('----------------------------------------')
		print (' ')
		set @start_time=GETDATE()
		print('>> Trucating Table "silver.crm_cust_info"  ') 
		TRUNCATE TABLE silver.crm_cust_info
		print('>> Inserting "silver.crm_cust_info"  ') 
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		select  
		cst_id,
		cst_key,
		trim(cst_firstname) AS cst_firstname,
		trim(cst_lastname) AS cst_lastname,
		CASE
			WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Maried'
			WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
			ELSE'n/a'
		END AS cst_marital_status,
		CASE
			WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Male'
			WHEN UPPER(TRIM(cst_marital_status))='F' THEN 'Femail'
			ELSE'n/a'
		END AS cst_gndr,
		cst_create_date
		from 
		(SELECT 
		*,
		row_number() over (partition by cst_id order by cst_create_date desc ) as val
		FROM [bronze].[crm_cust_info]
		where cst_id is not null ) as temp
		where val =1
		set @end_time=GETDATE()

		PRINT ('>>Time "silver.crm_cust_info" :: '+cast(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR )+'s')
		print('')
		print ('----------------------------------------')
		print('Loading "silver.crm_prd_info"  Table.... ')
		print ('----------------------------------------')
		print('')

		set @start_time=GETDATE()
		print('>> Trucating Table "silver.crm_prd_info"  ') 
		TRUNCATE TABLE [silver].[crm_prd_info]
		print('>> Inserting "silver.crm_prd_info"  ') 
		INSERT INTO [silver].[crm_prd_info](
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		select 
		prd_id,
		SUBSTRING(prd_key,1,5) as cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_nm,
		CASE 
			WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
			WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
			WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
			WHEN UPPER(TRIM(prd_line))='O' THEN 'Other Sales'
			ELSE 'n/a'
		END AS prd_line,
		prd_start_dt,
		LEAD(prd_start_dt) over(partition by prd_nm order by prd_start_dt) as prd_end_dt
		from bronze.crm_prd_info
		WHERE prd_end_dt<prd_start_dt

		set @end_time=GETDATE()
		print ('>>Time "silver.crm_prd_info" :: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+'s')


		print('')
		print ('----------------------------------------')
		print('Loading "silver.crm_sales_details"  Table.... ')
		print ('----------------------------------------')
		print('')

		set @start_time=GETDATE()
		print('>> Trucating Table "silver.crm_sales_details"  ') 
		TRUNCATE TABLE silver.crm_sales_details
		print('>> Inserting "silver.crm_sales_details"  ') 
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt<0 or sls_order_dt is null or len(sls_order_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
			END  AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt<0 or sls_ship_dt is null or len(sls_ship_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
			END AS  sls_ship_dt,
			CASE 
				WHEN sls_due_dt<0 or sls_due_dt is null or len(sls_due_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales is null or sls_sales!=sls_quantity*sls_price or sls_sales<=0 THEN ABS(sls_quantity*ISNULL(sls_price,0))
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price is null  or sls_price<=0 THEN ABS(ISNULL(sls_sales,0)/sls_quantity)
				ELSE sls_price
			END AS sls_price
		from bronze.crm_sales_details

		set @end_time=GETDATE()

		print ('>>Time "silver.crm_sales_details" :: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+'s')



		print('')
		print ('----------------------------------------')
		print('Loading "silver.erp_cust_az12" Table.... ')
		print ('----------------------------------------')
		print('')

		set @start_time=GETDATE()

		print('>> Trucating Table "silver.erp_cust_az12"  ') 

		TRUNCATE TABLE silver.erp_cust_az12

		print('>> Inserting "silver.erp_cust_az12"  ')

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		select
			CASE 
				WHEN cid LIKE '%NAS%' THEN SUBSTRING(cid,4,len(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE 
				WHEN upper(trim(gen)) in ('F','FEMALE') THEN 'Female'
				WHEN upper(trim(gen)) in ('M','MALE') THEN 'Male'
				ELSE 'n/a'
			END gen
		from [bronze].[erp_cust_az12]

		set @end_time=GETDATE()

		print ('>>Time "silver.erp_cust_az12" :: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+'s')


		print('')
		print ('----------------------------------------')
		print('Loading "silver.erp_loc_a101" Table.... ')
		print ('----------------------------------------')
		print('')

		set @start_time=GETDATE()

		print('>> Trucating Table "silver.erp_loc_a101"  ') 

		TRUNCATE TABLE silver.erp_cust_az12

		print('>> Inserting "silver.erp_loc_a101"  ')
 
		INSERT INTO silver.erp_loc_a101(
		cid,
		cntry
		)
		select
		REPLACE(cid,'-','') as cid,
		CASE 
			WHEN UPPER(TRIM(cntry))= 'US' THEN 'United State'
			WHEN TRIM(cntry)=''  OR cntry is null THEN 'n/a'
			ELSE cntry
		END cntry
		from [bronze].[erp_loc_a101]

		set @end_time=GETDATE()

		print ('>>Time "silver.erp_loc_a101" :: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+'s')

		print('')
		print ('----------------------------------------')
		print('Loading "silver.erp_px_cat_g1v2" Table.... ')
		print ('----------------------------------------')
		print('')

		set @start_time=GETDATE()

		print('>> Trucating Table "silver.erp_px_cat_g1v2"  ') 

		TRUNCATE TABLE silver.erp_px_cat_g1v2

		print('>> Inserting "silver.erp_px_cat_g1v2"  ')

		INSERT INTO  silver.erp_px_cat_g1v2(
		id,
		cat,
		subcat,
		maintenance
		)
		select *
		from [bronze].[erp_px_cat_g1v2]

		set @end_time=GETDATE()
 
		 print ('>>Time "silver.erp_loc_a101" :: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+'s')

		 SET @batch_end= GETDATE()
		 PRINT('')
		 PRINT('')
		 print ('::: TOTAL TIME CONSUMED  ::: '+CAST(DATEDIFF(SECOND,@batch_start,@batch_end) AS NVARCHAR)+'s')
	END TRY 
	BEGIN CATCH
		PRINT('----------------------------------------------')
		PRINT('ERROR OCCURRED DURING LOADING DATA INTO SILVER')
		PRINT('Error Message '+ERROR_MESSAGE())
		PRINT('Error Number '+cast(ERROR_NUMBER() AS VARCHAR))
		PRINT('Error Status '+ cast(ERROR_STATE() AS VARCHAR))
		PRINT('----------------------------------------------')
	END CATCH
END