CREATE OR ALTER PROCEDURE dbo.sp_add_new_contractors
AS 
BEGIN

    SET NOCOUNT ON;
    
    WITH CONTRACTOR_LIST AS (
        SELECT      therapist_name AS contractor_name,
                    MIN(CAST(session_date AS DATE)) AS start_date
        FROM        dbo.s_session
        GROUP BY    therapist_name
        UNION
        SELECT      supervisor AS contractor_name,
                    MIN(CAST(session_date AS DATE)) AS start_date
        FROM        dbo.s_session
        WHERE       supervisor IS NOT NULL
        GROUP BY    supervisor
    )
    INSERT INTO dbo.contractor
    SELECT      contractor_name,
                'TBD' AS department,
                'Monthly' AS invoice_frequency,
                'TBD' AS email,
                MIN(start_date) AS start_date
    FROM        CONTRACTOR_LIST cl
    WHERE       NOT EXISTS (SELECT 1 FROM dbo.contractor WHERE contractor_name = cl.contractor_name)
    GROUP BY    contractor_name;

    PRINT('*** Please manually update the department, invoice_frequency and email for any new contractors added, and create any service cut overrides. ***')

END
