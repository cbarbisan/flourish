SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- What inputs are required from the user?
--      Therapist
--      Year/Month

-- Might want to maintain a table of billable attendance statuses to join into this query
-- Best to not hard-code those status values in the WHERE clause
-- Ditto for note status values, if the plan is to do a full refresh of session data every month, to get updates to the note status field

-- Implementation note - this could be a view, which gets queried when generating invoices and invoice details
-- That would allow us to pass in contractor role to the UDF which calculates amounts
-- It would also allow us to aggregate the invoice details into the parent invoice record

CREATE OR ALTER VIEW [dbo].[v_invoice_details]
WITH SCHEMABINDING
AS
SELECT      c.contractor_id,
            s.session_id,
            FORMAT(s.session_date,'yyyy-MM-dd h:mm tt') AS session_date,
            s.[service_name],
            s.client_code,
            s.duration,
            s.attendance,
            s.fee,
            s.charged,
            s.paid,
            IIF(c.contractor_name = s.therapist_name, 'Therapist', 'Supervisor') AS service_role,
            CASE
                WHEN c.contractor_name = s.therapist_name THEN
                    ROUND(sc.service_cut*s.charged, 2)
                ELSE
                    ROUND(sc.supervision_cut*s.charged, 2)
            END AS contractor_amount
FROM        dbo.contractor c
JOIN        dbo.owl_session s
ON          (c.contractor_name = s.therapist_name OR c.contractor_name = s.supervisor)
JOIN        dbo.contractor_service_cut sc
ON          c.contractor_id = sc.contractor_id
AND         s.service_name = sc.service_name
WHERE       s.attendance NOT IN ('Cancelled', 'Non Billable')
AND         s.note_status IN ('Signed Note', 'N/A')
AND         EXISTS (SELECT 1 FROM dbo.payment WHERE session_id = s.session_id)
AND         NOT EXISTS (SELECT 1 FROM dbo.contractor_invoice_tracking WHERE session_id = s.session_id and contractor_name = s.therapist_name and invoiced = 1);
GO
