-- Remember a session may get invoiced twice.
-- Once by the therapist and once by the supervisor.
-- For the purpose of this table, both will be considered the "contractor"
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoice_tracking](
	[session_id] [int] NOT NULL,
	[contractor] [nvarchar](200) NOT NULL,
	[invoiced] [bit] DEFAULT 0 NOT NULL,
	CONSTRAINT [PK_invoice_tracking] PRIMARY KEY CLUSTERED ([session_id] ASC, [contractor] ASC)
);
GO


