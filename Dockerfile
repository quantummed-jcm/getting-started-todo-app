# =========================
# BASE IMAGE (build stage)
# =========================
FROM node:22-alpine AS base

WORKDIR /app/backend

# Install dependencies needed for sqlite3 + node-gyp
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    sqlite-dev

# Ensure python command exists (node-gyp requirement)
RUN ln -sf python3 /usr/bin/python

# =========================
# INSTALL DEPENDENCIES
# =========================
FROM base AS deps

COPY backend/package*.json ./

RUN npm install --build-from-source

# =========================
# DEV / BUILD STAGE
# =========================
FROM base AS backend-dev

WORKDIR /app/backend

COPY backend/ ./
COPY --from=deps /app/backend/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "run", "dev"]

# =========================
# PRODUCTION STAGE (OPTIONAL)
# =========================
FROM node:22-alpine AS backend-prod

WORKDIR /app/backend

RUN apk add --no-cache sqlite sqlite-dev

COPY backend/package*.json ./
RUN npm install --omit=dev --build-from-source

COPY backend/ ./

EXPOSE 3000

CMD ["npm", "start"]