SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contractor_invoice] (
    [contractor_invoice_id]         INT IDENTITY(1, 1) NOT NULL,
    [invoice_date]        			DATE           NOT NULL,
    [invoice_start]                 DATE           NOT NULL,
    [invoice_end]                   DATE           NOT NULL,
	[contractor_id]                 INT            NOT NULL,
    [contractor_name]				NVARCHAR(200)  NOT NULL,
    [void]                          BIT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_contractor_invoice] PRIMARY KEY CLUSTERED ([contractor_invoice_id] ASC)
);
GO

CREATE UNIQUE INDEX IDX_NonVoidInvoice
    ON dbo.contractor_invoice (contractor_id, invoice_start, invoice_end)
    WHERE void = 0;