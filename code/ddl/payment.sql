SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment](
	[location] [nvarchar](50) NOT NULL,
	[session_id] [int] NOT NULL,
	[session_type] [nvarchar](50) NOT NULL,
	[session_date] [datetime] NOT NULL,
	[service_name] [nvarchar](200) NOT NULL,
	[service_type] [nvarchar](50) NOT NULL,
	[client_code] [nvarchar](10) NOT NULL,
	[client_id] [int] NOT NULL,
	[client_tags] [nvarchar](max) NULL,
	[therapist_name] [nvarchar](200) NOT NULL,
	[supervisor] [nvarchar](200) NULL,
	[duration] [int] NOT NULL,
	[attendance] [nvarchar](50) NOT NULL,
	[fee] [money] NOT NULL,
	[charged] [money] NOT NULL,
	[tax_charged] [money] NOT NULL,
	[payment_amount] [money] NOT NULL,
	[payment_tax_amount] [money] NOT NULL,
	[payment_date] [datetime] NOT NULL,
	[total_session_amount_paid] [money] NOT NULL,
	[total_session_tax_paid] [money] NOT NULL,
	[invoice_id] [int] NOT NULL,
	[payment_method] [nvarchar](50) NOT NULL,
	[insurer] [nvarchar](200) NULL,
	[receipt_confirmation_number] [nvarchar](50) NULL,
	[payment_status] [nvarchar](20) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
