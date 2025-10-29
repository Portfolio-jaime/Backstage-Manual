# PostgreSQL Manifiestos

Recursos para la base de datos usada por Backstage.

## Archivos

- `deploy-postgres.yaml` – Deployment (o StatefulSet) con contenedor PostgreSQL.
- `service-postgres.yaml` – Service que expone el puerto 5432 dentro del cluster.
- `secret-postgres.yaml` – Credenciales (usuario, password, DB).
- `pv.yaml` / `pvc.yaml` – Persistencia de datos.

## Persistencia

Separación explícita de PV y PVC asegura que el claim se vincule correctamente y evita estado `Pending` prolongado.

## Variables de Entorno

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`

Estas se inyectan en el Deployment y se consumen por Backstage.

## Backup y Restore (Manual)

Ejemplo de backup:
```bash
kubectl exec -n backstage-manual deploy/postgres -- pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql
```
Restore:
```bash
kubectl exec -n backstage-manual deploy/postgres -- psql -U $POSTGRES_USER $POSTGRES_DB < backup.sql
```

## Troubleshooting

| Problema | Causa | Acción |
|----------|-------|--------|
| PVC Pending | StorageClass incorrecto | Revisar `storageclass-manual.yaml` |
| Auth failed | Usuario/password no coinciden | Ver `secret-postgres.yaml` |
| Crash por init | Falta variable de entorno | Validar env en Deployment |

## Buenas Prácticas

- Usar `resources` para limitar consumo.
- Rotar contraseñas periódicamente.
- Plan de backup automatizado (cronjob futuro).

## Próximos Pasos

- Migrar a StatefulSet para manejo más robusto de volumen.
- Añadir monitoreo de métricas de Postgres (pg_exporter).
- Automatizar backups con CronJob + almacenamiento externo.

## Referencias

- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Kubernetes Volumes](https://kubernetes.io/docs/concepts/storage/)
