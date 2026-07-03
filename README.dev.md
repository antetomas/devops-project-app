# Lokalno razvojno okruzenje - Secure Event Ticketing Platform

## Preduvjeti
- Podman 5+ i compose provider
- cp .env.example .env

## Servisi i portovi
- frontend (Node/Express) - 3000 - web sucelje
- api (Node/Express) - 8080 - REST API, health, red narudzbi
- worker (Node) - obrada narudzbi iz reda
- postgres (PostgreSQL 16) - 5432 - pohrana narudzbi
- redis (Redis 7) - 6379 - red poruka

## Pokretanje
	podman compose up --build

## Validacija
	curl http://localhost:8080/healthz
	curl http://localhost:8080/readyz
	curl -X POST http://localhost:8080/tickets/purchase -H "Content-Type: application/json" -d '{"eventId":"evt-1001","customerEmail":"student@example.com","quantity":2}'
	curl http://localhost:8080/tickets/orders

## Hot-reload
Kod je bind-mountan, servisi u dev fazi koriste nodemon - izmjene bez rebuilda.

## Perzistencija
PostgreSQL podaci u imenovanom volumenu, prezivljavaju restart.

## Zaustavljanje
	podman compose down
	podman compose down -v
