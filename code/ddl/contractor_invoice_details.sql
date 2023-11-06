SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contractor_invoice_details] (
    [contractor_invoice_details_id]  INT      IDENTITY (1, 1) NOT NULL,
    [contractor_invoice_id]          INT            NOT NULL,
    [session_id]                    INT            NOT NULL,
    [session_date]                  DATETIME       NOT NULL,
    [service_name]                  NVARCHAR(200)  NOT NULL,
    [client_code]                   NVARCHAR(10)   NOT NULL,
    [duration]                      INT            NOT NULL,
    [attendance]                    NVARCHAR(50)   NOT NULL,
    [fee]                           MONEY          NOT NULL,
    [charged]                       MONEY          NOT NULL,
    [paid]                          MONEY          NOT NULL,
    [contractor_amount]             MONEY          NOT NULL,
    [clinic_amount]                 MONEY          NOT NULL,
    [supervisor_amount]             MONEY DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_contractor_invoice_details] PRIMARY KEY CLUSTERED ([contractor_invoice_details_id] ASC)
);
GO
