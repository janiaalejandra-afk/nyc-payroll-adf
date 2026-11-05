-- =============================================================================
-- NYC Payroll - Azure Synapse Analytics, built-in serverless SQL pool
-- Run in: Synapse Studio > Develop > + SQL script > Connect to: Built-in
-- =============================================================================

-- STEP 1 - with "Use database" = master, run ONLY this statement:
-- CREATE DATABASE udacity;

-- STEP 2 - refresh the database list, select "Use database" = udacity
--          and run the rest of this script.
--   Replace <MASTER_KEY_PASSWORD> with a strong password (e.g. Upper+lower+digit+symbol, 12+ chars)
--   Replace <SAS_TOKEN> with the SAS token of storage account adlsnycpayrolljanias
--   (Read + List permissions, WITHOUT the leading "?").

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<MASTER_KEY_PASSWORD>';
GO

IF NOT EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'cred_adls_nycpayroll')
    CREATE DATABASE SCOPED CREDENTIAL [cred_adls_nycpayroll]
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
         SECRET = '<SAS_TOKEN>';
GO

-- Data source that points to the dirstaging directory written by Dataflow_Summary
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'ds_adlsnycpayrolljanias_dirstaging')
    CREATE EXTERNAL DATA SOURCE [ds_adlsnycpayrolljanias_dirstaging]
    WITH (
        LOCATION = 'https://adlsnycpayrolljanias.blob.core.windows.net/adlsnycpayroll-jania-s/dirstaging',
        CREDENTIAL = [cred_adls_nycpayroll]
    );
GO

-- Comma delimited files; the data flow writes a header row, so data starts on row 2
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat')
    CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat]
    WITH (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS (
            FIELD_TERMINATOR = ',',
            STRING_DELIMITER = '"',
            FIRST_ROW = 2,
            USE_TYPE_DEFAULT = FALSE
        )
    );
GO

IF OBJECT_ID('dbo.NYC_Payroll_Summary') IS NOT NULL
    DROP EXTERNAL TABLE [dbo].[NYC_Payroll_Summary];
GO

CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_Summary](
    [FiscalYear] int NULL,
    [AgencyName] varchar(50) NULL,
    [TotalPaid] float NULL
)
WITH (
    LOCATION = '/',
    DATA_SOURCE = [ds_adlsnycpayrolljanias_dirstaging],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
);
GO

-- After the pipeline run, this returns the payroll summary written to dirstaging
SELECT TOP 100 * FROM [dbo].[NYC_Payroll_Summary] ORDER BY FiscalYear, TotalPaid DESC;
