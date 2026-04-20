# =========================
# BASE IMAGE
# =========================
FROM node:20-alpine AS base

WORKDIR /app/backend

# Install dependencies needed for sqlite3 build
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    sqlite-dev \
    bash

# Fix python symlink (node-gyp requirement)
RUN ln -sf python3 /usr/bin/python

# =========================
# INSTALL DEPENDENCIES
# =========================
FROM base AS deps

COPY backend/package*.json ./

# IMPORTANT: ensure clean install for sqlite3 build
RUN npm install --build-from-source

# =========================
# DEVELOPMENT STAGE
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

RUN apk add --no-cache \
    sqlite \
    sqlite-dev \
    python3 \
    make \
    g++ \
    bash

RUN ln -sf python3 /usr/bin/python

COPY backend/package*.json ./

# IMPORTANT: rebuild sqlite3 correctly in prod
RUN npm install --omit=dev --build-from-source

COPY backend/ ./

EXPOSE 3000

CMD ["npm", "start"]