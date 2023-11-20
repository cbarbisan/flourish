SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Implementation note - this could be a view, which gets queried when generating invoices and invoice details
-- It would also allow us to aggregate the invoice details into the parent invoice record

CREATE OR ALTER VIEW [dbo].[v_invoice_details]
WITH SCHEMABINDING
AS
WITH SESSION_PAYMENT AS (
    SELECT      session_id,
                MIN(payment_date) AS payment_date
    FROM        dbo.payment
    GROUP BY    session_id
)
SELECT      sp.payment_date,
            c.contractor_id,
            c.contractor_name,
            s.session_id,
            FORMAT(s.session_date,'yyyy-MM-dd h:mm tt') AS session_date,
            s.[service_name],
            s.client_code,
            s.duration,
            s.attendance,
            s.note_status,
            s.fee,
            s.charged,
            s.paid,
            IIF(c.contractor_name = s.therapist_name, 'Therapist', 'Supervisor') AS service_role,
            CASE
                WHEN c.contractor_name = s.therapist_name THEN
                    CAST(COALESCE(sc.service_cut,0.7)*s.charged AS MONEY)
                ELSE
                    CAST(COALESCE(sc.supervision_cut,0.1)*s.charged AS MONEY)
            END AS contractor_amount
FROM        dbo.contractor c
JOIN        dbo.owl_session s
ON          (c.contractor_name = s.therapist_name OR c.contractor_name = s.supervisor)
JOIN        SESSION_PAYMENT sp
ON          s.session_id = sp.session_id
LEFT JOIN   dbo.service_cut_override sc
ON          c.contractor_id = sc.contractor_id
AND         s.service_name = sc.service_name
WHERE       NOT EXISTS (SELECT 1 FROM dbo.contractor_invoice_details WHERE session_id = s.session_id and contractor_id = c.contractor_id)
AND         s.note_status IN ('Signed Note', 'N/A')
GO
