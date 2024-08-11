SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- There was too much logic in this view initially, which was confusing when troubleshooting issues
--
-- Refactored so that the view is only responsible for joining data together and formatting.
--
-- No filtering or aggregation. That will happen when we populate the invoice.
--
-- Calculation of amounts is in this view

CREATE OR ALTER VIEW [dbo].[v_session_details]
AS
-- There can be more than 1 payment for a session, but it's very rare.
-- In the cases where there are > 1 payment, the first payment has
-- always been enough to cover the charge.
-- Our selection criteria when we generated the invoice will be to include 
-- the session on the invoice once the first payment is received. That date 
-- will be considered the payment date. If there has been no payment for the 
-- session, the payment date will be null in this view and the session will
-- not be included in the invoice until payment is received
--
-- The contractor table is joined into this query 2 times:
-- 1. Once for the contractor who was the therapist for the session
-- 2. Once for the contractor who was the supervisor for the session
--
-- The notion of who the contractor is only exists in the context of an invoice.
-- A contractor can be either the therapist OR the supervisor for a session, but
-- not both.
--
-- Not everyone in the contractor table is necessarily a contractor, some
-- are employees. So the nomenclature could be better. Employees will be 
-- filtered out of the invoice generation process however, because their
-- invoice frequency will be set to "Never"

WITH SESSION_PAYMENT AS (
    SELECT      session_id,
                MIN(payment_date) AS payment_date
    FROM        dbo.s_payment
    GROUP BY    session_id
)
SELECT      sp.payment_date,
            t.contractor_id AS therapist_id,
            t.contractor_name AS therapist_name,
            s.contractor_id AS supervisor_id,
            s.contractor_name AS supervisor_name,
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
            CAST(ROUND((COALESCE(sc.service_cut,0.7)*sess.charged),2) AS MONEY) AS therapist_amount,
            CAST(ROUND((COALESCE(sc.supervision_cut,0.0)*sess.charged),2) AS MONEY) AS supervisor_amount,
            sess.charged - (CAST(ROUND((COALESCE(sc.service_cut,0.7)*sess.charged),2) AS MONEY)) - (CAST(ROUND((COALESCE(sc.supervision_cut,0.0)*sess.charged),2) AS MONEY)) AS clinic_amount
FROM        dbo.s_session sess
LEFT JOIN   dbo.contractor t
ON          sess.therapist_name = t.contractor_name
LEFT JOIN   dbo.contractor s
ON          sess.supervisor = s.contractor_name
LEFT JOIN   SESSION_PAYMENT sp
ON          sess.session_id = sp.session_id
LEFT JOIN   dbo.service_cut_override sc
ON          t.contractor_id = sc.therapist_id
AND         sess.service_name = sc.service_name
AND         ISNULL(s.contractor_id,0) = ISNULL(sc.supervisor_id,0)

GO
