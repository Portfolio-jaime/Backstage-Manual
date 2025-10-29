# 📚 Glosario de Términos Técnicos - Backstage Solutions

[![Glossary](https://img.shields.io/badge/Glossary-Terms-607D8B?style=for-the-badge&logo=bookstack&logoColor=white)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Backstage](https://img.shields.io/badge/Backstage-0095D5?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJDMTMuMSAyIDE0IDIuOSAxNCA0VjE2QzE0IDE3LjEgMTMuMSAxOCA5LjUgMTguNUM3LjkgMTguNSA3IDE3LjYgNyAxNlY0QzcgMi45IDcuOSAyIDkgMkgxNUMxNS4xIDIgMTYgMi45IDE2IDRWMTJDMTYgMTMuMSAxNS4xIDE0IDEzLjUgMTQuNUMxMS45IDE0LjUgMTEgMTMuNiAxMSAxMloiIGZpbGw9IiMwMDk1RDUiLz4KPC9zdmc+)](https://backstage.io/)

> **Diccionario completo de términos técnicos** usados en la plataforma Backstage Solutions. Desde conceptos básicos hasta terminología avanzada de Kubernetes, DevOps y desarrollo de software.

## 📖 Navegación Rápida

### 🏗️ **Por Categoría**
- [**☸️ Kubernetes**](#kubernetes) - Conceptos de orquestación de contenedores
- [**🎭 Backstage**](#backstage) - Terminología específica de la plataforma
- [**🐳 DevOps & CI/CD**](#devops-cicd) - Desarrollo y despliegue continuo
- [**📊 Monitoreo**](#monitoring) - Observabilidad y métricas
- [**🐘 Bases de Datos**](#databases) - PostgreSQL y persistencia
- [**🔒 Seguridad**](#security) - Autenticación y autorización

### 🔍 **Por Nivel de Complejidad**
- [**🟢 Principiante**](#beginner-level) - Conceptos básicos
- [**🟡 Intermedio**](#intermediate-level) - Conocimientos técnicos
- [**🔴 Avanzado**](#advanced-level) - Terminología especializada

---

## ☸️ Kubernetes - Conceptos de Orquestación

### 🏗️ **Componentes Core**

| Término | Definición | Contexto en Backstage |
|---------|------------|----------------------|
| **Pod** | Unidad más pequeña desplegable en Kubernetes, contiene uno o más contenedores | Backstage se ejecuta en un Pod con el contenedor principal |
| **Deployment** | Recurso que declara el estado deseado de Pods y ReplicaSets | Gestiona la aplicación Backstage y PostgreSQL |
| **Service** | Abstracción que define un conjunto de Pods y una política para acceder a ellos | Expone Backstage en `backstage:7007` internamente |
| **Ingress** | API object que gestiona acceso externo a servicios en un cluster | Publica Backstage en `backstage.local` |
| **ConfigMap** | Objeto para almacenar datos de configuración no confidenciales | Configuraciones de aplicación Backstage |
| **Secret** | Objeto para almacenar datos sensibles como passwords | Credenciales de BD y tokens de autenticación |
| **PersistentVolume (PV)** | Almacenamiento persistente en el cluster | Datos de PostgreSQL |
| **PersistentVolumeClaim (PVC)** | Solicitud de almacenamiento por un Pod | Reclamo de storage para la base de datos |

### 📊 **Gestión de Recursos**

| Término | Definición | Ejemplo en Backstage |
|---------|------------|---------------------|
| **Namespace** | Partición virtual del cluster físico | `backstage-manual` para aislamiento |
| **Resource Limits** | Máximo de CPU/memoria que puede usar un contenedor | `memory: 1Gi, cpu: 500m` |
| **Resource Requests** | CPU/memoria garantizada para un contenedor | `memory: 512Mi, cpu: 250m` |
| **HorizontalPodAutoscaler (HPA)** | Escala automáticamente el número de Pods | Basado en uso de CPU/memoria |
| **StorageClass** | Define tipos de almacenamiento disponibles | `manual` para PV locales |

### 🔄 **GitOps y Despliegue**

| Término | Definición | Uso en Backstage |
|---------|------------|------------------|
| **ArgoCD** | Herramienta GitOps para Kubernetes | Sincroniza manifests desde Git |
| **Application** | Recurso de ArgoCD que define qué desplegar | `backstage-app.yaml` |
| **Sync Policy** | Define cuándo y cómo sincronizar cambios | Automático para producción |
| **GitOps** | Práctica de usar Git como fuente de verdad | Todos los cambios pasan por Git |

---

## 🎭 Backstage - Terminología Específica

### 🏛️ **Arquitectura Core**

| Término | Definición | Función |
|---------|------------|---------|
| **Catalog** | Sistema centralizado de gestión de entidades | Servicios, APIs, componentes, usuarios |
| **TechDocs** | Portal de documentación técnica integrada | Genera docs desde archivos Markdown |
| **Scaffolder** | Sistema de plantillas para nuevos proyectos | Crea proyectos desde templates |
| **Search** | Motor de búsqueda unificado | Busca en catálogo, docs y recursos |
| **Software Templates** | Plantillas reutilizables para proyectos | Estandariza creación de nuevos servicios |

### 🔧 **Plugins y Extensiones**

| Término | Definición | Ejemplo |
|---------|------------|---------|
| **Plugin** | Módulo que extiende funcionalidad de Backstage | `catalog`, `techdocs`, `scaffolder` |
| **Frontend Plugin** | Plugin que añade UI al portal | Componentes React personalizados |
| **Backend Plugin** | Plugin que añade APIs al backend | Endpoints REST adicionales |
| **Plugin API** | Interfaces para comunicación entre plugins | `createPlugin`, `createApiRef` |

### 📋 **Entidades y Metadatos**

| Término | Definición | Propósito |
|---------|------------|-----------|
| **Entity** | Cualquier cosa trackeada en el catálogo | Servicio, API, componente, usuario |
| **Kind** | Tipo de entidad (Component, API, User, etc.) | Clasificación de entidades |
| **Annotation** | Metadatos adicionales en entidades | `backstage.io/techdocs-ref` |
| **Label** | Etiquetas para filtrado y organización | `app: backstage` |
| **Relation** | Conexión entre entidades | Owner, dependency, etc. |

---

## 🐳 DevOps & CI/CD - Desarrollo y Despliegue

### 🚀 **Pipeline Concepts**

| Término | Definición | Implementación en Backstage |
|---------|------------|----------------------------|
| **CI/CD** | Integración y despliegue continuo | GitHub Actions automatiza builds |
| **Artifact** | Resultado de un proceso de build | Imagen Docker `backstage-custom` |
| **Registry** | Repositorio de imágenes de contenedores | Docker Hub para distribución |
| **Build Context** | Directorio usado para construir imagen | `./IDP` para aplicación Backstage |
| **Multi-stage Build** | Dockerfile con múltiples etapas | Optimización de imagen final |

### 🏗️ **Build & Deploy**

| Término | Definición | Ejemplo |
|---------|------------|---------|
| **Dockerfile** | Archivo con instrucciones para construir imagen | `IDP/Dockerfile` |
| **BuildKit** | Builder avanzado de Docker | Construcción paralela y cache |
| **QEMU** | Emulación para múltiples arquitecturas | Builds para amd64 y arm64 |
| **Rolling Update** | Estrategia de actualización sin downtime | Kubernetes actualiza Pods gradualmente |
| **Zero-downtime Deployment** | Despliegue sin interrupción del servicio | HPA mantiene disponibilidad |

### 🔄 **Versionado y Releases**

| Término | Definición | Patrón en Backstage |
|---------|------------|-------------------|
| **Semantic Versioning** | Versionado con MAJOR.MINOR.PATCH | `v1.2.3` para releases |
| **Commit Hash** | Identificador único de commit | `a1b2c3d` en tags |
| **Tag** | Referencia a un punto específico en Git | `latest`, `v1.0.0` |
| **Release** | Versión publicada y etiquetada | GitHub Releases |

---

## 📊 Monitoreo - Observabilidad y Métricas

### 📈 **Métricas y Alertas**

| Término | Definición | Herramienta |
|---------|------------|-------------|
| **Prometheus** | Sistema de monitoreo y alertas | Recolecta métricas de Backstage |
| **Grafana** | Plataforma de visualización de métricas | Dashboards para Kubernetes |
| **Alertmanager** | Maneja alertas de Prometheus | Envía notificaciones |
| **ServiceMonitor** | Define cómo monitorear servicios | `backstage-servicemonitor.yaml` |
| **Metrics Endpoint** | URL que expone métricas | `/metrics` en Backstage |

### 📊 **Tipos de Métricas**

| Término | Definición | Ejemplo |
|---------|------------|---------|
| **Counter** | Valor que solo aumenta | Número de requests HTTP |
| **Gauge** | Valor que puede subir o bajar | Uso de memoria actual |
| **Histogram** | Muestrea observaciones en buckets | Latencia de requests |
| **Summary** | Similar a histogram pero calcula percentiles | Percentiles de respuesta |

### 🚨 **Alertas y Notificaciones**

| Término | Definición | Configuración |
|---------|------------|---------------|
| **Alert Rule** | Condición que dispara alerta | `up{job="backstage"} == 0` |
| **Severity** | Nivel de criticidad de alerta | `critical`, `warning`, `info` |
| **Silence** | Suprime alertas temporalmente | Durante maintenance |
| **Inhibition** | Previene alertas relacionadas | Evita ruido de alertas |

---

## 🐘 Bases de Datos - PostgreSQL y Persistencia

### 💾 **Conceptos de Almacenamiento**

| Término | Definición | Uso en Backstage |
|---------|------------|------------------|
| **PersistentVolume (PV)** | Almacenamiento físico en el cluster | Datos de PostgreSQL |
| **PersistentVolumeClaim (PVC)** | Solicitud de almacenamiento | `postgres-pvc` |
| **StorageClass** | Define características del storage | `manual` para local |
| **Volume Mount** | Punto de montaje en contenedor | `/var/lib/postgresql/data` |
| **Access Mode** | Cómo se puede acceder al volumen | `ReadWriteOnce` |

### 🔄 **Backup y Recovery**

| Término | Definición | Implementación |
|---------|------------|----------------|
| **pg_dump** | Herramienta de backup lógico de PostgreSQL | Exporta datos en SQL |
| **pg_restore** | Herramienta de restauración | Importa datos desde backup |
| **Point-in-time Recovery** | Recuperación a un momento específico | Requiere WAL archiving |
| **WAL (Write-Ahead Log)** | Log de transacciones de PostgreSQL | Para recovery avanzado |

### 📊 **Performance y Tuning**

| Término | Definición | Configuración |
|---------|------------|---------------|
| **Connection Pooling** | Reutilización de conexiones DB | PgBouncer (futuro) |
| **Shared Buffers** | Memoria para cache de PostgreSQL | `256MB` por defecto |
| **Work Mem** | Memoria para operaciones complejas | `64MB` recomendado |
| **Maintenance Work Mem** | Memoria para VACUUM y otros | `256MB` recomendado |

---

## 🔒 Seguridad - Autenticación y Autorización

### 🛡️ **Conceptos de Seguridad**

| Término | Definición | Implementación |
|---------|------------|----------------|
| **RBAC (Role-Based Access Control)** | Control de acceso basado en roles | Permisos en Kubernetes |
| **ServiceAccount** | Cuenta para procesos automatizados | `backstage-sa` |
| **NetworkPolicy** | Reglas de tráfico de red | Isolación entre namespaces |
| **TLS/SSL** | Encriptación de comunicaciones | HTTPS en ingress |
| **Secrets Management** | Gestión segura de credenciales | Kubernetes secrets |

### 🔐 **Autenticación**

| Término | Definición | Método en Backstage |
|---------|------------|-------------------|
| **JWT (JSON Web Token)** | Token para autenticación stateless | Sesiones de usuario |
| **OAuth** | Protocolo de autorización | Integración con proveedores |
| **LDAP** | Protocolo de acceso a directorios | Autenticación enterprise |
| **SAML** | Lenguaje de markup para assertions | SSO corporativo |

### 🛡️ **Mejores Prácticas**

| Término | Definición | Recomendación |
|---------|------------|---------------|
| **Principle of Least Privilege** | Mínimos permisos necesarios | Roles específicos por usuario |
| **Defense in Depth** | Múltiples capas de seguridad | Network policies + RBAC + secrets |
| **Zero Trust** | No confiar en nada por defecto | Verificar todas las requests |
| **Security by Design** | Seguridad integrada desde el diseño | Reviews de seguridad en CI/CD |

---

## 🟢 Nivel Principiante - Conceptos Básicos

| Término | Definición Simple | Analogía |
|---------|------------------|----------|
| **Contenedor** | Paquete que contiene aplicación y dependencias | Caja que tiene todo lo necesario |
| **Orquestación** | Coordinar múltiples contenedores | Director de orquesta con músicos |
| **Microservicio** | Servicio pequeño e independiente | Pieza de lego especializada |
| **API** | Interfaz para comunicación | Menú de restaurante |
| **Base de Datos** | Almacén organizado de datos | Librería con libros catalogados |
| **Backup** | Copia de seguridad | Foto de respaldo |
| **Monitoreo** | Observar el estado del sistema | Dashboard de auto |

---

## 🟡 Nivel Intermedio - Conocimientos Técnicos

| Término | Definición | Importancia |
|---------|------------|-------------|
| **YAML** | Lenguaje de serialización para configuración | Formato estándar en Kubernetes |
| **Helm** | Gestor de paquetes para Kubernetes | Simplifica despliegues complejos |
| **Docker Compose** | Herramienta para definir aplicaciones multi-contenedor | Desarrollo local |
| **Environment Variables** | Variables de configuración externa | Configuración flexible |
| **Health Check** | Verificación automática de estado | Garantiza disponibilidad |
| **Load Balancing** | Distribución de carga entre instancias | Alta disponibilidad |
| **Caching** | Almacenamiento temporal para performance | Reduce latencia |

---

## 🔴 Nivel Avanzado - Terminología Especializada

| Término | Definición | Complejidad |
|---------|------------|-------------|
| **Operator Pattern** | Extensión de Kubernetes para gestión de aplicaciones | Muy avanzado |
| **Custom Resource Definition (CRD)** | Extensión del API de Kubernetes | Avanzado |
| **Admission Controller** | Código que intercepta requests al API server | Muy avanzado |
| **etcd** | Base de datos distribuida de Kubernetes | Avanzado |
| **Container Runtime Interface (CRI)** | Interfaz para runtimes de contenedores | Muy avanzado |
| **Service Mesh** | Infraestructura para comunicación entre servicios | Avanzado |
| **Chaos Engineering** | Pruebas intencionales de fallos | Muy avanzado |

---

## 📚 Referencias y Recursos Adicionales

### 📖 **Documentación Oficial**

- [**Kubernetes Docs**](https://kubernetes.io/docs/) - Documentación completa de K8s
- [**Backstage Docs**](https://backstage.io/docs/) - Guía oficial de Backstage
- [**Prometheus Docs**](https://prometheus.io/docs/) - Documentación de monitoreo
- [**PostgreSQL Docs**](https://www.postgresql.org/docs/) - Manual de base de datos

### 🎓 **Recursos de Aprendizaje**

- [**Kubernetes Learning Path**](https://kubernetes.io/training/) - Ruta de aprendizaje oficial
- [**Backstage Tutorials**](https://backstage.io/docs/getting-started/) - Guías de inicio
- [**CNCF Landscape**](https://landscape.cncf.io/) - Mapa del ecosistema cloud-native

### 🏷️ **Estándares y Convenciones**

- [**Semantic Versioning**](https://semver.org/) - Versionado de software
- [**Twelve-Factor App**](https://12factor.net/) - Metodología para aplicaciones cloud-native
- [**GitOps Principles**](https://www.gitops.tech/) - Prácticas GitOps

---

<div align="center">

**📚 Conocimiento que empodera**

*¡La terminología correcta acelera la comunicación y el aprendizaje!*

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Portfolio-jaime)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

</div>