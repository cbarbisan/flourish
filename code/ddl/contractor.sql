SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contractor] (
    [contractor_id]     INT            IDENTITY (1, 1) NOT NULL,
    [contractor_name]   NVARCHAR (200) NOT NULL,
    [department]        NVARCHAR (50)  NOT NULL,
    [invoice_frequency] NVARCHAR (50)  CONSTRAINT [DEFAULT_contractor_invoice_frequency] DEFAULT 'Monthly' NOT NULL,
	[email]             NVARCHAR (256) NULL,
	[start_date]        DATE NULL,
    CONSTRAINT [PK_contractor] PRIMARY KEY CLUSTERED ([contractor_id] ASC)
);
GO

INSERT INTO dbo.contractor
SELECT	'Leanda Barbisan, OT Reg. (Ont.)' AS contractor_name,
		'OCCUPATIONAL THERAPY' AS department,
        'Monthly' AS invoice_frequency,
		'leanda.barbisan@flourishhealthservices.ca' AS email,
		'20210901' AS start_date;