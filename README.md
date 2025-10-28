# Backstage Solutions - Manual de Despliegue

Una solución completa de Internal Developer Platform (IDP) basada en Backstage, containerizada y lista para desplegar en Kubernetes.

## 📋 Descripción General

Este proyecto proporciona una implementación completa de Backstage, el portal de desarrolladores de código abierto creado por Spotify. Incluye configuración para desarrollo local, containerización con Docker, despliegue en Kubernetes y pipeline de CI/CD automatizado.

## 🏗️ Arquitectura del Proyecto

```
Backstage-solutions/
├── IDP/                    # Aplicación Backstage principal
│   ├── packages/          # Código fuente (frontend/backend)
│   ├── plugins/           # Plugins personalizados
│   ├── examples/          # Ejemplos de entidades
│   └── app-config*.yaml   # Configuraciones
├── Manifest/              # Manifiestos de Kubernetes
│   ├── deploy-*.yaml      # Despliegues
│   ├── service-*.yaml     # Servicios
│   ├── secret-*.yaml      # Credenciales
│   └── ns.yaml           # Namespace
├── Docker/               # Configuración de containerización
│   └── Dockerfile        # Imagen de Backstage
├── Scripts/              # Utilidades de desarrollo
│   └── switch_git_profile.py  # Gestión de perfiles Git
├── .github/              # CI/CD Pipeline
│   └── workflows/        # GitHub Actions
└── README.md            # Esta documentación
```

## 🚀 Inicio Rápido

### Despliegue en Kubernetes (Recomendado)

```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd Backstage-solutions

# 2. Configurar secrets en Kubernetes
kubectl apply -f Manifest/secret-postgres.yaml
kubectl apply -f Manifest/secret-backstage.yaml

# 3. Desplegar la infraestructura
kubectl apply -f Manifest/ns.yaml
kubectl apply -f Manifest/pv.yaml
kubectl apply -f Manifest/deploy-postgres.yaml
kubectl apply -f Manifest/service-postgres.yaml
kubectl apply -f Manifest/deploy-backstage.yaml
kubectl apply -f Manifest/service-backstage.yaml

# 4. Verificar el despliegue
kubectl get pods -n backstage
```

### Desarrollo Local

```bash
# 1. Instalar dependencias
cd IDP
yarn install

# 2. Configurar base de datos PostgreSQL
# (Crear base de datos 'backstage' localmente)

# 3. Iniciar la aplicación
yarn start
```

Accede a `http://localhost:3000`

## 📦 Componentes Principales

### 🏢 IDP - Internal Developer Platform
- **Framework**: Backstage v1.44.0
- **Frontend**: React con TypeScript
- **Backend**: Node.js/Express
- **Base de Datos**: PostgreSQL
- **Plugins**: Catálogo, Búsqueda, Plantillas

### 🐳 Containerización
- **Imagen Base**: `node:20-alpine`
- **Registro**: Docker Hub (`jaimehenao8126/backstage-custom`)
- **Optimización**: Multi-stage build, dependencias de producción

### ☸️ Orquestación
- **Plataforma**: Kubernetes
- **Namespace**: `backstage`
- **Recursos**: CPU 100m-500m, Memoria 128Mi-512Mi
- **Almacenamiento**: PersistentVolume de 2GB

### 🔄 CI/CD Pipeline
- **Plataforma**: GitHub Actions
- **Triggers**: Push a `main`, Manual
- **Acciones**: Build, Test, Push Docker Image
- **Registro**: Docker Hub automático

## ⚙️ Configuración

### Variables de Entorno Requeridas

```yaml
# Base de datos
POSTGRES_HOST: postgres
POSTGRES_PORT: 5432
POSTGRES_DB: backstage
POSTGRES_USER: jaime
POSTGRES_PASSWORD: jaime

# Autenticación
BACKEND_AUTH_SECRET: <secret-key>
BACKEND_AUTH_KEYS_0_SECRET: <secret-key>

# Integraciones
GITHUB_TOKEN: <github-token>
```

### Secrets de Kubernetes

Los secrets están codificados en base64. Para modificarlos:

```bash
# Codificar nueva contraseña
echo -n "nueva_password" | base64

# Actualizar secret
kubectl edit secret postgres-secrets -n backstage
```

