CREATE OR ALTER PROCEDURE dbo.sp_delete_payment_data
AS 
BEGIN

    DECLARE @base_table NVARCHAR(1035);

    SELECT  @base_table = base_object_name
    FROM    SYS.SYNONYMS
    WHERE   [NAME] = 's_payment';

    IF ( @base_table = '[dbo].[therapist_payment]')
        TRUNCATE TABLE dbo.therapist_payment;
    ELSE IF ( @base_table = '[dbo].[payment]')
        TRUNCATE TABLE dbo.payment;
    ELSE
    BEGIN
        DECLARE @msg NVARCHAR(2000) = NULL;
        SET @msg = CONCAT('Synonym s_session pointing at unexpected table: ', ISNULL(@base_table, 'NULL'));
        THROW 50000, @msg, 1;
    END

END
