SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contractor] (
    [contractor_id] INT IDENTITY(1, 1) NOT NULL,
    [contractor_name] NVARCHAR(200) NOT NULL,
	[role] NVARCHAR(50) NOT NULL,
    [active] BIT DEFAULT 1 NOT NULL
    CONSTRAINT [PK_contractor] PRIMARY KEY CLUSTERED ([contractor_id] ASC)
);
GO

INSERT INTO dbo.contractor
SELECT	'Leanda Barbisan, OT Reg. (Ont.)' AS contractor_name,
		'Occupational Therapist' AS role,
		1 AS active;