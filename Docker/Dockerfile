# Backstage Dockerfile
FROM node:20-alpine

WORKDIR /app

# Instalar dependencias del sistema
RUN apk add --no-cache python3 make g++

# Copiar archivos del proyecto
COPY . .

# Habilitar corepack y preparar yarn
RUN corepack enable && corepack prepare yarn@4.4.1 --activate

# Instalar dependencias e iniciar build
RUN yarn install --immutable && yarn build

# Copiar configuración de producción
COPY IDP/app-config.production.yaml /app/app-config.production.yaml

# Exponer puerto
EXPOSE 7007

# Comando de inicio
CMD ["node", "packages/backend", "--config", "app-config.production.yaml"]
