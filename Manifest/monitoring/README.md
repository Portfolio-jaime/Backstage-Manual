# Monitoring (kube-prometheus-stack)

Esta carpeta gestiona el stack de monitoreo mediante una **ArgoCD Application** que consume el chart Helm `kube-prometheus-stack`.

## Componentes

- `monitoring-app.yaml` – ArgoCD Application declarando el chart y `values.yaml`.
- `values.yaml` – Personalizaciones (retención, storageSpec, ingress de Grafana, recursos).

El chart despliega automáticamente:
- Prometheus Operator
- Prometheus Server
- Alertmanager
- Grafana
- Node Exporter
- Kube State Metrics
- ServiceMonitors y PrometheusRules

## Personalización Clave (`values.yaml`)

Ejemplos:
- `prometheus.prometheusSpec.retention` – Días de retención de métricas.
- `grafana.ingress.enabled` y `grafana.ingress.hosts` – Exposición HTTP.
- `prometheus.prometheusSpec.storageSpec` – PVC para datos de Prometheus.

## Flujo GitOps

1. Se edita `values.yaml`.
2. Se hace commit y push.
3. ArgoCD detecta el diff y aplica cambios (SyncPolicy puede ser automática).

## Añadir Dashboards

Para dashboards personalizados:
1. Crear ConfigMap con etiqueta `grafana_dashboard: "1"`.
2. Referenciar JSON del dashboard.
3. ArgoCD lo aplicará y Grafana lo detectará.

## Alertas

- Configurar rutas en Alertmanager vía `alertmanager.config` dentro de `values.yaml`.
- Integrar Slack / Email añadiendo receivers y route default.

## Troubleshooting

| Problema | Causa | Acción |
|----------|-------|--------|
| Prometheus no levanta | PVC sin Bound | Revisar PV/PVC y StorageClass |
| Grafana 404 | Host incorrecto en Ingress | Validar `grafana.ingress.hosts` |
| Métricas vacías | ServiceMonitor no encuentra endpoints | Ver labels y namespace targets |

## Buenas Prácticas

- Limitar retención para controlar uso de disco.
- Configurar recursos (requests/limits) mínimos para estabilidad.
- Versionar los cambios de `values.yaml` con commit descriptivo.

## Próximos Pasos

- Añadir Alertmanager receivers.
- Integrar métricas de Backstage vía ServiceMonitor personalizado.
- Añadir reglas de grabación (recording rules) para SLOs.

## Referencias

- [kube-prometheus-stack Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Prometheus Operator Docs](https://prometheus-operator.dev/)
- [Grafana Docs](https://grafana.com/docs/)
