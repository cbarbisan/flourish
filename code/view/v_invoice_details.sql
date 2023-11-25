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
            sess.session_id,
            FORMAT(sess.session_date,'yyyy-MM-dd h:mm tt') AS session_date,
            sess.[service_name],
            sess.client_code,
            sess.duration,
            sess.attendance,
            sess.note_status,
            sess.fee,
            sess.charged,
            sess.paid,
            IIF(c.contractor_id = t.contractor_id, 'Therapist', 'Supervisor') AS service_role,
            CASE
                WHEN c.contractor_name = sess.therapist_name THEN
                    CAST(ROUND((COALESCE(sc.service_cut,0.7)*sess.charged),2) AS MONEY)
                ELSE
                    CAST(ROUND((COALESCE(sc.supervision_cut,0.1)*sess.charged),2) AS MONEY)
            END AS contractor_amount
FROM        dbo.contractor c
JOIN        dbo.owl_session sess
ON          (c.contractor_name = sess.therapist_name OR c.contractor_name = sess.supervisor)
LEFT JOIN   dbo.contractor t
ON          sess.therapist_name = t.contractor_name
LEFT JOIN   dbo.contractor s
ON          sess.supervisor = s.contractor_name
JOIN        SESSION_PAYMENT sp
ON          sess.session_id = sp.session_id
LEFT JOIN   dbo.service_cut_override sc
ON          t.contractor_id = sc.therapist_id
AND         sess.service_name = sc.service_name
AND         ISNULL(s.contractor_id,0) = ISNULL(sc.supervisor_id,0)
WHERE       NOT EXISTS (SELECT 1 FROM dbo.contractor_invoice_details WHERE session_id = sess.session_id and contractor_id = c.contractor_id)
AND         (sess.note_status IN ('Signed Note', 'N/A') OR c.contractor_id = s.contractor_id)
GO
