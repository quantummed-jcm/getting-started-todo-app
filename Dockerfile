# =========================
# BASE (Backend)
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

COPY backend/ ./

# =========================
# FRONTEND BUILD (VITE)
# =========================
FROM node:20-alpine AS frontend-build

WORKDIR /app/client

COPY client/package*.json ./
RUN npm install

COPY client/ ./
RUN npm run build

# =========================
# FINAL RUNTIME IMAGE
# =========================
FROM node:20-alpine

WORKDIR /app

# Install runtime dependencies for backend
RUN apk add --no-cache sqlite sqlite-dev bash

RUN ln -sf python3 /usr/bin/python || true

# Copy backend
COPY --from=backend /app/backend /app/backend
COPY --from=backend /app/backend/node_modules /app/backend/node_modules

# Copy frontend build into backend static folder OR nginx folder
COPY --from=frontend-build /app/client/dist /app/client/dist

WORKDIR /app/backend

EXPOSE 3000

CMD ["npm", "start"]