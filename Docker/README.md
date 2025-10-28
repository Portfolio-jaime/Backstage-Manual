# Configuración de Docker para Backstage

Esta carpeta contiene la configuración de Docker necesaria para containerizar la aplicación Backstage.

## Dockerfile

El archivo `Dockerfile` define una imagen multi-stage para la aplicación Backstage:

### Características

- **Base Image**: `node:20-alpine` - Imagen ligera de Node.js
- **Directorio de Trabajo**: `/app`
- **Optimización**: Instalación de dependencias en modo producción
- **Configuración**: Copia del archivo de configuración de producción
- **Puerto**: 7007 (puerto estándar de Backstage)

### Construcción de la Imagen

```bash
# Desde la raíz del proyecto
docker build -f Docker/Dockerfile -t backstage-custom .
```

### Estructura del Dockerfile

```dockerfile
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
```

## Consideraciones de Producción

### Variables de Entorno

La aplicación espera las siguientes variables de entorno (definidas en los manifests de Kubernetes):

- `POSTGRES_HOST`: Host de la base de datos
- `POSTGRES_PORT`: Puerto de la base de datos
- `POSTGRES_DB`: Nombre de la base de datos
- `POSTGRES_USER`: Usuario de la base de datos
- `POSTGRES_PASSWORD`: Contraseña de la base de datos
- `BACKEND_AUTH_SECRET`: Secret para autenticación del backend
- `BACKEND_AUTH_KEYS_0_SECRET`: Clave de autenticación
- `GITHUB_TOKEN`: Token de GitHub para integraciones

### Configuración de Producción

El archivo `app-config.production.yaml` contiene la configuración optimizada para entornos de producción, incluyendo:

- Conexión a base de datos PostgreSQL
- Configuración de autenticación
- Integraciones con GitHub
- Configuración de catálogo y plugins

## Construcción y Despliegue

### Construcción Local

```bash
# Construir la imagen
docker build -f Docker/Dockerfile -t backstage-custom:latest .

# Ejecutar localmente para pruebas
docker run -p 7007:7007 \
  -e POSTGRES_HOST=localhost \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=backstage \
  -e POSTGRES_USER=jaime \
  -e POSTGRES_PASSWORD=jaime \
  backstage-custom:latest
```

### CI/CD Automático

La imagen se construye automáticamente a través del workflow de GitHub Actions definido en `.github/workflows/docker-image.yml`, que:

1. Se activa en pushes a la rama `main`
2. Construye la imagen usando el contexto `./IDP`
3. La etiqueta como `latest` y con el hash del commit
4. La sube a Docker Hub (`jaimehenao8126/backstage-custom`)

## Optimizaciones

### Reducción de Tamaño

- Uso de Alpine Linux como base
- Instalación de dependencias en modo `--production`
- Exclusión de archivos de desarrollo y testing

### Seguridad

- Usuario no-root (por defecto en imágenes Node.js Alpine)
- Imagen base actualizada
- Dependencias actualizadas

### Rendimiento

- Cache de dependencias de npm
- Copia selectiva de archivos
- Configuración optimizada para producción

## Solución de Problemas

### Problemas Comunes

1. **Error de conexión a PostgreSQL**: Verificar variables de entorno
2. **Puerto ya en uso**: Cambiar el puerto de exposición o el mapeo
3. **Permisos insuficientes**: Verificar que el usuario tenga acceso a los archivos

### Debugging

```bash
# Ejecutar con logs detallados
docker run -p 7007:7007 backstage-custom:latest --log-level=debug

# Acceder al contenedor
docker run -it backstage-custom:latest /bin/sh

# Ver logs
docker logs <container-id>
```

## Mejores Prácticas

1. **Versionado**: Usa tags específicas en lugar de `latest` en producción
2. **Escaneo de Seguridad**: Escanea las imágenes regularmente
3. **Multi-stage Builds**: Considera builds multi-stage para mayor optimización
4. **Health Checks**: Implementa health checks en el Dockerfile
5. **Secrets Management**: No incluyas secrets en el Dockerfile

## Integración con Kubernetes

Esta imagen está diseñada para funcionar con los manifests de Kubernetes en la carpeta `Manifest/`, donde se definen:

- Variables de entorno
- Límites de recursos
- Volúmenes persistentes
- ConfigMaps y Secrets

La combinación de este Dockerfile con los manifests de Kubernetes proporciona un despliegue completo y production-ready de Backstage.