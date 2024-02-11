-- This table provides a mechanism for including in future sessions in future
-- invoices that were paid prior to the launch date, but not invoiced by the
-- contractor, either due to the note being incomplete or an error of
-- ommission.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[non_invoiced_session] (
    [contractor_id] INT NOT NULL,
    [session_id]    INT NOT NULL,
    CONSTRAINT [PK_non_invoiced_session] PRIMARY KEY CLUSTERED ([contractor_id] ASC, [session_id] ASC)
);
