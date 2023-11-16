-- This stored proc should only be executed when a new contractor/service has been
-- defined, and the role for the contractor has been updated in the contractor
-- table.
-- The procedure links a contractor to the services they provide and establishes
-- the cut for either performing or supervising that service.
CREATE OR ALTER PROCEDURE dbo.sp_add_service_cut_defaults
AS 
BEGIN

    SET NOCOUNT ON;
    
    INSERT INTO dbo.contractor_service_cut
    SELECT  c.contractor_id,
            rs.service_name,
            0.70 AS service_cut,
            0.10 AS supervision_cut
    FROM    dbo.contractor c
    JOIN    dbo.role_service rs
    ON      c.role = rs.role
    WHERE   NOT EXISTS (SELECT 1 FROM dbo.contractor_service_cut WHERE contractor_id = c.contractor_id AND [service_name] = rs.service_name);

END