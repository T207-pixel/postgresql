CREATE TABLE client(
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(40),
    adrdress VARCHAR(70) DEFAULT '',
    firstname VARCHAR(15) NOT NULL,
    lastname VARCHAR(15) NOT NULL,
    patronymic VARCHAR(15) DEFAULT '',
    age SMALLINT NOT NULL,
    passport VARCHAR(18) NOT NULL, --добавить ограничения [DONE]
    email VARCHAR(25) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    CONSTRAINT client_age_check CHECK(age > 0 AND age < 150),
    UNIQUE(passport, email, phone)
);

CREATE TABLE job_title(
    id SERIAL PRIMARY KEY,
    job_name VARCHAR(40) NOT NULL
);

CREATE TABLE companys_employee(
    id SERIAL PRIMARY KEY,
    employee_Firstname VARCHAR(30) NOT NULL,
    employee_Lastname VARCHAR(30) NOT NULL,
    employee_Patronimic VARCHAR(30),
    iNN VARCHAR(12) NOT NULL,
    sex BOOLEAN NOT NULL,
    phone VARCHAR(20) NOT NULL,
    login  VARCHAR(25) NOT NULL,
    _password_ VARCHAR(30) NOT NULL,
    enrollment_date DATE NOT NULL,
    dismissal_date DATE NOT NULL
);

CREATE TABLE _event_(
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(40) NOT NULL,
    info TEXT,
    services TEXT NOT NULL,
    client_Firstname VARCHAR(15) NOT NULL,
    client_Lastname VARCHAR(15) NOT NULL,
    client_Patronymic VARCHAR(15) DEFAULT '',
    manager_Firstname VARCHAR(15) NOT NULL,
    manager_Lastname VARCHAR(15) NOT NULL,
    companys_employee_id INTEGER REFERENCES companys_employee (id)
);

CREATE TABLE change_job_title(
    id SERIAL PRIMARY KEY,
    employees_id INTEGER REFERENCES companys_employee(id),
    previous_job_titles INTEGER NOT NULL,
    new_job_titles INTEGER NOT NULL,
    dates DATE DEFAULT CURRENT_DATE
);

CREATE TABLE place(
    id SERIAL PRIMARY KEY,
    place_name VARCHAR(40) NOT NULL,
    place_type VARCHAR(30) NOT NULL,
    address VARCHAR(40) NOT NULL,
    place_square_meters NUMERIC(5,2) CHECK(place_square_meters > 0) NOT NULL
);

CREATE TABLE celebrity(
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    real_name VARCHAR(40) NOT NULL,
    price MONEY NOT NULL,
    scenario TEXT NOT NULL,
    email VARCHAR(25) NOT NULL,
    phone VARCHAR(25) NOT NULL
);

CREATE TABLE pricelist(
    id SERIAL PRIMARY KEY,
    Time_interval INTERVAL NOT NULL,
    pricelist_type VARCHAR(30) NOT NULL
);

CREATE TABLE payment_document(
    id SERIAL PRIMARY KEY,
    treaty_code INTEGER UNIQUE NOT NULL,
    payment_document_number INTEGER UNIQUE NOT NULL,
    payment_date DATE NOT NULL,
    total_price MONEY NOT NULL,
    accountant_firstname VARCHAR(15) NOT NULL,
    accountant_lastname VARCHAR(15) NOT NULL,
    document_type BOOLEAN NOT NULL,
    companys_employee_id INTEGER REFERENCES companys_employee (id) NOT NULL,
    client_id INTEGER REFERENCES client (id) NOT NULL
);

-- In further tabels have to add FK using ALTER TABLE
-- Firstly creates without any unrelated links with unexisting entityes

CREATE TABLE treaty(
    id SERIAL PRIMARY KEY,
    treaty_type VARCHAR(30) NOT NULL,
    total_price MONEY NOT NULL,
    treaty_number INTEGER UNIQUE NOT NULL,
    conclusion_date DATE NOT NULL,
    cancellation_date DATE NOT NULL,
    extra_pay  MONEY NOT NULL,
    employee_id INTEGER REFERENCES companys_employee (id) NOT NULL,
    client_id INTEGER REFERENCES client (id) NOT NULL, 
    event_id INTEGER REFERENCES _event_ (id) NOT NULL,
    celebrity_id INTEGER REFERENCES celebrity (id) NOT NULL
    -- and common.TREATY_ID (FK3) (USE ALTER TABEL) "DONE"
);

ALTER TABLE treaty
ADD treaty_id INTEGER REFERENCES treaty (id) NULL;

