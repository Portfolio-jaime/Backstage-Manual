# Backstage Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copia el package.json y package-lock.json
COPY package*.json ./

# Instala dependencias
RUN npm install --production --ignore-scripts --prefer-offline

# Copia el código fuente
COPY . .

# Copia el archivo de configuración de producción desde la carpeta IDP
COPY IDP/app-config.production.yaml /app/app-config.production.yaml

# Expone el puerto de Backstage
EXPOSE 7007

# Comando de arranque
CMD ["node", "packages/backend", "--config", "app-config.production.yaml"]
