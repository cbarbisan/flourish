-- Synonym object for payment data.
-- If we want to configure the system to use the
-- therapist specific data, then the synonym 
-- should point to dbo.therapist_payment.
-- If we want to configure the system to use the
-- all therapist data, then the synonym should
-- point to dbo.payment.
CREATE SYNONYM dbo.s_payment FOR dbo.therapist_payment;