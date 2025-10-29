# Backstage IDP (Internal Developer Platform)

Esta es una aplicación Backstage personalizada, un portal de desarrollador interno que proporciona una experiencia unificada para gestionar servicios, herramientas y documentación.

## Descripción General

Backstage es una plataforma de código abierto creada por Spotify para construir portales de desarrolladores. Esta implementación incluye:

- **Catálogo de Servicios**: Gestión centralizada de componentes, APIs y recursos
- **Documentación Técnica**: Portal unificado para toda la documentación
- **Herramientas de Desarrollo**: Integración con herramientas de CI/CD, monitoreo y más
- **Plantillas de Proyecto**: Scaffolding automatizado para nuevos proyectos

## Estructura del Proyecto

```
IDP/
├── packages/
│   ├── app/                 # Aplicación frontend React
│   └── backend/             # Backend Node.js/TypeScript
├── plugins/                 # Plugins personalizados
├── examples/                # Ejemplos de entidades y plantillas
├── app-config.yaml          # Configuración de desarrollo
├── app-config.production.yaml  # Configuración de producción
├── backstage.json           # Versión de Backstage
├── package.json             # Dependencias del proyecto
└── yarn.lock               # Lockfile de Yarn
```

## Tecnologías Utilizadas

- **Framework**: Backstage v1.44.0
- **Frontend**: React con TypeScript
- **Backend**: Node.js con Express
- **Base de Datos**: PostgreSQL
- **Gestión de Paquetes**: Yarn
- **Lenguaje**: TypeScript
- **Testing**: Playwright para E2E

## Inicio Rápido

### Prerrequisitos

- Node.js 20 o 22
- Yarn package manager
- PostgreSQL (para persistencia de datos)

### Instalación y Ejecución

```bash
# Instalar dependencias
yarn install

# Iniciar la aplicación en modo desarrollo
yarn start
```

La aplicación estará disponible en `http://localhost:3000`

## Imagen Docker de Producción

Se usa un Dockerfile multi-stage optimizado (`IDP/Dockerfile`) que:

1. Construye todos los paquetes (`builder` stage).
2. Instala solo dependencias de producción (`prod-deps` stage) usando `yarn workspaces focus --production`.
3. Copia los artefactos compilados y `node_modules` necesarios al stage final (`runtime`).
4. Ejecuta el backend usando `node packages/backend/dist/index.cjs.js` con `dumb-init` para manejo correcto de señales.

### Build local (opcional)
```bash
docker build -f IDP/Dockerfile -t backstage:local ./IDP
docker run --rm -p 7007:7007 --env-file .env backstage:local
```

## Pipeline CI/CD (GitHub Actions)

Workflow: `.github/workflows/docker-image.yml`

Pasos clave:
- Extrae el hash corto del commit y lo usa como tag secundario.
- Construye y publica arquitectura multi-plataforma (`linux/amd64`, `linux/arm64`).
- Actualiza el manifiesto `Manifest/backstage/deploy-backstage.yaml` reemplazando la línea de la imagen.
- Evita fallos por commits vacíos (si no hay cambios, no hace push).

### Ejemplo de tags publicados
```
jaimehenao8126/backstage-custom:latest
jaimehenao8126/backstage-custom:<short-sha>
```

### Actualización automática del manifiesto
La línea afectada en `deploy-backstage.yaml`:
```yaml
image: jaimehenao8126/backstage-custom:<short-sha>
```
ArgoCD sincroniza la nueva imagen tras el push.

## Runtime y Entrypoint

En producción se ejecuta el archivo compilado `packages/backend/dist/index.cjs.js`. Esto elimina la necesidad de tener el código fuente TypeScript en la imagen final y reduce el tamaño.

## Troubleshooting

| Problema | Causa común | Solución |
|---------|-------------|----------|
| `MODULE_NOT_FOUND /app/packages/backend/src/index` | Ejecución de script que espera código fuente en imagen final | Usar el nuevo Dockerfile multi-stage y entrypoint compilado |
| Commit vacío falla en workflow | `git commit` sin cambios | Ya mitigado: se verifica si hay cambios antes de commitear |
| Imagen no se actualiza en cluster | ArgoCD no sincronizó aún | Forzar sync desde la UI o `argocd app sync backstage` |

## Próximos Pasos

- Añadir métricas personalizadas vía `kube-prometheus-stack`.
- Integrar alertas en Alertmanager (Slack / Email).
- Documentar uso de plugins adicionales (TechDocs, Scaffolder templates).

## Scripts Disponibles

- `yarn start` - Inicia el servidor de desarrollo
- `yarn build` - Construye la aplicación para producción
- `yarn test` - Ejecuta las pruebas unitarias
- `yarn test:e2e` - Ejecuta las pruebas end-to-end con Playwright
- `yarn lint` - Ejecuta el linter de código
- `yarn fix` - Corrige automáticamente problemas de linting

## Configuración

### Desarrollo
El archivo `app-config.yaml` contiene la configuración para desarrollo local.

### Producción
El archivo `app-config.production.yaml` contiene la configuración optimizada para entornos de producción.

## Plugins Incluidos

- **Catálogo**: Gestión de entidades (servicios, componentes, APIs)
- **Búsqueda**: Motor de búsqueda integrado
- **Plantillas**: Sistema de scaffolding para nuevos proyectos

## Contribución

1. Clona el repositorio
2. Instala dependencias con `yarn install`
3. Crea una rama para tu feature
4. Realiza tus cambios
5. Ejecuta las pruebas con `yarn test`
6. Envía un pull request

## Soporte

Para soporte técnico o preguntas sobre esta implementación de Backstage, consulta la documentación oficial en [backstage.io](https://backstage.io).
