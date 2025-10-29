###############################
# Backstage Multi-Stage Build #
###############################
# Etapas:
# 1. deps      -> instala dependencias (cache rápido en cambios de código)
# 2. builder   -> compila frontend (assets) y backend (dist) usando dev deps
# 3. prod-deps -> instala SÓLO dependencias de producción del backend
# 4. runtime   -> imagen final mínima con dist + assets + deps backend

ARG NODE_VERSION=20-alpine

###############################
# 1. Dependencias (cache)
###############################
FROM node:${NODE_VERSION} AS deps
WORKDIR /app
RUN apk add --no-cache python3 make g++ git
COPY package.json yarn.lock .yarnrc.yml .yarn/ ./
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json
RUN corepack enable && corepack prepare yarn@4.4.1 --activate && \
    yarn set version 4.4.1
# Instalación inmutable para asegurar reproducibilidad (cache mounts deben ir antes del comando)
RUN --mount=type=cache,target=/app/.yarn/cache \
    --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/app/node_modules \
    yarn install --immutable

###############################
# 2. Builder (usa dev deps)
###############################
FROM deps AS builder
WORKDIR /app
COPY . .
# Build completo (frontend + backend)
RUN yarn build:all || yarn build

###############################
# 3. Prod deps (solo backend runtime)
###############################
FROM node:${NODE_VERSION} AS prod-deps
WORKDIR /app
RUN apk add --no-cache python3 make g++ git
# Copiamos artefactos de Yarn del stage anterior para asegurar yarnPath existente
COPY --from=deps /app/.yarn /app/.yarn
COPY --from=deps /app/.yarnrc.yml /app/.yarnrc.yml
COPY package.json yarn.lock ./
COPY packages/backend/package.json packages/backend/package.json
RUN corepack enable && corepack prepare yarn@4.4.1 --activate && \
    yarn set version 4.4.1
# Primero instalar (con cache) y luego enfocar sólo backend en modo producción
RUN --mount=type=cache,target=/app/.yarn/cache \
    --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/app/node_modules \
    yarn install --immutable && yarn workspaces focus backend --production

###############################
# 4. Runtime final
###############################
FROM node:${NODE_VERSION} AS runtime
WORKDIR /app
RUN apk add --no-cache dumb-init curl
ENV NODE_ENV=production
ENV APP_DIST_DIR=/app/packages/app/dist
# Copiamos solo lo necesario
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=prod-deps /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=prod-deps /app/packages/backend/package.json ./packages/backend/package.json
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist
COPY --from=builder /app/packages/app/dist ./packages/app/dist
COPY --from=builder /app/app-config.production.yaml ./app-config.production.yaml
COPY --from=builder /app/catalog-info.yaml ./catalog-info.yaml
COPY --from=builder /app/backstage.json ./backstage.json

EXPOSE 7007
USER node
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "packages/backend/dist/index.cjs.js"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=25s --retries=3 \
	CMD wget -qO- http://127.0.0.1:7007/health || wget -qO- http://127.0.0.1:7007/healthcheck || exit 1
