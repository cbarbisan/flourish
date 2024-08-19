CREATE OR ALTER PROCEDURE dbo.sp_delete_session_data
AS 
BEGIN

    DECLARE @base_table NVARCHAR(1035);

    SELECT  @base_table = base_object_name
    FROM    SYS.SYNONYMS
    WHERE   [NAME] = 's_session';

    IF ( @base_table = '[dbo].[owl_therapist_session]')
        TRUNCATE TABLE dbo.owl_therapist_session;
    ELSE IF ( @base_table = '[dbo].[owl_session]')
        TRUNCATE TABLE dbo.owl_session;
    ELSE
    BEGIN
        DECLARE @msg NVARCHAR(2000) = NULL;
        SET @msg = CONCAT('Synonym s_session pointing at unexpected table: ', ISNULL(@base_table, 'NULL'));
        THROW 50000, @msg, 1;
    END

END
