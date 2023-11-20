CREATE OR ALTER PROCEDURE dbo.sp_add_new_contractors
AS 
BEGIN

    SET NOCOUNT ON;
    
    WITH CONTRACTOR_LIST AS (
        SELECT  DISTINCT therapist_name AS contractor_name
        FROM    dbo.owl_session
        UNION
        SELECT  DISTINCT supervisor AS contractor_name
        FROM    dbo.owl_session
        WHERE   supervisor IS NOT NULL
    )
    INSERT INTO dbo.contractor
    SELECT  contractor_name,
            'TBD' AS department,
            'Monthly' AS invoice_frequency,
            1 AS active
    FROM    CONTRACTOR_LIST cl
    WHERE   NOT EXISTS (SELECT 1 FROM dbo.contractor WHERE contractor_name = cl.contractor_name);

    PRINT('*** Please manually update the department for any new contractors added, and create the service cuts. ***')

END