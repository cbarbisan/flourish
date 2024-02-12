-- Generates the invoice and invoice detail records for each contractor whose
-- invoice frequency matches the frequency passed into the proc.
--
-- Invoice will include eligible sessions for the date range specified,
-- along with sessions that were manually deemed eligible by inclusion in
-- the non_invoiced_session table.
--
-- We ONLY show amount to clinic when the contractor was the therapist for
-- the session. If we show it under both, then we risk double-counting the
-- amount to clinic, because it will show up on an invoice twice, once
-- for the therapist and once for the supervisor.
CREATE OR ALTER PROCEDURE dbo.sp_create_invoices
    @invoice_start DATE,
    @invoice_end DATE,
    @invoice_frequency NVARCHAR(50)
AS 
BEGIN

    SET NOCOUNT ON;

    DECLARE @launch_date DATE = '20231101';

    -- A session is eligible to be invoiced for by the contractor IF:
    --      1. The note is completed
    --      2. A payment has been received for the session
    --      3. The contractor who is invoicing the session is on the same invoice
    --      frequency as specified by the parameter @invoice_frequency
    --      4. The session has not been invoiced previously
    
    -- Let's start by gathering the details of eligible sessions into
    -- a temp table
    
    -- Include in the invoice details, manually specified sessions that occurred before launch date but are not in our 
    -- invoice details table
    -- When would we manually specify a session?:
    --      1. It was paid by the client before the launch date, but not invoiced by the contractor due to note status
    --      2. It was paid by the client before the launch date, but not invoiced by the contractor unintentionally    
    
    -- TODO: Should launch date be different depending on invoice frequency? I think so. Perhaps a config table to
    -- store the different launch dates.
    
    SELECT  c.contractor_id,
            c.contractor_name,
            c.invoice_frequency,
            sess.*,
            IIF (c.contractor_id = sess.therapist_id, 'Therapist', 'Supervisor') AS contractor_role,
            IIF (c.contractor_id = sess.therapist_id, sess.therapist_amount, sess.supervisor_amount) AS contractor_amount,
            IIF (c.contractor_id = sess.therapist_id, sess.charged - (sess.therapist_amount + sess.supervisor_amount), NULL) AS amount_to_clinic
    INTO    #invoice_details
    FROM    dbo.contractor c
    JOIN    dbo.v_session_details sess
    ON      (c.contractor_id = sess.therapist_id OR c.contractor_id = sess.supervisor_id)
    WHERE   sess.note_status IN ('Signed Note', 'N/A')
    AND     c.invoice_frequency = @invoice_frequency
    AND     NOT EXISTS (SELECT 1 FROM dbo.v_invoice_details WHERE session_id = sess.session_id AND contractor_id = c.contractor_id AND void = 0)
    AND     (
                (sess.payment_date BETWEEN @launch_date AND @invoice_end)
                OR
                (
                        sess.payment_date < @launch_date
                        AND
                        EXISTS (SELECT 1 FROM dbo.non_invoiced_session where session_id = sess.session_id AND contractor_id = c.contractor_id)
                )
    );
    
    /*
        Notes:
            1. Complete both INSERTs as a single transaction
    */
    
    -- Use the eligible session details to determine which invoices need to be generated
    INSERT INTO dbo.contractor_invoice
    SELECT  DISTINCT
            CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time' AS DATE) AS invoice_date,
            @invoice_start,
            @invoice_end,
            inv.contractor_id,
            inv.contractor_name,
            0 AS void
    FROM    #invoice_details inv;

    -- Once we get here, all of the invoice details in the temp table can just
    -- be inserted into the contractor_invoice_details table in 1 step.
    -- There shouldn't be any need for a second INSERT query.

    -- INSERTs all sessions that were PAID in this period, regardless of when the session occurred.
    -- However the session must have a signed note and not have been invoiced before.
    -- Joining the invoice record ensures that we are only inserting the invoice details
    -- we need for the invoices we created above.
    --
    -- TODO: A supervised session should generate 2 records of invoice details, not just 1.
    --       1 record for the therapist's invoice and 1 record for the supervisor's invoice.
    --       Will need logic here to fan those session records into 2 invoice detail records.
    INSERT INTO dbo.contractor_invoice_details
    SELECT  ci.contractor_invoice_id,
            ci.contractor_id,
            inv.session_id,
            inv.session_date,
            inv.[service_name],
            inv.client_code,
            inv.duration,
            inv.attendance,
            inv.fee,
            inv.charged,
            inv.paid,
            inv.contractor_role,
            inv.contractor_amount
    FROM    #invoice_details inv;

END