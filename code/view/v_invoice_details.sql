-- Remember that an invoice is a contractor-centric (payee) view
-- Need to turn this into a stored proc

-- Need to look at Flourish spreadsheet to get data requirements

-- What inputs are required from the user?
--      Therapist
--      Year/Month

-- Might want to maintain a table of billable attendance statuses to join into this query
-- Best to not hard-code those status values in the WHERE clause
-- Ditto for note status values, if the plan is to do a full refresh of session data every month, to get updates to the note status field

-- What fields are calculated specifically for the therapist?
--      Amount to Contractor
--      Contractor Role

-- What fields are inputs to the calculated fields?
--      For Contractor Role:
--          payee
--          therapist name
--          supervisor
--      For Contractor Amount:
--          payee
--          Contractor Role
--          service_name
--          charged
--          onsite_cut
--          session_date
--          offsite_cut
--          supervisor_cut

-- Implementation note - this could be a view, which gets queried when generating invoices and invoice details
-- That would allow us to pass in contractor role to the UDF which calculates amounts
-- It would also allow us to aggregate the invoice details into the parent invoice record

CREATE OR ALTER VIEW dbo.v_invoice_details
WITH SCHEMABINDING
AS
SELECT      FORMAT(ts.session_date,'yyyy-MM-dd h:mm tt') AS [Date],
            ts.[service_name] AS [Service],
            ts.client_code AS [Client],
            ts.duration AS Duration,
            ts.therapist_name,
            ts.supervisor,
            ts.attendance AS Attendance,
            ts.fee AS Fee,
            ts.charged AS Charged,
            ts.paid AS Paid,
            CASE
                WHEN t.therapist_name = ts.therapist_name AND ts.supervisor IS NULL THEN 'Therapist'
                WHEN t.therapist_name = ts.therapist_name AND ts.supervisor IS NOT NULL THEN 'Supervised Therapist'
                WHEN t.therapist_name <> ts.therapist_name AND t.therapist_name = ts.supervisor THEN 'Supervisor'
                ELSE NULL
            END AS ContractorRole,
            CASE
                WHEN ts.[service_name] IN ('Occupational Therapy', 'Occupational Therapy - In Person') THEN CAST(ts.charged * t.onsite_cut AS MONEY)
                WHEN (ts.[service_name] = 'Virtual Occupational Therapy' AND DATENAME(WEEKDAY, ts.session_date) = 'Monday') THEN CAST(ts.charged * t.onsite_cut AS MONEY)
                WHEN (ts.[service_name] = 'Virtual Occupational Therapy' AND DATENAME(WEEKDAY, ts.session_date) <> 'Monday') THEN CAST(ts.charged * t.offsite_cut AS MONEY)
            END AS [Amount to Contractor]
FROM        dbo.therapist t
JOIN        dbo.therapist_session ts
ON          (t.therapist_name = ts.therapist_name OR t.therapist_name = ts.supervisor)
WHERE       CAST(ts.session_date AS DATE) < '20231001'
AND         ts.attendance NOT IN ('Cancelled', 'Non Billable')
--AND         (ts.therapist_name = @payee OR ts.supervisor = @payee)
AND         EXISTS (SELECT 1 FROM dbo.therapist_payment WHERE session_id = ts.session_id);