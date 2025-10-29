# Backstage Dockerfile para producción
FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY . .

RUN corepack enable && corepack prepare yarn@4.4.1 --activate

RUN yarn install --immutable && yarn build

COPY app-config.production.yaml /app/app-config.production.yaml

EXPOSE 7007

CMD ["yarn", "workspace", "backend", "start"]
