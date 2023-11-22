SELECT  DISTINCT t.contractor_id AS therapist_id, 
        t.contractor_name AS therapist_name,
        sess.service_name,
        s.contractor_id AS supervisor_id,
        s.contractor_name AS supervisor_name
FROM    dbo.owl_session sess
JOIN    dbo.contractor t
ON      sess.therapist_name = t.contractor_name
JOIN    dbo.contractor s
ON      sess.supervisor = s.contractor_name
WHERE   sess.supervisor IS NOT NULL
AND     sess.session_date > '20230731'
ORDER BY 1, 2, 3;

INSERT INTO dbo.service_cut_override
SELECT  DISTINCT t.contractor_id AS therapist_id, 
        --t.contractor_name AS therapist_name,
        sess.service_name,
        s.contractor_id AS supervisor_id,
        --s.contractor_name AS supervisor_name,
        0.75 AS service_cut,
        0.25 AS supervision_cut
FROM    dbo.owl_session sess
JOIN    dbo.contractor t
ON      sess.therapist_name = t.contractor_name
JOIN    dbo.contractor s
ON      sess.supervisor = s.contractor_name
WHERE   sess.supervisor IS NOT NULL
AND     sess.session_date > '20230731';
