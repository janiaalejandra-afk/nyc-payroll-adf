-- =============================================================================
-- NYC Payroll - Azure SQL Database (db_nycpayroll)
-- Run in: Azure portal > SQL database > Query editor (SQL authentication)
-- Creates the master data, payroll transaction and payroll summary tables.
-- =============================================================================

DROP TABLE IF EXISTS [dbo].[NYC_Payroll_EMP_MD];
CREATE TABLE [dbo].[NYC_Payroll_EMP_MD](
    [EmployeeID] varchar(10) NULL,
    [LastName] varchar(20) NULL,
    [FirstName] varchar(20) NULL
);

DROP TABLE IF EXISTS [dbo].[NYC_Payroll_TITLE_MD];
CREATE TABLE [dbo].[NYC_Payroll_TITLE_MD](
    [TitleCode] varchar(10) NULL,
    [TitleDescription] varchar(100) NULL
);

DROP TABLE IF EXISTS [dbo].[NYC_Payroll_AGENCY_MD];
CREATE TABLE [dbo].[NYC_Payroll_AGENCY_MD](
    [AgencyID] varchar(10) NULL,
    [AgencyName] varchar(50) NULL
);

DROP TABLE IF EXISTS [dbo].[NYC_Payroll_Data_2020];
CREATE TABLE [dbo].[NYC_Payroll_Data_2020](
    [FiscalYear] int NULL,
    [PayrollNumber] int NULL,
    [AgencyID] varchar(10) NULL,
    [AgencyName] varchar(50) NULL,
    [EmployeeID] varchar(10) NULL,
    [LastName] varchar(20) NULL,
    [FirstName] varchar(20) NULL,
    [AgencyStartDate] date NULL,
    [WorkLocationBorough] varchar(50) NULL,
    [TitleCode] varchar(10) NULL,
    [TitleDescription] varchar(100) NULL,
    [LeaveStatusasofJune30] varchar(50) NULL,
    [BaseSalary] float NULL,
    [PayBasis] varchar(50) NULL,
    [RegularHours] float NULL,
    [RegularGrossPaid] float NULL,
    [OTHours] float NULL,
    [TotalOTPaid] float NULL,
    [TotalOtherPay] float NULL
);

DROP TABLE IF EXISTS [dbo].[NYC_Payroll_Data_2021];
CREATE TABLE [dbo].[NYC_Payroll_Data_2021](
    [FiscalYear] int NULL,
    [PayrollNumber] int NULL,
    [AgencyCode] varchar(10) NULL,
    [AgencyName] varchar(50) NULL,
    [EmployeeID] varchar(10) NULL,
    [LastName] varchar(20) NULL,
    [FirstName] varchar(20) NULL,
    [AgencyStartDate] date NULL,
    [WorkLocationBorough] varchar(50) NULL,
    [TitleCode] varchar(10) NULL,
    [TitleDescription] varchar(100) NULL,
    [LeaveStatusasofJune30] varchar(50) NULL,
    [BaseSalary] float NULL,
    [PayBasis] varchar(50) NULL,
    [RegularHours] float NULL,
    [RegularGrossPaid] float NULL,
    [OTHours] float NULL,
    [TotalOTPaid] float NULL,
    [TotalOtherPay] float NULL
);

DROP TABLE IF EXISTS [dbo].[NYC_Payroll_Summary];
CREATE TABLE [dbo].[NYC_Payroll_Summary](
    [FiscalYear] int NULL,
    [AgencyName] varchar(50) NULL,
    [TotalPaid] float NULL
);


-- Verify: the 6 tables must be listed
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'NYC_Payroll%'
ORDER BY TABLE_NAME;
