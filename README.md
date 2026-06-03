# Airline Reservation System — SQL

A relational database schema for managing airline operations, built as part of a Database Management Systems (DBMS) course project.

---

## Overview

This project models a simplified airline reservation system covering airlines, aircraft, airports, passengers, flights, schedules, reservations, and payments. It demonstrates relational schema design, constraint enforcement, and multi-table query patterns.

---

## Schema

| Table | Description |
|---|---|
| `Airline` | Registered airline carriers |
| `Aircraft` | Aircraft fleet, linked to an owning airline |
| `Airport` | Airport registry with city and country |
| `Passenger` | Passenger profiles with unique email constraint |
| `Flight` | Flights operated by a specific airline and aircraft |
| `Flight_Schedule` | Scheduled departure/arrival legs for each flight |
| `Reservation` | Passenger bookings with assigned seat numbers |
| `Payment` | Payment records linked to reservations |

### Entity Relationships

```
Airline ──< Aircraft
Airline ──< Flight
Aircraft ──< Flight
Flight ──< Flight_Schedule >── Airport (departure)
                            └── Airport (arrival)
Flight ──< Reservation >── Passenger
Reservation ──< Payment
```

---

## Queries

### Basic
1. All reservations with passenger names and seat assignments
2. Payment history per passenger
3. Flight schedules with departure and arrival cities
4. Each flight and its operating airline

### Advanced
5. Full itinerary view — reservation joined to passenger, route, and schedule
6. Total revenue collected per passenger (aggregated)
7. Airline schedule report across all routes
8. Reservation breakdown with payment method and amount

---

## Design Notes

- All foreign keys and check constraints are **explicitly named** for maintainability
- `Flight_Schedule` is kept separate from `Flight` to support recurring routes on the same flight number
- `GROUP BY` aggregations use primary keys rather than name columns to avoid collisions on duplicate names
- Column naming follows `snake_case` throughout for consistency

---

## Stack

- **SQL dialect:** MySQL 8.0+ / MariaDB 10.6+
- **Concepts covered:** DDL, DML, multi-table `INNER JOIN`, aggregation with `GROUP BY`, named constraints, referential integrity

---

## Author

**Uzair Imran** — Database Management Systems (DBMS), 2025
