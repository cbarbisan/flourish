-- Generates the invoice and invoice detail records for each contractor whose
-- invoice frequency matches the frequency passed into the proc.
-- Invoice will include eligible sessions for the date range specified.
CREATE OR ALTER PROCEDURE dbo.sp_create_invoices
    @start_date DATE,
    @end_date DATE,
    @invoice_frequency NVARCHAR(50)
AS 
BEGIN

    SET NOCOUNT ON;

    DECLARE @launch_date DATE = '20231201';
    
    /*
        Notes:
            1. Generate contractor invoice id
            2. Exclude sessions prior to launch.
            3. We may have to manually fix some invoices the first month, to include sessions that are excluded by note 2.
    */
    
    -- INSERTs all sessions that were paid this month, regardless of when the session occurred.
    INSERT INTO dbo.contractor_invoice_details
    SELECT  session_id,
            session_date,
            [service_name],
            client_code,
            duration,
            attendance,
            fee,
            charged,
            paid,
            service_role,
            contractor_amount
    FROM    dbo.v_invoice_details inv
    JOIN    dbo.contractor c
    ON      inv.contractor_id = c.contractor_id
    WHERE   payment_date BETWEEN @start_date AND @end_date
    AND     c.invoice_frequency = @invoice_frequency;

    -- INSERTs all sessions that were paid previously, but did not have a signed note, and are not already
    -- in the contractor invoice details table.
    -- If these sessions are showing in v_invoice_details, we know that their note status is now
    -- compliant
    -- How do we exclude sessions prior to launch from this pull, while still getting sessions whose
    -- note status has changed? We define the launch date and ignore anything before it.
    INSERT INTO dbo.contractor_invoice_details
    SELECT  session_id,
            session_date,
            [service_name],
            client_code,
            duration,
            attendance,
            fee,
            charged,
            paid,
            service_role,
            contractor_amount
    FROM    v_invoice_details inv
    WHERE   payment_date BETWEEN @launch_date AND DATEADD(day, -1, @start_date)
    AND     NOT EXISTS (
        SELECT  1
        FROM    dbo.contractor_invoice_details
        WHERE   session_id = inv.session_id
        AND     contractor_id = inv.contractor_id
    );

END