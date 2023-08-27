CREATE TRIGGER generate_price
    AFTER INSERT ON chosen_services
    FOR EACH ROW
    EXECUTE FUNCTION generate_price_func();
