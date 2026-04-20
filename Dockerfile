# =========================
# BASE
# =========================
FROM node:22-alpine AS base

WORKDIR /app

RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite \
    sqlite-dev

RUN ln -sf python3 /usr/bin/python

# =========================
# BACKEND BUILD
# =========================
FROM base AS backend

WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm install

COPY backend/ ./

EXPOSE 3000

CMD ["npm", "run", "dev"]


# =========================
# CLIENT BUILD
# =========================
FROM node:22-alpine AS client-build

WORKDIR /app/client

COPY client/package*.json ./
RUN npm install

COPY client/ .
RUN npm run build


# =========================
# NGINX SERVE CLIENT
# =========================
FROM nginx:alpine AS client

COPY --from=client-build /app/client/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]