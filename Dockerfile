###################################################
# Stage: base
###################################################
FROM node:22-alpine AS base
WORKDIR /usr/local/app

################## CLIENT ##################

FROM base AS client-base

COPY client/package*.json ./

# Faster + smaller install
RUN npm ci

COPY client/ .

FROM client-build AS client-build
RUN npm run build

################## BACKEND ##################

FROM base AS backend-dev

COPY backend/package*.json ./
RUN npm ci

COPY backend/ .

CMD ["npm", "run", "dev"]

################## TEST ##################

FROM backend-dev AS test
RUN npm run test

################## FINAL ##################

# Use lightweight runtime
FROM node:22-alpine AS final

WORKDIR /usr/local/app

ENV NODE_ENV=production

# Install only production dependencies
COPY --from=test /usr/local/app/package*.json ./

RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy backend code
COPY backend/src ./src

# Copy built client
COPY --from=client-build /usr/local/app/dist ./src/static

EXPOSE 3000

CMD ["node", "src/index.js"]