SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_invoice_details]
AS
SELECT      ci.invoice_date,
            ci.invoice_start,
            ci.invoice_end,
            ci.contractor_name,
            ci.void,
            d.*
FROM        dbo.contractor_invoice ci
JOIN        dbo.contractor_invoice_details d
ON          ci.contractor_invoice_id = d.contractor_invoice_id

GO
