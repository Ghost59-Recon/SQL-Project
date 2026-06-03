-- ============================================================
-- Project      : Airline Reservation System
-- Description  : Relational schema, seed data, and analytical
--                queries for managing airlines, flights,
--                passengers, reservations, and payments.
-- Database     : MySQL 8.0+ / MariaDB 10.6+
-- Author       : Uzair Imran
-- Date         : 2025-06-16
-- Course       : Database Management Systems (DBMS)
-- ============================================================


-- ============================================================
-- SCHEMA DEFINITION
-- ============================================================

CREATE TABLE Airline (
    airline_id    INT          NOT NULL,
    airline_name  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_airline PRIMARY KEY (airline_id)
);

-- An aircraft belongs to exactly one airline.
CREATE TABLE Aircraft (
    aircraft_id  INT          NOT NULL,
    model        VARCHAR(100) NOT NULL,
    capacity     INT          NOT NULL,
    airline_id   INT          NOT NULL,
    CONSTRAINT pk_aircraft        PRIMARY KEY (aircraft_id),
    CONSTRAINT fk_aircraft_airline FOREIGN KEY (airline_id) REFERENCES Airline (airline_id),
    CONSTRAINT chk_capacity        CHECK (capacity > 0)
);

CREATE TABLE Airport (
    airport_id    INT          NOT NULL,
    airport_name  VARCHAR(100) NOT NULL,
    city          VARCHAR(100) NOT NULL,
    country       VARCHAR(100) NOT NULL,
    CONSTRAINT pk_airport PRIMARY KEY (airport_id)
);

CREATE TABLE Passenger (
    passenger_id  INT          NOT NULL,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL,
    phone         VARCHAR(15),
    CONSTRAINT pk_passenger    PRIMARY KEY (passenger_id),
    CONSTRAINT uq_passenger_email UNIQUE (email)
);

-- A flight is operated by one airline using one aircraft.
CREATE TABLE Flight (
    flight_id      INT         NOT NULL,
    flight_number  VARCHAR(10) NOT NULL,
    aircraft_id    INT         NOT NULL,
    airline_id     INT         NOT NULL,
    CONSTRAINT pk_flight           PRIMARY KEY (flight_id),
    CONSTRAINT uq_flight_number    UNIQUE (flight_number),
    CONSTRAINT fk_flight_aircraft  FOREIGN KEY (aircraft_id) REFERENCES Aircraft (aircraft_id),
    CONSTRAINT fk_flight_airline   FOREIGN KEY (airline_id)  REFERENCES Airline  (airline_id)
);

-- One flight can have multiple scheduled legs (e.g. recurring daily routes).
CREATE TABLE Flight_Schedule (
    schedule_id           INT      NOT NULL,
    flight_id             INT      NOT NULL,
    departure_airport_id  INT      NOT NULL,
    arrival_airport_id    INT      NOT NULL,
    departure_time        DATETIME NOT NULL,
    arrival_time          DATETIME NOT NULL,
    CONSTRAINT pk_schedule              PRIMARY KEY (schedule_id),
    CONSTRAINT fk_schedule_flight       FOREIGN KEY (flight_id)            REFERENCES Flight  (flight_id),
    CONSTRAINT fk_schedule_dep_airport  FOREIGN KEY (departure_airport_id) REFERENCES Airport (airport_id),
    CONSTRAINT fk_schedule_arr_airport  FOREIGN KEY (arrival_airport_id)   REFERENCES Airport (airport_id),
    CONSTRAINT chk_schedule_times       CHECK (arrival_time > departure_time)
);

CREATE TABLE Reservation (
    reservation_id    INT         NOT NULL,
    passenger_id      INT         NOT NULL,
    flight_id         INT         NOT NULL,
    seat_number       VARCHAR(10) NOT NULL,
    reservation_date  DATE        NOT NULL,
    CONSTRAINT pk_reservation          PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_passenger FOREIGN KEY (passenger_id) REFERENCES Passenger (passenger_id),
    CONSTRAINT fk_reservation_flight    FOREIGN KEY (flight_id)    REFERENCES Flight    (flight_id)
);

CREATE TABLE Payment (
    payment_id      INT           NOT NULL,
    reservation_id  INT           NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    payment_date    DATE          NOT NULL,
    payment_method  VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_payment              PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_reservation  FOREIGN KEY (reservation_id) REFERENCES Reservation (reservation_id),
    CONSTRAINT chk_payment_amount      CHECK (amount >= 0)
);


-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO Airline (airline_id, airline_name) VALUES
    (1, 'SkyJet Airlines'),
    (2, 'Global Wings');

INSERT INTO Aircraft (aircraft_id, model, capacity, airline_id) VALUES
    (101, 'Boeing 737',  180, 1),
    (102, 'Airbus A320', 150, 2);

INSERT INTO Airport (airport_id, airport_name, city, country) VALUES
    (1, 'Heathrow Airport',  'London',   'UK'),
    (2, 'JFK International', 'New York',  'USA');

