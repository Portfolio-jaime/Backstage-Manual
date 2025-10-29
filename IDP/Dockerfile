# Backstage Dockerfile para producción
###############################
# Backstage Multi-Stage Build #
###############################

# ---- Base builder with dev deps ----
FROM node:20-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++ git
COPY . .
RUN corepack enable && corepack prepare yarn@4.4.1 --activate
# Install all workspace deps (dev + prod) for build
RUN yarn install --immutable
# Build all packages (generates backend dist/index.cjs.js)
RUN yarn build:all || yarn build

# ---- Prune to production (remove dev deps) ----
FROM node:20-alpine AS prod-deps
WORKDIR /app
RUN apk add --no-cache python3 make g++ git
COPY .yarn .yarn
COPY package.json yarn.lock .yarnrc.yml ./
COPY packages/backend/package.json packages/backend/package.json
COPY packages/app/package.json packages/app/package.json
RUN corepack enable && corepack prepare yarn@4.4.1 --activate
# Instala dependencias completas para resolución y luego reduce SOLO backend (no necesitamos dependencias runtime del frontend para servir API)
RUN yarn install --immutable \
	&& yarn workspaces focus backend --production \
	&& rm -rf packages/app/node_modules || true

# ---- Final runtime image ----
FROM node:20-alpine AS runtime
WORKDIR /app
# Solo las utilidades mínimas necesarias en runtime
RUN apk add --no-cache dumb-init curl
ENV NODE_ENV=production
# Copy production node_modules
# Copia node_modules (solo backend) y package.json relevantes
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=prod-deps /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=prod-deps /app/packages/backend/package.json ./packages/backend/package.json
# Copy dist output
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist
COPY app-config.production.yaml ./app-config.production.yaml
COPY catalog-info.yaml ./catalog-info.yaml
COPY backstage.json ./backstage.json

EXPOSE 7007

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run the compiled backend (built by backstage-cli) directly
CMD ["node", "packages/backend/dist/index.cjs.js"]

# Healthcheck simple (ajustar endpoint si se expone /health)
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
	CMD wget -qO- http://127.0.0.1:7007/health || wget -qO- http://127.0.0.1:7007/healthcheck || exit 1
