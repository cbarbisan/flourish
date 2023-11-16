SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment](
	[location] [nvarchar](50) NOT NULL,
	[payment_id] [int] NOT NULL,
	[payment_date] [date] NOT NULL,
	[payment_amount] [money] NOT NULL,
	[payment_tax_amount] [money] NOT NULL,
	[session_id] [int] NOT NULL,
	[session_type] [nvarchar](50) NOT NULL,
	[session_date] [datetime] NOT NULL,
	[client_id] [int] NOT NULL,
	[client_tags] [nvarchar](max) NULL,
	[fee] [money] NOT NULL,
	[charged] [money] NOT NULL,
	[tax_charged] [money] NOT NULL,
	[amount_paid] [money] NOT NULL,
	[tax_paid] [money] NOT NULL,
	[payment_method] [nvarchar](50) NOT NULL,
	[insurer] [nvarchar](200) NULL,
	[therapist_name] [nvarchar](200) NOT NULL,
	[supervisor] [nvarchar](200) NULL,
	[invoice_id] [int] NOT NULL,
	[invoice_date] [datetime] NOT NULL,
	[invoice_amount] [money] NOT NULL,
	[invoice_tax_amount] [money] NOT NULL,
	[receipt_id] [int] NOT NULL,
	[receipt_date] [datetime] NOT NULL,
	[receipt_amount] [money] NOT NULL,
	[receipt_tax_amount] [money] NOT NULL,
	[receipt_confirmation_number] [nvarchar](50) NULL,
	[payment_status] [nvarchar](20) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