INSERT INTO Passenger (passenger_id, first_name, last_name, email, phone) VALUES
    (201, 'Alice', 'Walker', 'alice@example.com', '1234567890'),
    (202, 'Bob',   'Smith',  'bob@example.com',   '9876543210');

INSERT INTO Flight (flight_id, flight_number, aircraft_id, airline_id) VALUES
    (301, 'SJ1001', 101, 1),
    (302, 'GW2020', 102, 2);

INSERT INTO Flight_Schedule (schedule_id, flight_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time) VALUES
    (401, 301, 1, 2, '2025-06-01 10:00:00', '2025-06-01 14:00:00'),
    (402, 302, 2, 1, '2025-06-02 15:00:00', '2025-06-02 19:00:00');

INSERT INTO Reservation (reservation_id, passenger_id, flight_id, seat_number, reservation_date) VALUES
    (501, 201, 301, '12A', '2025-05-20'),
    (502, 202, 302, '15B', '2025-05-21');

INSERT INTO Payment (payment_id, reservation_id, amount, payment_date, payment_method) VALUES
    (601, 501, 450.00, '2025-05-20', 'Credit Card'),
    (602, 502, 500.00, '2025-05-21', 'Debit Card');


-- ============================================================
-- QUERIES — BASIC
-- Straightforward single-purpose joins for common lookups.
-- ============================================================

-- 1. All reservations with passenger names and assigned seats
SELECT
    r.reservation_id,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    f.flight_number,
    r.seat_number
FROM       Reservation r
INNER JOIN Passenger   p ON p.passenger_id = r.passenger_id
INNER JOIN Flight      f ON f.flight_id    = r.flight_id;


-- 2. Payment history per passenger
SELECT
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    pm.amount,
    pm.payment_date,
    pm.payment_method
FROM       Passenger   p
INNER JOIN Reservation r  ON r.passenger_id  = p.passenger_id
INNER JOIN Payment     pm ON pm.reservation_id = r.reservation_id;


-- 3. Flight schedules with route cities
SELECT
    f.flight_number,
    dep.city          AS departure_city,
    arr.city          AS arrival_city,
    fs.departure_time,
    fs.arrival_time
FROM       Flight_Schedule fs
INNER JOIN Flight          f   ON f.flight_id            = fs.flight_id
INNER JOIN Airport         dep ON dep.airport_id         = fs.departure_airport_id
INNER JOIN Airport         arr ON arr.airport_id         = fs.arrival_airport_id;


-- 4. Each flight and its operating airline
SELECT
    f.flight_number,
    al.airline_name
FROM       Flight   f
INNER JOIN Airline  al ON al.airline_id = f.airline_id;


-- ============================================================
-- QUERIES — ADVANCED
-- Multi-table joins with aggregation and business context.
-- ============================================================

-- 5. Full itinerary view — reservation linked to passenger, route, and timing
SELECT
    r.reservation_id,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    f.flight_number,
    dep.airport_name  AS departure_airport,
    arr.airport_name  AS arrival_airport,
    fs.departure_time,
    fs.arrival_time,
    r.seat_number
FROM       Reservation     r
INNER JOIN Passenger       p   ON p.passenger_id         = r.passenger_id
INNER JOIN Flight          f   ON f.flight_id            = r.flight_id
INNER JOIN Flight_Schedule fs  ON fs.flight_id           = f.flight_id
INNER JOIN Airport         dep ON dep.airport_id         = fs.departure_airport_id
INNER JOIN Airport         arr ON arr.airport_id         = fs.arrival_airport_id;


-- 6. Total revenue collected per passenger
SELECT
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    SUM(pm.amount)                          AS total_paid
FROM       Passenger   p
INNER JOIN Reservation r  ON r.passenger_id   = p.passenger_id
INNER JOIN Payment     pm ON pm.reservation_id = r.reservation_id
GROUP BY   p.passenger_id, p.first_name, p.last_name;


-- 7. Airline schedule report — all routes with departure and arrival cities
SELECT
    al.airline_name,
    f.flight_number,
    dep.city          AS from_city,
    arr.city          AS to_city,
    fs.departure_time,
    fs.arrival_time
FROM       Airline         al
INNER JOIN Flight          f   ON f.airline_id           = al.airline_id
INNER JOIN Flight_Schedule fs  ON fs.flight_id           = f.flight_id
INNER JOIN Airport         dep ON dep.airport_id         = fs.departure_airport_id
INNER JOIN Airport         arr ON arr.airport_id         = fs.arrival_airport_id;


-- 8. Reservation detail with payment breakdown
SELECT
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    r.seat_number,
    f.flight_number,
    pm.payment_method,
    pm.amount
FROM       Reservation r
INNER JOIN Passenger   p  ON p.passenger_id   = r.passenger_id
INNER JOIN Flight      f  ON f.flight_id      = r.flight_id
INNER JOIN Payment     pm ON pm.reservation_id = r.reservation_id;