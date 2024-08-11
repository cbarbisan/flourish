-- Synonym object for session data.
-- If we want to configure the system to use the
-- therapist specific data, then the synonym 
-- should point to dbo.owl_therapist_session.
-- If we want to configure the system to use the
-- all therapist data, then the synonym should
-- point to dbo.owl_session.
CREATE SYNONYM dbo.s_session FOR dbo.owl_therapist_session;