-- This data defines overrides to what percentage of the customer's
-- fee is paid to the contractor who provided the service, and the
-- percentage paid to the contractor if they supervised the service
-- provider
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[service_cut_override] (
    [contractor_id]   INT            NOT NULL,
    [service_name]    NVARCHAR (200) NOT NULL,
    [service_cut]     DECIMAL (4, 3) DEFAULT ((0.7)) NOT NULL,
    [supervision_cut] DECIMAL (4, 3) DEFAULT ((0.1)) NOT NULL,
    CONSTRAINT [PK_contractor_service_cut] PRIMARY KEY CLUSTERED ([contractor_id] ASC, [service_name] ASC)
);
