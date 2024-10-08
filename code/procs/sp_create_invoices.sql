-- Generates the invoice and invoice detail records for each contractor whose
-- invoice frequency matches the frequency passed into the proc.
--
-- Invoice will include eligible sessions for the date range specified,
-- along with sessions that were manually deemed eligible through inclusion
-- in the non_invoiced_session table.
--
-- We ONLY show amount to clinic when the contractor was the therapist for
-- the session. If we show it under both, then we risk double-counting the
-- amount to clinic, because it could show up on an invoice twice, once
-- for the session's therapist and once for the session's supervisor.
CREATE OR ALTER PROCEDURE dbo.sp_create_invoices
    @invoice_start DATE,
    @invoice_end DATE,
    @invoice_frequency NVARCHAR(50)
AS 
BEGIN

    SET NOCOUNT ON;

    DECLARE @launch_date DATE;

    SELECT @launch_date = launch_date
    FROM app_launch
    WHERE invoice_frequency = @invoice_frequency;

    -- A session is eligible to be invoiced for by the contractor IF:
    --      1. The note is completed
    --      2. A payment has been received for the session
    --      3. The contractor who is invoicing the session is on the same invoice
    --      frequency as specified by the parameter @invoice_frequency
    --      4. The session has not been invoiced previously
    
    -- Let's start by gathering the details of eligible sessions into
    -- a temp table
    
    -- Add to the invoice details, manually specified sessions that occurred before launch date but are not in our 
    -- invoice details table
    -- When would we manually specify a session?:
    --      1. It was paid by the client before the launch date, but not invoiced by the contractor due to note status
    --      2. It was paid by the client before the launch date, but not invoiced by the contractor unintentionally    
    
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
    
    -- Either the invoice record and all of the invoice detail records should be created, or
    -- nothing should be created. Use a transaction to make sure it's either/or
    BEGIN TRANSACTION

        BEGIN TRY
        
                -- Use the eligible session details to determine which invoices need to be generated
                INSERT INTO dbo.contractor_invoice
                SELECT  DISTINCT
                        CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time' AS DATE) AS invoice_date,
                        @invoice_start,
                        @invoice_end,
                        contractor_id,
                        contractor_name,
                        0 AS void
                FROM    #invoice_details;

                -- Once we get here, all of the invoice details in the temp table can just
                -- be inserted into the contractor_invoice_details table in 1 step.
                -- There shouldn't be any need for a second INSERT query.

                INSERT INTO dbo.contractor_invoice_details
                SELECT  ci.contractor_invoice_id,
                        d.contractor_id,
                        d.session_id,
                        d.session_date,
                        d.[service_name],
                        d.client_code,
                        d.duration,
                        d.attendance,
                        d.fee,
                        d.charged,
                        d.paid,
                        d.contractor_role,
                        d.contractor_amount
                FROM    #invoice_details d
                JOIN    contractor_invoice ci
                ON      d.contractor_id = ci.contractor_id
                AND     ci.invoice_start = @invoice_start
                AND     ci.invoice_end = @invoice_end
                AND     ci.void = 0;

        END TRY
        BEGIN CATCH

                SELECT   ERROR_NUMBER() AS ErrorNumber  
                        ,ERROR_SEVERITY() AS ErrorSeverity  
                        ,ERROR_STATE() AS ErrorState  
                        ,ERROR_PROCEDURE() AS ErrorProcedure  
                        ,ERROR_LINE() AS ErrorLine  
                        ,ERROR_MESSAGE() AS ErrorMessage;  
  
                IF @@TRANCOUNT > 0
                        ROLLBACK TRANSACTION;

        END CATCH

        IF @@TRANCOUNT > 0
                COMMIT TRANSACTION;

END