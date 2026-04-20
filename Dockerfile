############################################
# 🟢 BASE IMAGE (shared dependencies)
############################################
FROM node:22-alpine AS base
WORKDIR /app

############################################
# 🟡 BACKEND DEPENDENCIES
############################################
FROM base AS backend-deps
COPY backend/package*.json ./backend/
WORKDIR /app/backend
RUN npm install

############################################
# 🟠 BACKEND DEV (matches compose fix)
############################################
FROM base AS backend-dev
WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm install

COPY backend/ ./

EXPOSE 3000
CMD ["npm", "run", "dev"]

############################################
# 🔵 FRONTEND DEPENDENCIES
############################################
FROM base AS client-deps
COPY client/package*.json ./client/
WORKDIR /app/client
RUN npm install

############################################
# 🟣 FRONTEND BUILD
############################################
FROM client-deps AS client-build
COPY client/ ./
RUN npm run build

############################################
# 🟤 FRONTEND PRODUCTION (NGINX)
############################################
FROM nginx:alpine AS frontend

COPY --from=client-build /app/client/dist /usr/share/nginx/html

# SPA routing fix (important for React/Vite)
RUN printf 'server {\n\
  listen 5173;\n\
  server_name localhost;\n\
  root /usr/share/nginx/html;\n\
  index index.html;\n\
\n\
  location / {\n\
    try_files $uri /index.html;\n\
  }\n\
}' > /etc/nginx/conf.d/default.conf

EXPOSE 5173
CMD ["nginx", "-g", "daemon off;"]