CREATE TRIGGER check_paymentDocs_total_price
    AFTER INSERT OR UPDATE ON payment_document
    FOR EACH ROW
    EXECUTE FUNCTION check_paymentDocs_total_price_func();