## 🛠️ Desarrollo

### Comandos Útiles

```bash
# Instalar dependencias
yarn install

# Desarrollo local
yarn start

# Construir para producción
yarn build

# Ejecutar tests
yarn test

# Linting
yarn lint

# Tests E2E
yarn test:e2e
```

### Gestión de Perfiles Git

```bash
# Perfil personal
python Scripts/switch_git_profile.py personal

# Perfil laboral
python Scripts/switch_git_profile.py laboral
```

## 🚢 Despliegue

### Pre-requisitos

- **Kubernetes**: Clúster configurado (minikube, EKS, GKE, etc.)
- **kubectl**: CLI de Kubernetes instalado
- **Docker Hub**: Cuenta y token de acceso
- **GitHub**: Secrets configurados para CI/CD

### Pasos de Despliegue Detallados

1. **Preparar el Clúster**
   ```bash
   # Crear namespace
   kubectl apply -f Manifest/ns.yaml

   # Configurar almacenamiento persistente
   kubectl apply -f Manifest/pv.yaml
   ```

2. **Configurar Secrets**
   ```bash
   # Credenciales de base de datos
   kubectl apply -f Manifest/secret-postgres.yaml

   # Credenciales de Backstage
   kubectl apply -f Manifest/secret-backstage.yaml
   ```

3. **Desplegar PostgreSQL**
   ```bash
   kubectl apply -f Manifest/deploy-postgres.yaml
   kubectl apply -f Manifest/service-postgres.yaml
   ```

4. **Desplegar Backstage**
   ```bash
   kubectl apply -f Manifest/deploy-backstage.yaml
   kubectl apply -f Manifest/service-backstage.yaml
   ```

5. **Verificar Despliegue**
   ```bash
   # Ver estado de pods
   kubectl get pods -n backstage

   # Ver logs
   kubectl logs -f deployment/backstage -n backstage

   # Ver servicios
   kubectl get services -n backstage
   ```

### Acceso a la Aplicación

- **Interno**: `http://backstage.backstage.svc.cluster.local`
- **Con Ingress**: Configurar Ingress Controller para acceso externo
- **Port Forwarding**: `kubectl port-forward svc/backstage 8080:80 -n backstage`

## 🔍 Monitoreo y Troubleshooting

### Comandos de Diagnóstico

```bash
# Ver estado general
kubectl get all -n backstage

# Ver logs detallados
kubectl logs -f <pod-name> -n backstage

# Describir recursos
kubectl describe deployment backstage -n backstage

# Ver eventos
kubectl get events -n backstage --sort-by=.metadata.creationTimestamp
```

### Problemas Comunes

1. **Pods en CrashLoopBackOff**
   - Verificar variables de entorno
   - Revisar conectividad a PostgreSQL

2. **ImagePullBackOff**
   - Verificar credenciales de Docker Hub
   - Confirmar que la imagen existe

3. **Pending Pods**
   - Verificar recursos disponibles en el clúster
   - Revisar configuración de PersistentVolume

## 🔒 Seguridad

### Mejores Prácticas Implementadas

- Secrets en Kubernetes (no hardcoded)
- Imágenes base actualizadas
- Usuario no-root en contenedores
- Políticas de red (NetworkPolicies recomendadas)

### Consideraciones Adicionales

- Cambiar contraseñas por defecto en producción
- Implementar HTTPS con certificados
- Configurar RBAC en Kubernetes
- Monitoreo de logs y métricas

## 📚 Documentación Adicional

- [📖 IDP/README.md](IDP/README.md) - Documentación de la aplicación Backstage
- [☸️ Manifest/README.md](Manifest/README.md) - Detalles de los manifiestos de Kubernetes
- [🐳 Docker/README.md](Docker/README.md) - Configuración de containerización
- [🔧 Scripts/README.md](Scripts/README.md) - Utilidades de desarrollo
- [🔄 .github/README.md](.github/README.md) - Pipeline de CI/CD

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

Para soporte técnico o preguntas:

- 📧 Email: jaimehenao8126@outlook.com
- 🐛 Issues: [GitHub Issues](https://github.com/Portfolio-jaime/Backstage-Manual/issues)
- 📖 Docs: [Backstage Official](https://backstage.io)

---

**Desarrollado con ❤️ por Jaime Henao**