-- This links a contractor's role with a service they provide.
-- This data will allow us to create contractor_service_cut records
-- that are specific to the role of the contractor.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[role_service] (
    [role]         NVARCHAR (50)  NOT NULL,
    [service_name] NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_role_service2] PRIMARY KEY CLUSTERED ([role] ASC, [service_name] ASC)
);