###################################################
# Base image (shared)
###################################################
FROM node:22-alpine AS base

WORKDIR /usr/local/app


###################################################
# CLIENT BASE
###################################################
FROM base AS client-base

COPY client/package*.json ./
RUN npm install

COPY client/ .


###################################################
# CLIENT BUILD (Vite)
###################################################
FROM client-base AS client-build

RUN npm run build


###################################################
# BACKEND BASE
###################################################
FROM base AS backend-base

COPY backend/package*.json ./

# 🔥 REQUIRED for sqlite3 / node-gyp build
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    py3-pip

RUN npm ci

COPY backend/ .


###################################################
# BACKEND DEV
###################################################
FROM backend-base AS backend-dev

CMD ["npm", "run", "dev"]


###################################################
# TEST STAGE
###################################################
FROM backend-base AS test

RUN npm run test


###################################################
# FINAL PRODUCTION IMAGE
###################################################
FROM node:22-alpine AS final

WORKDIR /usr/local/app

ENV NODE_ENV=production

# Install production dependencies only
COPY backend/package*.json ./

RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    py3-pip && \
    npm ci --omit=dev && \
    npm cache clean --force

# Backend source
COPY backend/src ./src

# Frontend build output (Vite)
COPY --from=client-build /usr/local/app/dist ./src/static

EXPOSE 3000

CMD ["node", "src/index.js"]