-- If a contractor gets more/less for providing a service than the
-- default cut, that is established by the data in this table.
-- For contractors who are supervised, the arrangement between
-- the therapist and the supervisor is also defined by this data.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[service_cut_override] (
    [record_id]       INT            IDENTITY (1, 1) NOT NULL,
    [therapist_id]    INT            NOT NULL,
    [service_name]    NVARCHAR (200) NOT NULL,
    [supervisor_id]   INT            NULL,
    [service_cut]     DECIMAL (4, 3) CONSTRAINT [DEFAULT_service_cut_override_service_cut] DEFAULT 0.7 NOT NULL,
    [supervision_cut] DECIMAL (4, 3) NULL,
    CONSTRAINT [PK_service_cut_override] PRIMARY KEY CLUSTERED ([record_id] ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [Index_service_cut_override_1]
    ON [dbo].[service_cut_override]([therapist_id] ASC, [service_name] ASC, [supervisor_id] ASC);
GO