CREATE TABLE chosen_services(
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(40) NOT NULL,
    comment_to_service TEXT,
    service_type BOOLEAN NOT NULL,
    services_quantity  SMALLINT NOT NULL, -- doesn't exist already
    event_id INTEGER REFERENCES _event_ (id) NOT NULL, -- doesn't exist already
    treaty_id INTEGER REFERENCES treaty (id) NOT NULL
);

CREATE TABLE services_in_pricelist(
    service_name VARCHAR(30) NOT NULL,
    about_service TEXT NOT NULL,
    service_price MONEY NOT NULL,
    chosen_services_id INTEGER REFERENCES chosen_services (id) NOT NULL,
    pricelist_id INTEGER REFERENCES pricelist (id) NOT NULL,
    PRIMARY KEY (chosen_services_id, pricelist_id)
);

-- can't define with name in E13
CREATE TABLE services_in_events(
    service_price MONEY NOT NULL,
    chosen_services_id INTEGER REFERENCES chosen_services (id) NOT NULL,
    event_id INTEGER REFERENCES _event_ (id) NOT NULL,
    PRIMARY KEY (chosen_services_id, event_id)
);

CREATE TABLE installment(
    current_price MONEY NOT NULL,
    payment_document_id INTEGER REFERENCES payment_document (id) NOT NULL,
    treaty_id INTEGER REFERENCES treaty (id) NOT NULL,
    PRIMARY KEY (payment_document_id, treaty_id)
);

CREATE TABLE Rent(
    time_interval INTERVAL NOT NULL,
    treaty_id INTEGER REFERENCES treaty (id) NOT NULL,
    place_id INTEGER REFERENCES place (id) NOT NULL,
    PRIMARY KEY (treaty_id, place_id)
);

ALTER TABLE client 
ADD CONSTRAINT firstname_regexp CHECK (firstname ~ $$[A-Z,a-z][a-z]{2,15}$$);

ALTER TABLE client 
ADD CONSTRAINT lastname_regexp CHECK (lastname ~ $$[A-Z,a-z][a-z]{2,15}$$);

ALTER TABLE client
ADD CONSTRAINT patronymic_regexp CHECK (patronymic ~ $$[A-Z,a-z][a-z]{2,15}$$);

ALTER TABLE client
ADD CONSTRAINT passport_regexp CHECK (passport ~ $$\d{2}\s?\d{2}\s?\d{6}$$);

ALTER TABLE client
ADD CONSTRAINT phone_regexp CHECK (phone ~ $$[+]?[8,7]\s?-?[(]?[\d]{3}\s?-?[)]?[(]?[\d]{3}\s?-?[)]?[(]?[\d]{2}\s?-?[)]?[(]?[\d]{2}[)]?$$);

ALTER TABLE chosen_services
DROP COLUMN event_id;

ALTER TABLE chosen_services
DROP COLUMN services_quantity;

ALTER TABLE chosen_services
ALTER COLUMN actual_cost
SET NOT NULL;

ALTER TABLE pricelist
ALTER COLUMN time_interval
DROP NOT NULL;

ALTER TABLE pricelist
ALTER COLUMN pricelist_type
DROP NOT NULL;

ALTER TABLE pricelist
ADD service_name VARCHAR(30) NOT NULL;

ALTER TABLE pricelist
ADD cost MONEY NOT NULL;

ALTER TABLE pricelist
DROP COLUMN pricelist_type;

ALTER TABLE pricelist
ADD pricelist_type VARCHAR(30) NULL DEFAULT 'ordinary';

ALTER TABLE chosen_services
ALTER COLUMN service_type
DROP NOT NULL;

ALTER TABLE chosen_services
ADD counter INTEGER DEFAULT 1;

ALTER TABLE treaty
ADD additional_place INTEGER REFERENCES place(id) NULL;

ALTER TABLE place
ADD COLUMN price MONEY NOT NULL;

ALTER TABLE payment_document
ADD COLUMN linked_treaty INTEGER REFERENCES treaty(id) NOT NULL;

ALTER TABLE pricelist
DROP COLUMN service_name;

ALTER TABLE pricelist
DROP COLUMN pricelist_type;

ALTER TABLE services_in_pricelist
ALTER COLUMN about_service
DROP NOT NULL;

ALTER TABLE services_in_pricelist
ADD id  SERIAL PRIMARY KEY;

CREATE TABLE services(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL DEFAULT 'unknown'
);

CREATE TABLE payment_orders(
    id SERIAL PRIMARY KEY,
    total_payment MONEY NOT NULL DEFAULT 0,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    treaty_id INTEGER REFERENCES treaty(id)
);
