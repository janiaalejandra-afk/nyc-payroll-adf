# NYC Payroll Data Integration Pipelines - Azure Data Factory

Udacity Data Engineering with Microsoft Azure - Project: Data Integration Pipelines for NYC Payroll Data Analytics.

## Architecture

```
Data Lake Gen2 (adlsnycpayroll-jania-s)            Azure SQL DB (db_nycpayroll)            Data Lake Gen2 / Synapse
  dirpayrollfiles/  EmpMaster.csv    --->  NYC_Payroll_EMP_MD
                    TitleMaster.csv  --->  NYC_Payroll_TITLE_MD
                    AgencyMaster.csv --->  NYC_Payroll_AGENCY_MD
                    nycpayroll_2021  --->  NYC_Payroll_Data_2021 --+
  dirhistoryfiles/  nycpayroll_2020  --->  NYC_Payroll_Data_2020 --+--> Dataflow_Summary --+--> NYC_Payroll_Summary (SQL DB)
                                                                                          +--> dirstaging/*.csv
                                                                                                 |
                                                                     Synapse serverless external table NYC_Payroll_Summary
```

## Repository content

| Folder | Content |
|---|---|
| `linkedService/` | `ls_adls_nycpayroll` (AzureBlobFS - Data Lake Gen2), `ls_sqldb_nycpayroll` (AzureSqlDatabase, Legacy version) |
| `dataset/` | DelimitedText datasets (`AzureBlobFSLocation`) for `EmpMaster.csv`, `TitleMaster.csv`, `AgencyMaster.csv`, `nycpayroll_2020.csv`, `nycpayroll_2021.csv` and the `dirstaging` folder; `AzureSqlTable` datasets for the 6 SQL DB tables |
| `dataflow/` | `df_load_*` data flows (Data Lake Gen2 -> SQL DB) and `Dataflow_Summary` (aggregation) |
| `pipeline/` | `pl_nyc_payroll` - orchestration with `ExecuteDataFlow` activities |
| `factory/` | Factory settings and the global parameter `gp_fiscalyear` (created by ADF) |
| `sql/` | DDL for Azure SQL DB, Synapse external table (CETAS-ready serverless setup) and verification queries |
| `screenshots/` | Proof of work |

## Data flows

| Data flow | Source | Transformations | Sink |
|---|---|---|---|
| `df_load_agency_md` | `AgencyMaster.csv` | - | `NYC_Payroll_AGENCY_MD` |
| `df_load_emp_md` | `EmpMaster.csv` | - | `NYC_Payroll_EMP_MD` |
| `df_load_title_md` | `TitleMaster.csv` | - | `NYC_Payroll_TITLE_MD` |
| `df_load_payroll_2020` | `dirhistoryfiles/nycpayroll_2020.csv` | Derived column: data type casting | `NYC_Payroll_Data_2020` |
| `df_load_payroll_2021` | `dirpayrollfiles/nycpayroll_2021.csv` | Derived column: data type casting | `NYC_Payroll_Data_2021` |
| `Dataflow_Summary` | SQL DB `NYC_Payroll_Data_2020` + `NYC_Payroll_Data_2021` | Select (`AgencyCode` -> `AgencyID`), Union, Filter `toInteger(FiscalYear) >= $dataflow_param_fiscalyear`, Derived column `TotalPaid = RegularGrossPaid + TotalOTPaid + TotalOtherPay`, Aggregate `sum(TotalPaid)` by `FiscalYear`, `AgencyName` | SQL DB `NYC_Payroll_Summary` (truncate table) and Data Lake `dirstaging` (clear the folder) |

## Pipeline `pl_nyc_payroll`

1. `Load Agency Master`, `Load Employee Master`, `Load Title Master` run in parallel.
2. `Load Payroll 2020` and `Load Payroll 2021` start when the three master data loads succeed.
3. `Aggregate Payroll Summary` (`Dataflow_Summary`) starts when both payroll loads succeed. Its
   `dataflow_param_fiscalyear` parameter receives the global parameter `gp_fiscalyear` (default 2020).

## Azure resources

| Resource | Name |
|---|---|
| Data Lake Gen2 storage account / container | `adlsnycpayrolljanias` / `adlsnycpayroll-jania-s` |
| Azure SQL Database | `sqlserver-nycpayroll-jania-s` / `db_nycpayroll` |
| Synapse Analytics serverless database | `udacity` |
