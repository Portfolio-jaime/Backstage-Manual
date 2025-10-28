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
