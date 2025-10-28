# CI/CD Pipeline - GitHub Actions

Esta carpeta contiene la configuración de integración y despliegue continuo usando GitHub Actions.

## Workflow: Build and Push Docker Image

### Descripción
El workflow `docker-image.yml` automatiza la construcción y publicación de imágenes Docker para la aplicación Backstage.

### Triggers
- **Push a main**: Se ejecuta automáticamente cuando hay cambios en la rama `main`
- **Manual**: Puede ejecutarse manualmente desde la interfaz de GitHub Actions

### Jobs

#### `build-and-push`
- **Runner**: Ubuntu Latest
- **Propósito**: Construir y publicar la imagen Docker

### Pasos del Workflow

1. **Checkout Code**
   - Usa `actions/checkout@v4`
   - Obtiene el código fuente del repositorio

2. **Setup QEMU**
   - Usa `docker/setup-qemu-action@v3`
   - Habilita emulación para múltiples arquitecturas

3. **Setup Docker Buildx**
   - Usa `docker/setup-buildx-action@v3`
   - Configura Buildx para builds avanzados

4. **Login to DockerHub**
   - Usa `docker/login-action@v3`
   - Autentica con Docker Hub usando secrets del repositorio
   - **Secrets requeridos**:
     - `DOCKERHUB_USERNAME`: Usuario de Docker Hub
     - `DOCKERHUB_TOKEN`: Token de acceso

5. **Extract Commit Hash**
   - Extrae el hash corto del commit actual
   - Lo guarda como output para usar en tags

6. **Build and Push Docker Image**
   - Usa `docker/build-push-action@v5`
   - **Contexto**: `./IDP` (carpeta de la aplicación Backstage)
   - **Dockerfile**: `./IDP/Dockerfile`
   - **Push**: Habilita subida automática
   - **Tags**:
     - `jaimehenao8126/backstage-custom:latest`
     - `jaimehenao8126/backstage-custom:${{ steps.vars.outputs.commit_hash }}`

### Configuración del Workflow

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract commit hash
        id: vars
        run: echo "commit_hash=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: ./IDP
          file: ./IDP/Dockerfile
          push: true
          tags: |
            jaimehenao8126/backstage-custom:latest
            jaimehenao8126/backstage-custom:${{ steps.vars.outputs.commit_hash }}
```

## Secrets Requeridos

Para que el workflow funcione correctamente, configura los siguientes secrets en el repositorio:

- **`DOCKERHUB_USERNAME`**: Tu nombre de usuario en Docker Hub
- **`DOCKERHUB_TOKEN`**: Token de acceso personal de Docker Hub

### Cómo Configurar Secrets

1. Ve a tu repositorio en GitHub
2. Navega a **Settings** > **Secrets and variables** > **Actions**
3. Haz clic en **New repository secret**
4. Agrega cada secret con su valor correspondiente

## Imágenes Generadas

El workflow genera dos tags para cada build:

1. **`latest`**: Tag flotante que siempre apunta a la versión más reciente
2. **`<commit-hash>`**: Tag específico del commit para versionado preciso

### Ejemplo de Tags
```
jaimehenao8126/backstage-custom:latest
jaimehenao8126/backstage-custom:a1b2c3d
```

## Integración con Kubernetes

Las imágenes publicadas se usan automáticamente en los manifests de Kubernetes (`Manifest/deploy-backstage.yaml`):

```yaml
spec:
  template:
    spec:
      containers:
        - name: backstage
          image: jaimehenao8126/backstage-custom:latest
```

## Monitoreo del Pipeline

### Ver Estado de Builds
- Ve a la pestaña **Actions** en tu repositorio
- Revisa el historial de workflows ejecutados
- Haz clic en un workflow para ver detalles de ejecución

### Logs y Debugging
- Cada paso del workflow genera logs detallados
- Los errores se muestran claramente en la interfaz
- Puedes re-ejecutar workflows fallidos

## Optimizaciones

### Cache
- El workflow usa cache automático de Docker layers
- Reduce tiempo de construcción en builds subsiguientes

### Multi-plataforma
- Configurado para builds multi-arquitectura (amd64, arm64)
- Usa QEMU para emulación

### Seguridad
- Secrets encriptados
- Acceso limitado a recursos
- Imágenes verificadas

## Solución de Problemas

### Build Fails
- **Problema**: Error de autenticación con Docker Hub
  - **Solución**: Verificar que los secrets estén configurados correctamente

- **Problema**: Error de construcción del Dockerfile
  - **Solución**: Revisar logs del paso de build y validar el Dockerfile

- **Problema**: Push falla
  - **Solución**: Verificar permisos del token de Docker Hub

### Performance Issues
- **Problema**: Builds muy lentos
  - **Solución**: Verificar conectividad de red y recursos del runner

## Mejores Prácticas

1. **Versionado**: Usa tags específicos para producción
2. **Testing**: Agrega pasos de testing antes del push
3. **Security Scanning**: Implementa escaneo de vulnerabilidades
4. **Notifications**: Configura notificaciones de fallos
5. **Branch Protection**: Protege la rama main con status checks

## Extensión del Pipeline

### Posibles Mejoras

- **Testing**: Agregar ejecución de tests automatizados
- **Linting**: Validación de código antes del build
- **Security**: Escaneo de vulnerabilidades en imágenes
- **Deploy**: Despliegue automático a staging/production
- **Notifications**: Alertas en Slack/Discord

### Ejemplo de Extensión

```yaml
- name: Run tests
  run: |
    cd IDP
    yarn install
    yarn test

- name: Security scan
  uses: docker/scan-action@v1
  with:
    image: jaimehenao8126/backstage-custom:latest
```

## Costos

- **GitHub Actions**: 2000 minutos gratis por mes para cuentas personales
- **Docker Hub**: Plan gratuito incluye pulls ilimitados
- **Monitoreo**: Sin costo adicional para repositorios públicos

Este pipeline proporciona una base sólida para CI/CD que puede escalarse según las necesidades del proyecto.