CREATE DATABASE taxi;

CREATE DOMAIN valid_address AS CHAR(17)
    CHECK (
            VALUE IN
            ('Адмирлтейский', 'Василеостровский', 'Выборгский', 'Калининский',
             'Кировский',
             'Колпинский', 'Красногвардейский', 'Красносельский', 'Кронштадтский',
             'Курортный', 'Московский', 'Невский', 'Петроградский',
             'Петродворцовый',
             'Приморский', 'Пушкинский', 'Фрунзенский', 'Центральный')
        );

CREATE DOMAIN valid_name AS VARCHAR(15)
    CHECK (VALUE SIMILAR TO '[А-Я][а-я]+');

CREATE DOMAIN valid_phone_number AS CHAR(11)
    CHECK (VALUE SIMILAR TO '8\d{10}');


CREATE TABLE drivers
(
    name         valid_name PRIMARY KEY,
    phone_number valid_phone_number NOT NULL UNIQUE
);


CREATE TABLE cars
(
    license_plate   CHAR(6) PRIMARY KEY CHECK (license_plate SIMILAR TO '[А-Я]\d{3}[А-Я]{2}'),
    number_of_seats INTEGER  NOT NULL CHECK (number_of_seats BETWEEN 1 AND 16),
    brand           CHAR(13) NOT NULL CHECK (brand IN
                                             ('Audi', 'BMW', 'Ford', 'Honda', 'Hyundai', 'Kia', 'Lada', 'Mazda',
                                              'Mercedes-Benz', 'Mitsubishi', 'Nissan', 'Renault', 'Skoda', 'Toyota',
                                              'Volkswagen')),
    color           CHAR(10)  NOT NULL CHECK (color IN
                                             ('розовый', 'красный', 'зеленый', 'синий', 'белый', 'черный', 'серый', 'желтый',
                                              'фиолетовый')),
    type            CHAR(11)  NOT NULL CHECK (type IN
                                             ('седан', 'лимузин', 'миниавтобус', 'кабриолет', 'универсал', 'хэтчбек',
                                              'минивен', 'пикап')),
    driver          valid_name UNIQUE REFERENCES drivers (name)
);

CREATE TABLE customers
(
    name         valid_name PRIMARY KEY,
    phone_number valid_phone_number NOT NULL UNIQUE,
    address      valid_address
);

CREATE TABLE orders
(
    id                     SERIAL PRIMARY KEY,
    arrival_address        valid_address NOT NULL,
    departure_address      valid_address NOT NULL,
    price                  NUMERIC       NOT NULL CHECK (price >= 0.0),
    status                 CHAR(16)      NOT NULL CHECK (status IN ('едет к заказчику',
                                                                    'поездка началась', 'завершен',
                                                                    'отменен')) DEFAULT 'едет к заказчику',

    payment_method         CHAR(8)       NOT NULL CHECK (payment_method IN ('наличные', 'карта')),
    customer               CHAR(15)      NOT NULL REFERENCES customers (name),
    car                    CHAR(6) REFERENCES cars (license_plate),
    booking_time           TIMESTAMP     NOT NULL                                DEFAULT NOW(),
    arrival_time_to_client TIMESTAMP
);

CREATE TABLE logs
(
    id               SERIAL PRIMARY KEY,
    order_id         INT       NOT NULL REFERENCES orders (id),
    time             TIMESTAMP NOT NULL,

    -- 1 - to goes_to_customer
    -- 2 - from goes_to_customer to trip_started
    -- 3 - from trip_started to completed
    -- 4 - to canceled
    status_change_id INT       NOT NULL CHECK (status_change_id BETWEEN 1 AND 4) DEFAULT 1
);
