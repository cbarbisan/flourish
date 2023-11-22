-- Assuming all session data since the beginning of time is loaded in dbo.owl_session,
-- we can run this to calculate the start date for each contractor and update the
-- contractor table accordingly
WITH StartDates AS (
    SELECT      c.contractor_name, MIN(s.session_date) AS start_date
    FROM        dbo.contractor c
    JOIN        dbo.owl_session s
    ON          c.contractor_name = s.therapist_name
    OR          c.contractor_name = s.supervisor
    GROUP BY    c.contractor_name
)
UPDATE  c
SET     c.start_date = SD.start_date
FROM    dbo.contractor c
JOIN    StartDates SD
ON      c.contractor_name = SD.contractor_name;
