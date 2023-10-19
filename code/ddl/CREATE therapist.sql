SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[therapist] (
    [therapist_id] INT IDENTITY(1, 1) NOT NULL,
    [therapist_name] NVARCHAR(200) NOT NULL,
    [active] BIT DEFAULT 1 NOT NULL,
	[onsite_cut] DECIMAL(3,2) NOT NULL,
	[offsite_cut] DECIMAL(3,2) NOT NULL,
	[supervising_cut] DECIMAL(3,2) NOT NULL,
    CONSTRAINT [PK_therapist] PRIMARY KEY CLUSTERED ([therapist_id] ASC)
);
GO

INSERT INTO dbo.therapist
SELECT	'Leanda Barbisan, OT Reg. (Ont.)' AS therapist_name,
		1 AS active,
		0.70 AS onsite_cut,
		0.80 AS offsite_cut,
		0.10 AS supervising_cut;