# SQL-data-warehouse-project
Build a data ***warehouse*** project using SQL-server  
  
You take raw files from two systems, a CRM and an ERP, and build one data warehouse in SQL Server. At the end, the data is clean and ready for analysis.
******
### Project over:
In this project we build a **medallion architecture**  
It contains three layers **Bronze**,**Silver**,**Gold** Each perform there role to generate structure data from the raw data  
For this project we use **csv** files as our source  
# 🏗️ Data Flow
<img width="100%" alt="Screenshot 2026-10-22 124124" src="https://github.com/user-attachments/assets/97079ee0-a306-43e3-9149-264806ac9d41" />

### Layers:

1. **Bronze Layer** we store data same as the sore system has. There will be no transformation in the **Bronze layer**  
2. **Silver Layer** we do all the transformation ex: data cleaning , normalization , errors , null values etc..
3. **Gold Layer** we implement all the business logic and create a structured schema like star , snowflake  
## Data Integration 
<div align ="center">
<img width="50%" aline="center" alt="image" src="https://github.com/user-attachments/assets/553bc048-c84f-41b5-b836-1a6adf3dbb17" />
</div>

### In this project we :

1. Design the architecture: a modern data warehouse with three layers, bronze, silver and gold.
2. Build the ETL pipelines: load the source files and move the data through the layers.
3. Model the data: facts and dimensions, ready for reports.
4. Analyze it: answer business questions with SQL.


