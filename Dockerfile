###################################################
# BASE
###################################################
FROM node:22-alpine AS base

WORKDIR /app


###################################################
# ================= BACKEND ======================
###################################################
FROM base AS backend-deps

COPY backend/package*.json ./

# Install ONLY production dependencies
RUN npm ci --omit=dev && npm cache clean --force

COPY backend/ .


###################################################
# BACKEND RUNTIME (CLEAN)
###################################################
FROM node:22-alpine AS backend

WORKDIR /app

ENV NODE_ENV=production

# Copy clean backend
COPY --from=backend-deps /app /app

EXPOSE 3000

CMD ["node", "src/index.js"]


###################################################
# ================= FRONTEND =====================
###################################################
FROM base AS client-deps

COPY client/package*.json ./
RUN npm ci

COPY client/ .

FROM client-deps AS client-build

RUN npm run build


###################################################
# FRONTEND RUNTIME (NGINX)
###################################################
FROM nginx:alpine AS frontend

COPY --from=client-build /app/dist /usr/share/nginx/html

EXPOSE 80