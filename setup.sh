#!/bin/bash
for s in api:8080:server.js frontend:3000:server.js; do
	svc=${s%%:*}; rest=${s#*:}; port=${rest%%:*}; entry=${rest#*:}
	cat > $svc/Dockerfile <<EOF
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
FROM base AS dev
RUN npm install
COPY . .
USER node
EXPOSE $port
CMD ["npm","run","dev"]
FROM base AS build
RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev
FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY package*json ./
COPY src ./src
USER node
EXPOSE $port
CMD ["node","src/$entry"]
EOF
done
cat > worker/Dockerfile <<'EOF'
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
FROM base AS dev
RUN npm install
COPY . .
USER node
CMD ["npm","run","dev"]
FROM base AS build
RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev
FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY package*.json ./
COPY src ./src
USER node
CMD ["node","src/worker.js"]
EOF
echo "Gotovo. Dockerfileovi:"
ls api/Dockerfile worker/Dockerfile frontend/Dockerfile
