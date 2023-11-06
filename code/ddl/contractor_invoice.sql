SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contractor_invoice] (
    [contractor_invoice_id]          INT IDENTITY(1, 1) NOT NULL,
    [invoice_year]                  SMALLINT       NOT NULL,
    [invoice_month]                 TINYINT        NOT NULL,
    [invoice_date]        			DATE           NOT NULL,
	[contractor_name]				NVARCHAR(200)  NOT NULL,
    [void]                          BIT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_contractor_invoice] PRIMARY KEY CLUSTERED ([contractor_invoice_id] ASC)
);
GO
