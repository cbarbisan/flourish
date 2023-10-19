SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[therapist_invoice] (
    [therapist_invoice_id]          INT IDENTITY(1, 1) NOT NULL,
    [invoice_year]                  SMALLINT       NOT NULL,
    [invoice_month]                 TINYINT        NOT NULL,
    [therapist_invoice_date]        DATE           NOT NULL,
	[therapist_name]				NVARCHAR(200)  NOT NULL,
    [void]                          BIT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_therapist_invoice] PRIMARY KEY CLUSTERED ([therapist_invoice_id] ASC)
);
GO
