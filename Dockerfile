# =========================
# BASE IMAGE
# =========================
FROM node:20-alpine AS base

WORKDIR /app/backend

# Install build tools required for sqlite3
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    sqlite-dev

RUN ln -sf python3 /usr/bin/python

# =========================
# DEPENDENCIES STAGE
# =========================
FROM base AS deps

COPY backend/package*.json ./
RUN npm install

# =========================
# DEV STAGE
# =========================
FROM base AS backend-dev

WORKDIR /app/backend

COPY backend/ ./
COPY --from=deps /app/backend/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "run", "dev"]

# =========================
# PRODUCTION STAGE
# =========================
FROM node:20-alpine AS backend-prod

WORKDIR /app/backend

RUN apk add --no-cache sqlite sqlite-dev

COPY backend/package*.json ./
RUN npm install --omit=dev

COPY backend/ ./

EXPOSE 3000

CMD ["npm", "start"]