# 🎯 ArgoCD Namespace & Consolidation

Este directorio contiene los manifiestos mínimos para asegurar que **ArgoCD** se ejecute exclusivamente en el namespace `argocd` y evitar instalaciones duplicadas (por ejemplo en `default`).

## ✅ Objetivo
- Un solo namespace dedicado (`argocd`).
- Limpieza segura de cualquier instalación previa en `default`.
- Punto de anclaje para futuras mejoras (App-of-Apps, RBAC, NetworkPolicies, Projects).

## 📂 Contenido
| Archivo | Propósito |
|---------|-----------|
| `namespace.yaml` | Declara el namespace dedicado con labels estándar. |

## 🧪 Verificación Rápida
## 🔄 Consolidación & Buenas Prácticas

### ¿Por qué evitar múltiples namespaces?
Tener ArgoCD desplegado en más de un namespace (p.e. `default` y `argocd`) provoca:
- Doble reconciliación y riesgo de "drift".
- Consumo innecesario de recursos (dos repos servers, dos application controllers).
- Confusión operativa en dashboards y alertas.

### Criterios de éxito tras la limpieza
- `kubectl get deploy -A | grep argocd` retorna solo el namespace `argocd`.
- No hay secrets ni configmaps con label `app.kubernetes.io/part-of=argocd` en `default`.
- El Ingress apunta únicamente al service `argocd-server` en el namespace correcto.

### Comprobaciones adicionales
```bash
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
kubectl get ingress -A | grep -i argocd
kubectl get applications.argoproj.io -A | awk '{print $1"\t"$2}' | column -t
```

### Estrategia App-of-Apps (futuro)
Crear una Application raíz (ej. `platform-root`) que gestione sub-apps como `backstage`, `monitoring`, `postgres`, `network` usando la carpeta `Manifest/`.

Ejemplo mínimo:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Portfolio-jaime/Backstage-Manual.git
    path: Manifest
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Luego cada subdirectorio puede convertirse en ApplicationSet o Helm Chart controlado.

### Buenas Prácticas de Operación
- Asegurar backups de `argocd-repo-server` si se usan plugins personalizados.
- Versionar toda la configuración (`argocd-cm`, `argocd-rbac-cm`, `argocd-cmd-params-cm`).
- Activar notificaciones selectivas (no por defecto a todos los sync events).
- Limitar acceso mediante RBAC: grupos para `read-only`, `sync`, `admin`.
- Revisar métricas: integrar con Prometheus (`argocd_metrics` endpoint).

```bash
# Ver únicos namespaces donde hay deployments argocd
kubectl get deploy -A | grep -i argocd | awk '{print $1}' | sort -u

# Debe mostrar solo: argocd
```

## 🧹 Limpieza de instalación duplicada (si existe en `default`)
Ejecutar SOLO si confirmas que no usas ya el ArgoCD de `default`.
```bash
# Inventario previo
kubectl get deploy,svc,cm,secret,pods -n default | grep -i argocd || true

# Eliminación controlada (ajusta si faltan algunos)
kubectl delete deploy argocd-server argocd-repo-server argocd-applicationset-controller argocd-notifications-controller argocd-dex-server argocd-redis -n default --ignore-not-found
kubectl delete statefulset argocd-application-controller -n default --ignore-not-found
kubectl delete svc -l app.kubernetes.io/part-of=argocd -n default --ignore-not-found
kubectl delete cm -l app.kubernetes.io/part-of=argocd -n default --ignore-not-found
kubectl delete secret -l app.kubernetes.io/part-of=argocd -n default --ignore-not-found
```

### 📋 Inventario actual (ejemplo)
Salida observada antes de limpieza (tu entorno puede variar):
```
pod/argocd-application-controller-0   Running
service/argocd-applicationset-controller
service/argocd-dex-server
service/argocd-redis
service/argocd-repo-server
service/argocd-server
configmap/argocd-cm
configmap/argocd-rbac-cm
secret/argocd-secret
secret/argocd-initial-admin-secret
```
Si tras ejecutar los pasos anteriores vuelves a listar y no aparece nada, la consolidación fue exitosa.

### ✅ Comprobación final
```bash
kubectl get deploy,sts,svc,cm,secret -n default | grep -i argocd || echo "[OK] No quedan recursos ArgoCD en default"
kubectl get deploy -n argocd | grep -i argocd
```
Debes ver únicamente los deployments en `argocd`.

### ⚠️ Consideraciones antes de borrar
- Exporta configuraciones personalizadas: `kubectl get cm argocd-cm -n default -o yaml > backup-argocd-cm.yaml`.
- Guarda la admin password si aún la necesitas: `kubectl get secret argocd-initial-admin-secret -n default -o jsonpath='{.data.password}' | base64 -d`.
- Verifica que ninguna Application (CRD) apunte a objetos gestionados por el ArgoCD del namespace `default`.

### ♻️ Migración suave de Applications
Si tenías Applications creadas contra el namespace `default`, puedes:
1. Exportarlas: `kubectl get applications.argoproj.io -n default -o yaml > exported-apps.yaml`.
2. Editar el campo `metadata.namespace` a `argocd`.
3. Aplicarlas nuevamente: `kubectl apply -f exported-apps.yaml`.

---
## 🔐 Endurecimiento posterior a la consolidación
- Implementar `NetworkPolicy` restringiendo acceso sólo desde namespaces permitidos.
- Añadir RBAC granular en `argocd-rbac-cm` (roles de solo lectura vs sync/admin).
- Activar SSO (GitHub, OIDC) modificando `argocd-cm` y ocultando secrets en un gestor externo.
- Configurar métricas y alertas (Prometheus rule para fallos de sync repetidos).

---
## 🛠️ Comandos rápidos reutilizables
```bash
# Ver todos los recursos ArgoCD en cualquier namespace
kubectl get all -A | grep -i argocd || true

# Ver configmaps y secrets ArgoCD
kubectl get cm -A | grep -i argocd || true
kubectl get secret -A | grep -i argocd || true

# Eliminar TODOS los recursos ArgoCD en default (forzar limpieza final)
kubectl delete all -n default -l app.kubernetes.io/part-of=argocd --ignore-not-found
```

---
## 🗂️ Próximo: App-of-Apps
Tras la limpieza, crear la Application raíz y mover los manifiestos de cada módulo (backstage, monitoring, postgres) a subpaths declarados en un `ApplicationSet`.


## 🔍 Script de validación
Se genera `Scripts/check_argocd.sh` para comprobar que sólo existe ArgoCD en un namespace.
```bash
./Scripts/check_argocd.sh
```
Exit code `0` => OK. Si retorna `>0` mostrará detalle de duplicados.

## 🚀 Próximas mejoras sugeridas
- Manifiesto de `ArgoCD` App-of-Apps (gestiona todas las Applications desde aquí).
- `NetworkPolicy` para aislar `argocd`.
- Definición de `Projects` para segmentar aplicaciones (ej: platform, data, sandbox).
- SSO/OAuth configuración en `argocd-cm`.

## 🏷️ Labels incluidas
```yaml
labels:
  app.kubernetes.io/name: argocd
  app.kubernetes.io/part-of: gitops
  argocd: system
```
Estas ayudan a seleccionar y limpiar recursos relacionados si fuese necesario.

---
**Fuente de verdad GitOps**: cualquier cambio al namespace debe pasar por pull request.
