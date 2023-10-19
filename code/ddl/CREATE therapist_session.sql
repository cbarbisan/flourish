SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[therapist_session](
	[location] [nvarchar](50) NOT NULL,
	[session_id] [int] NOT NULL,
	[session_type] [nvarchar](50) NOT NULL,
	[session_date] [datetime] NOT NULL,
	[service_name] [nvarchar](200) NOT NULL,
	[service_type] [nvarchar](50) NOT NULL,
	[client_code] [nvarchar](10) NOT NULL,
	[client_id] [int] NOT NULL,
	[therapist_name] [nvarchar](200) NOT NULL,
	[supervisor] [nvarchar](200) NULL,
	[duration] [int] NOT NULL,
	[attendance] [nvarchar](50) NOT NULL,
	[fee] [money] NOT NULL,
	[charged] [money] NOT NULL,
	[tax_charged] [money] NOT NULL,
	[paid] [money] NOT NULL,
	[tax_paid] [money] NOT NULL,
	[invoice_id] [int] NULL,
	[payment_method] [nvarchar](50) NULL,
	[note_status] [nvarchar](50) NOT NULL,
	[comments] [nvarchar](max) NULL,
	[client_tags] [nvarchar](max) NULL,
	[video] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[therapist_session] ADD  CONSTRAINT [PK_therapist_session] PRIMARY KEY CLUSTERED 
(
	[session_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
