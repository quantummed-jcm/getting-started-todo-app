# =========================
# BACKEND BUILD STAGE
# =========================
FROM node:20-alpine AS backend

WORKDIR /app/backend

RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    sqlite-dev \
    bash

RUN ln -sf python3 /usr/bin/python

COPY backend/package*.json ./
RUN npm install

COPY backend/ .

# =========================
# FRONTEND BUILD STAGE
# =========================
FROM node:20-alpine AS frontend

WORKDIR /app/client

COPY client/package*.json ./
RUN npm install

COPY client/ .
RUN npm run build

# =========================
# FINAL RUNTIME STAGE
# =========================
FROM node:20-alpine AS runtime

WORKDIR /app

# runtime dependencies only (NO build tools)
RUN apk add --no-cache sqlite sqlite-dev bash

# backend
COPY --from=backend /app/backend /app/backend

# frontend build
COPY --from=frontend /app/client/dist /app/backend/public

WORKDIR /app/backend

EXPOSE 3000

CMD ["npm", "start"]