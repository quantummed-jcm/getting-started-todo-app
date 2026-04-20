###################################################
# BASE (shared lightweight image)
###################################################
FROM node:22-alpine AS base

WORKDIR /app


###################################################
# ================= CLIENT =======================
###################################################
FROM base AS client-deps

COPY client/package*.json ./
RUN npm ci


FROM client-deps AS client-build

COPY client/ .
RUN npm run build


###################################################
# ================= BACKEND =======================
###################################################
FROM base AS backend-deps

COPY backend/package*.json ./

# ONLY install production deps (NO sqlite3 build tools)
RUN npm ci --omit=dev

COPY backend/ .


###################################################
# BACKEND RUNTIME (CLEAN)
###################################################
FROM node:22-alpine AS backend

WORKDIR /app

ENV NODE_ENV=production

COPY --from=backend-deps /app /app

EXPOSE 3000

CMD ["node", "src/index.js"]


###################################################
# ================= FINAL FRONTEND ===============
###################################################
FROM nginx:alpine AS frontend

COPY --from=client-build /app/dist /usr/share/nginx/html

EXPOSE 80