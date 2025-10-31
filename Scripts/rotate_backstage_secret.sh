#!/usr/bin/env bash
set -euo pipefail

NS="backstage-manual"
SECRET_NAME="backstage-secret"
GITHUB_CLIENT_ID="${GITHUB_CLIENT_ID:-}"      # exporta antes o pasa por env
GITHUB_CLIENT_SECRET="${GITHUB_CLIENT_SECRET:-}"  # exporta antes o pasa por env
GITHUB_TOKEN="${GITHUB_TOKEN:-}"              # opcional

if [[ -z "$GITHUB_CLIENT_ID" || -z "$GITHUB_CLIENT_SECRET" ]]; then
  echo "[ERROR] Debes exportar GITHUB_CLIENT_ID y GITHUB_CLIENT_SECRET antes de ejecutar este script." >&2
  exit 1
fi

echo "[INFO] Generando nueva llave BACKEND_AUTH_KEYS_0_SECRET" >&2
NEW_KEY=$(openssl rand -base64 48)

echo "[INFO] Creando/actualizando Secret $SECRET_NAME en namespace $NS" >&2
kubectl -n "$NS" create secret generic "$SECRET_NAME" \
  --dry-run=client -o yaml \
  --from-literal=BACKEND_AUTH_KEYS_0_SECRET="$NEW_KEY" \
  --from-literal=GITHUB_CLIENT_ID="$GITHUB_CLIENT_ID" \
  --from-literal=GITHUB_CLIENT_SECRET="$GITHUB_CLIENT_SECRET" \
  $( [[ -n "$GITHUB_TOKEN" ]] && echo --from-literal=GITHUB_TOKEN="$GITHUB_TOKEN" ) \
  | kubectl apply -f -

echo "[INFO] Reiniciando deployment backstage" >&2
kubectl -n "$NS" rollout restart deploy/backstage
kubectl -n "$NS" rollout status deploy/backstage

echo "[OK] Rotación completa. Nueva llave aplicada." >&2
