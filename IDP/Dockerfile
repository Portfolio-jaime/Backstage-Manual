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
# Only install production dependencies
RUN yarn workspaces focus --all --production

# ---- Final runtime image ----
FROM node:20-alpine AS runtime
WORKDIR /app
RUN apk add --no-cache dumb-init
ENV NODE_ENV=production
# Copy production node_modules
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=prod-deps /app/packages/backend/node_modules ./packages/backend/node_modules
COPY --from=prod-deps /app/packages/app/node_modules ./packages/app/node_modules
# Copy dist output
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist
COPY --from=builder /app/packages/app/dist ./packages/app/dist
# Copy static assets & configs required at runtime
COPY app-config.production.yaml ./app-config.production.yaml
COPY packages/app/public ./packages/app/public
COPY catalog-info.yaml ./catalog-info.yaml
COPY backstage.json ./backstage.json

EXPOSE 7007

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run the compiled backend (built by backstage-cli) directly
CMD ["node", "packages/backend/dist/index.cjs.js"]
