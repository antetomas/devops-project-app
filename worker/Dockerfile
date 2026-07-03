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
