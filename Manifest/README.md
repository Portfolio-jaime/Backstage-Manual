
# 📦 Manifiestos de Kubernetes

Esta carpeta contiene todos los archivos de configuración para desplegar Backstage, PostgreSQL y el stack de monitoreo en Kubernetes.

## 📂 Estructura

```
Manifest/
├── backstage/    # Backstage y ArgoCD
├── postgres/     # PostgreSQL
├── monitoring/   # Prometheus y Grafana
├── ns.yaml       # Namespace
└── storageclass-manual.yaml # StorageClass
```

## 🔗 Diagrama de Dependencias

```mermaid
graph TD;
  subgraph Kubernetes
    A[Backstage] -- DB --> B[Postgres]
    A -- Metrics --> C[Prometheus]
    C -- Dashboards --> D[Grafana]
  end
```

## 📑 Guía Rápida

1. Aplica el namespace y storage class:
   ```bash
   kubectl apply -f ns.yaml
   kubectl apply -f storageclass-manual.yaml
   ```
2. Aplica los recursos de cada stack:
   ```bash
   kubectl apply -f backstage/
   kubectl apply -f postgres/
   kubectl apply -f monitoring/
   ```

## 🗂️ Detalle de Carpetas

- **backstage/**: Despliegue, servicio, ingress, secrets y apps de ArgoCD para Backstage.
- **postgres/**: Despliegue, servicio, secrets, PVC/PV y app de ArgoCD para PostgreSQL.
- **monitoring/**: Despliegue y servicio de Prometheus y Grafana, ingress y configmap.

## 📝 TODO
- [ ] Añadir ejemplos de dashboards en Grafana
- [ ] Documentar integración de Alertmanager
- [ ] Mejorar la seguridad de los secrets
- [ ] Añadir pruebas automáticas para los manifiestos

---
**Desarrollado con ❤️ por Jaime Henao**