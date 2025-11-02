###############################
# Backstage Multi-Stage Build #
###############################
# Etapas:
# 1. deps      -> instala dependencias (cache rápido en cambios de código)
# 2. builder   -> compila frontend (assets) y backend (dist) usando dev deps
# 3. prod-deps -> instala SÓLO dependencias de producción del backend
# 4. runtime   -> imagen final mínima con dist + assets + deps backend

ARG NODE_VERSION=20-slim

###############################
# 1. Dependencias (cache)
###############################
FROM node:${NODE_VERSION} AS deps
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ git ca-certificates curl && rm -rf /var/lib/apt/lists/*
# Copiamos manifestos de dependencias; la carpeta .yarn será creada por Yarn en este contenedor
COPY package.json yarn.lock .yarnrc.yml ./
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json
RUN corepack enable && corepack prepare yarn@4.4.1 --activate && \
    yarn set version 4.4.1
# Instalación inmutable para asegurar reproducibilidad (cache mounts deben ir antes del comando)
RUN --mount=type=cache,target=/app/.yarn/cache \
    --mount=type=cache,target=/root/.cache \
    yarn install --immutable

###############################
# 2. Builder (usa dev deps)
###############################
FROM deps AS builder
WORKDIR /app
# Copiamos código fuente (sin sobrescribir estado de dependencias ya instalado en la etapa deps)
COPY . .
# Garantizamos que node_modules exista (si en el futuro se reintroduce el mount cache para node_modules en deps, esto volverá a instalar rápido usando .yarn/cache)
RUN yarn install --immutable --mode=skip-build || yarn install --immutable || true
# Build completo (frontend + backend) usando estado de instalación existente
RUN yarn build:all || yarn build

###############################
# 3. Prod deps (solo backend runtime)
###############################
FROM node:${NODE_VERSION} AS prod-deps
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ git ca-certificates curl && rm -rf /var/lib/apt/lists/*
# Copiamos artefactos de Yarn del stage anterior para asegurar yarnPath existente
# Copiamos estado de instalación (directorio .yarn) y configuración para garantizar reproducibilidad
COPY --from=deps /app/.yarn /app/.yarn
COPY --from=deps /app/.yarnrc.yml /app/.yarnrc.yml
COPY package.json yarn.lock ./
COPY packages/backend/package.json packages/backend/package.json
RUN corepack enable && corepack prepare yarn@4.4.1 --activate && \
    yarn set version 4.4.1
# Primero instalar (con cache) y luego enfocar sólo backend en modo producción
RUN --mount=type=cache,target=/app/.yarn/cache \
    --mount=type=cache,target=/root/.cache \
    yarn workspaces focus backend --production

###############################
# 4. Runtime final
###############################
FROM node:${NODE_VERSION} AS runtime
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init curl ca-certificates && rm -rf /var/lib/apt/lists/*
ENV NODE_ENV=production
ENV APP_DIST_DIR=/app/packages/app/dist
# Copiamos solo lo necesario
COPY --from=prod-deps /app/node_modules ./node_modules
# No copiamos packages/backend/node_modules porque el focus backend sólo generó node_modules raíz.
# La resolución de módulos del backend (dist) ascenderá hasta /app/node_modules.
COPY --from=prod-deps /app/packages/backend/package.json ./packages/backend/package.json
# Copiamos el bundle generado por el build y lo extraemos para obtener dist/index.cjs.js
COPY --from=builder /app/packages/backend/dist/bundle.tar.gz ./bundle.tar.gz
RUN tar xzf bundle.tar.gz || echo "[WARN] No se pudo extraer bundle.tar.gz (puede no existir)" && rm -f bundle.tar.gz || true
# Copia directa del dist del backend (garantiza presencia de index.cjs.js independientemente del contenido del bundle)
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist
# Verificación temprana: fallar si el archivo principal no existe
RUN test -f packages/backend/dist/index.cjs.js || (echo "[ERROR] Backend dist/index.cjs.js no encontrado tras build" && ls -R packages/backend/dist || exit 1)
# El bundle (si existió) puede haber traído otros assets; mantenemos dist explícito.
COPY --from=builder /app/packages/app/dist ./packages/app/dist
COPY --from=builder /app/app-config.production.yaml ./app-config.production.yaml
COPY --from=builder /app/app-config.yaml ./app-config.yaml
COPY --from=builder /app/catalog-info.yaml ./catalog-info.yaml
COPY --from=builder /app/backstage.json ./backstage.json
## Catálogo de ejemplos (usuarios, grupos, templates): se requería para que las rutas ./examples/*.yaml del app-config existan en runtime
COPY --from=builder /app/IDP/examples ./examples

EXPOSE 7007
 # Ajustamos ownership para permitir que el usuario "node" lea los artefactos extraídos
 RUN chown -R node:node /app
USER node
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=25s --retries=3 \
    CMD curl -fsS http://127.0.0.1:7007/health || curl -fsS http://127.0.0.1:7007/healthcheck || exit 1

# Sugerencias futuras:
# - Añadir variable BACKSTAGE_LOG_LEVEL para controlar verbosidad.
# - Montar kubeconfig si se habilita plugin kubernetes.
# - Generar SBOM (syft) y firmar la imagen (cosign) en CI, no aquí.
