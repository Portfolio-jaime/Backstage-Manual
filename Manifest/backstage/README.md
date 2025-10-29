# Backstage Manifiestos

Esta carpeta contiene los recursos Kubernetes y la definicion de la Application ArgoCD para desplegar Backstage.

## Archivos Principales

- `ns.yaml` (si aplica aquí) – Namespace del entorno (en raíz de Manifest).
- `backstage-app.yaml` – Definición de la ArgoCD Application para Backstage.
- `deploy-backstage.yaml` – Deployment de la aplicación Backstage (imagen se actualiza vía workflow CI).
- `service-backstage.yaml` – Service ClusterIP para exponer el puerto 7007 internamente.
- `ingress-backstage.yaml` – Ingress (HTTP) que publica la app externamente.
- `secret-backstage.yaml` – Secrets específicos de la aplicación (tokens / claves de auth).

## Flujo de Actualización de Imagen

1. GitHub Actions construye y publica la imagen (tags: `latest` y `<short-sha>`).
2. El workflow edita `deploy-backstage.yaml` reemplazando la línea de la imagen.
3. ArgoCD detecta el cambio y sincroniza.
4. El nuevo Pod se crea y pasa a Running.

## Variables de Entorno Críticas

- `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` – Conexión a PostgreSQL.
- `BACKEND_AUTH_SECRET`, `BACKEND_AUTH_KEYS_0_SECRET` – Claves para autenticación interna.

## Buenas Prácticas

- No commitear valores reales de secrets; mantenerlos en `secret-*` cifrados o gestionados vía external secret operator.
- Mantener requests/limits en el Deployment para control de recursos.
- Usar etiquetas coherentes (`app: backstage`) para permitir recolección de métricas y políticas de red.

## Troubleshooting

| Problema | Causa | Acción |
|----------|-------|--------|
| Pod CrashLoop | Imagen incorrecta o falta de secret | Ver logs `kubectl logs` y validar secrets |
| Error de conexión a DB | Host/puerto/credencial mal configurado | Revisar environment y secreto `postgres-secrets` |
| ArgoCD OutOfSync | Cambios no aplicados aún | Forzar sync desde UI o `argocd app sync backstage` |

## Extensiones Futuras

- Añadir NetworkPolicy para restringir tráfico.
- Integrar ServiceMonitor para métricas personalizadas.
- Añadir HorizontalPodAutoscaler (HPA).

## Referencias

- [Backstage Docs](https://backstage.io/docs)
- [ArgoCD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
