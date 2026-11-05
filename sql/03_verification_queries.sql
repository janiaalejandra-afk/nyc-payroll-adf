-- =============================================================================
-- NYC Payroll - verification queries (run after the pipeline completes)
-- =============================================================================

-- ---------- Azure SQL Database (db_nycpayroll) - Query editor ----------
SELECT 'NYC_Payroll_AGENCY_MD' AS table_name, COUNT(*) AS row_count FROM dbo.NYC_Payroll_AGENCY_MD
UNION ALL SELECT 'NYC_Payroll_EMP_MD', COUNT(*) FROM dbo.NYC_Payroll_EMP_MD
UNION ALL SELECT 'NYC_Payroll_TITLE_MD', COUNT(*) FROM dbo.NYC_Payroll_TITLE_MD
UNION ALL SELECT 'NYC_Payroll_Data_2020', COUNT(*) FROM dbo.NYC_Payroll_Data_2020
UNION ALL SELECT 'NYC_Payroll_Data_2021', COUNT(*) FROM dbo.NYC_Payroll_Data_2021
UNION ALL SELECT 'NYC_Payroll_Summary', COUNT(*) FROM dbo.NYC_Payroll_Summary;

-- Summary table (destination of Dataflow_Summary)
SELECT TOP 100 FiscalYear, AgencyName, TotalPaid
FROM dbo.NYC_Payroll_Summary
ORDER BY FiscalYear, TotalPaid DESC;

-- Data quality: typed columns should not be NULL after the load
SELECT FiscalYear,
       SUM(CASE WHEN AgencyStartDate IS NULL THEN 1 ELSE 0 END) AS null_start_dates,
       SUM(CASE WHEN RegularGrossPaid IS NULL THEN 1 ELSE 0 END) AS null_regular_gross_paid,
       COUNT(*) AS total_rows
FROM dbo.NYC_Payroll_Data_2021
GROUP BY FiscalYear;

-- ---------- Synapse serverless SQL pool (database: udacity) ----------
-- SELECT TOP 100 * FROM dbo.NYC_Payroll_Summary ORDER BY FiscalYear, TotalPaid DESC;
