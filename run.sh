#!/bin/bash
set -e
podman rm -f postgres redis api worker frontend 2>/dev/null || true
podman network create ticketnet 2>/dev/null || true

echo "== postgres =="
podman run -d --name postgres --network ticketnet --env-file .env \
	-e PGDATA=/var/lib/postgresql/data/pgdata \
	-v pgdata:/var/lib/postgresql/data \
	-v ./infra/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql:ro,Z \
	docker.io/library/postgres:16-alpine

echo "== redis =="
podman run -d --name redis --network ticketnet \
	docker.io/library/redis:7-alpine redis-server --save "" --appendonly no

echo "== build slika =="
podman build -t ticketing-api:dev --target dev ./api
podman build -t ticketing-worker :dev --target dev ./worker
podman build -t ticketing-frontend:dev --target dev ./frontend

echo "== cekam bazu 8s =="
sleep 8

echo "== api =="
podman run -d --name api --network ticketnet --env-file .env -p 8080:8080 ticketing-api:dev
echo "== worker =="
podman run -d --name worker --network ticketnet --env-file .env ticketing-worker:dev
echo "== frontend =="
podman run -d --name frontend --network ticketnet --env-file .env \
	-e API_BASE_URL=http://localhost:8080 -p 3000:3000 ticketing_frontend:dev

echo "== GOTOVO =="
podman ps
