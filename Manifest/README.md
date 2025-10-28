# Manifiestos de Kubernetes para Backstage

Esta carpeta contiene todos los archivos de configuración necesarios para desplegar la aplicación Backstage en un clúster de Kubernetes.

## Descripción General

Los manifiestos están organizados para crear un despliegue completo de Backstage con su base de datos PostgreSQL en el namespace `backstage`.

## Archivos de Configuración

### Namespaces
- **`ns.yaml`**: Define el namespace `backstage` donde se desplegarán todos los recursos

### Secrets
- **`secret-postgres.yaml`**: Credenciales para la base de datos PostgreSQL
  - Usuario: `jaime` (codificado en base64)
  - Contraseña: `jaime` (codificado en base64)
  - Base de datos: `backstage` (codificado en base64)
  - Puerto: `5432` (codificado en base64)

- **`secret-backstage.yaml`**: Credenciales para la aplicación Backstage
  - Token de GitHub (codificado en base64)
  - Secret de autenticación del backend
  - Claves de autenticación

### Almacenamiento
- **`pv.yaml`**: Define un PersistentVolume y PersistentVolumeClaim para almacenamiento persistente
  - Capacidad: 2GB
  - AccessMode: ReadWriteOnce
  - StorageClass: manual

### Despliegues
- **`deploy-backstage.yaml`**: Despliegue de la aplicación Backstage
  - Imagen: `jaimehenao8126/backstage-custom:latest`
  - Puerto: 7007
  - Recursos: CPU 100m-500m, Memoria 128Mi-512Mi
  - Variables de entorno para conexión a PostgreSQL

- **`deploy-postgres.yaml`**: Despliegue de PostgreSQL
  - Imagen: `postgres:13.2-alpine`
  - Puerto: 5432
  - Recursos: CPU 100m-500m, Memoria 128Mi-512Mi
  - Volumen persistente para datos

### Servicios
- **`service-backstage.yaml`**: Servicio para exponer Backstage
  - Puerto: 80 (mapeado al puerto 7007 del contenedor)
  - Tipo: ClusterIP (por defecto)

- **`service-postgres.yaml`**: Servicio para PostgreSQL
  - Puerto: 5432
  - Tipo: ClusterIP (por defecto)

## Arquitectura del Despliegue

```
Internet
    ↓
Service (backstage:80)
    ↓
Deployment (backstage)
    - Container: jaimehenao8126/backstage-custom:latest
    - Port: 7007
    - Env: POSTGRES_HOST=postgres, etc.

Service (postgres:5432)
    ↓
Deployment (postgres)
    - Container: postgres:13.2-alpine
    - Port: 5432
    - Volume: postgres-storage
```

## Despliegue

### Prerrequisitos

- Clúster de Kubernetes configurado
- kubectl instalado y configurado
- Acceso a Docker Hub para la imagen `jaimehenao8126/backstage-custom`

### Pasos de Despliegue

1. **Crear el namespace:**
   ```bash
   kubectl apply -f ns.yaml
   ```

2. **Crear los secrets:**
   ```bash
   kubectl apply -f secret-postgres.yaml
   kubectl apply -f secret-backstage.yaml
   ```

3. **Crear el almacenamiento persistente:**
   ```bash
   kubectl apply -f pv.yaml
   ```

4. **Desplegar PostgreSQL:**
   ```bash
   kubectl apply -f deploy-postgres.yaml
   kubectl apply -f service-postgres.yaml
   ```

5. **Desplegar Backstage:**
   ```bash
   kubectl apply -f deploy-backstage.yaml
   kubectl apply -f service-backstage.yaml
   ```

### Verificación del Despliegue

```bash
# Verificar pods
kubectl get pods -n backstage

# Verificar servicios
kubectl get services -n backstage

# Verificar logs de Backstage
kubectl logs -f deployment/backstage -n backstage

# Verificar logs de PostgreSQL
kubectl logs -f deployment/postgres -n backstage
```

### Acceso a la Aplicación

Una vez desplegado, Backstage estará disponible en el puerto 80 del servicio. Si tienes un Ingress configurado, podrás acceder a través de la URL definida.

## Configuración Personalizada

### Modificar Credenciales

Para cambiar las credenciales de PostgreSQL, actualiza los valores en `secret-postgres.yaml`:

```yaml
data:
  POSTGRES_USER: <base64-encoded-username>
  POSTGRES_PASSWORD: <base64-encoded-password>
  POSTGRES_DB: <base64-encoded-database-name>
```

### Cambiar Recursos

Los límites de recursos se pueden ajustar en los archivos de despliegue:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

### Actualizar Imágenes

Para usar una versión diferente de Backstage:

1. Actualiza la imagen en `deploy-backstage.yaml`
2. Asegúrate de que la nueva imagen esté disponible en el registro

## Solución de Problemas

### Problemas Comunes

1. **Pods en estado Pending**: Verificar si hay suficientes recursos en el clúster
2. **ImagePullBackOff**: Verificar credenciales de Docker Hub o disponibilidad de la imagen
3. **CrashLoopBackOff**: Revisar logs del contenedor para errores de configuración

### Comandos Útiles

```bash
# Describir un pod para más detalles
kubectl describe pod <pod-name> -n backstage

# Ejecutar comandos en un contenedor
kubectl exec -it <pod-name> -n backstage -- /bin/bash

# Ver eventos del namespace
kubectl get events -n backstage --sort-by=.metadata.creationTimestamp
```

## Seguridad

- Las credenciales están codificadas en base64 (no encriptadas)
- Considera usar un gestor de secrets como Vault o AWS Secrets Manager en producción
- Los servicios usan ClusterIP por defecto (no expuestos externamente sin Ingress)

## Mantenimiento

- **Backups**: Configura backups regulares de la base de datos PostgreSQL
- **Updates**: Actualiza las imágenes regularmente para seguridad
- **Monitoreo**: Implementa monitoreo de recursos y logs