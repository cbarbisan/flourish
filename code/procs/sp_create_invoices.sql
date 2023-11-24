-- Generates the invoice and invoice detail records for each contractor whose
-- invoice frequency matches the frequency passed into the proc.
-- Invoice will include eligible sessions for the date range specified.
CREATE OR ALTER PROCEDURE dbo.sp_create_invoices
    @period_start DATE,
    @period_end DATE,
    @invoice_frequency NVARCHAR(50)
AS 
BEGIN

    SET NOCOUNT ON;

    DECLARE @launch_date DATE = NULL;

    SELECT  @launch_date = COALESCE(MIN(period_start), '20231001')
    FROM    dbo.contractor_invoice;

PRINT('Launch Date = ' + CAST(@launch_date AS NVARCHAR));
    
    /*
        Notes:
            1. Complete all 3 INSERTs as a single transaction
    */
    
    -- Creates the invoice records
    INSERT INTO dbo.contractor_invoice
    SELECT  DISTINCT
            CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time' AS DATE) AS invoice_date,
            @period_start,
            @period_end,
            inv.contractor_id,
            inv.contractor_name,
            0 AS void
    FROM    dbo.v_invoice_details inv
    JOIN    dbo.contractor c
    ON      inv.contractor_id = c.contractor_id
    WHERE   inv.payment_date BETWEEN @period_start AND @period_end
    AND     c.invoice_frequency = @invoice_frequency;

    -- INSERTs all sessions that were PAID in this period, regardless of when the session occurred.
    INSERT INTO dbo.contractor_invoice_details
    SELECT  ci.contractor_invoice_id,
            ci.contractor_id,
            session_id,
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
    JOIN    dbo.contractor_invoice ci
    ON      inv.contractor_id = ci.contractor_id
    AND     ci.period_start = @period_start
    AND     ci.period_end = @period_end
    AND     ci.void = 0
    WHERE   inv.payment_date BETWEEN @period_start AND @period_end
    AND     c.invoice_frequency = @invoice_frequency;

    -- INSERTs all sessions that were PAID PRIOR to this period, but did not have a signed note at that time,
    -- and are not already in the contractor invoice details table.
    -- If these sessions are showing in v_invoice_details, we know that their note status is now
    -- compliant
    -- How do we exclude sessions prior to launch from this pull, while still getting sessions whose
    -- note status has changed? We define the launch date and ignore anything before it.
    -- Launch date should be the earliest start date in our invoice details table.
    INSERT INTO dbo.contractor_invoice_details
    SELECT  ci.contractor_invoice_id,
            ci.contractor_id,
            session_id,
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
    JOIN    dbo.contractor_invoice ci
    ON      inv.contractor_id = ci.contractor_id
    AND     ci.period_start = @period_start
    AND     ci.period_end = @period_end
    AND     ci.void = 0
    WHERE   payment_date BETWEEN @launch_date AND DATEADD(day, -1, @period_start)
    AND     NOT EXISTS (
        SELECT  1
        FROM    dbo.contractor_invoice_details
        WHERE   session_id = inv.session_id
        AND     contractor_id = inv.contractor_id
    );

END