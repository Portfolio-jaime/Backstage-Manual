#!/usr/bin/env bash
set -euo pipefail

# create_k8s_backstage_secret.sh
# Utility script to create / rotate the Backstage Kubernetes secret WITHOUT committing plaintext credentials to git.
# Usage:
#   export GITHUB_CLIENT_ID=xxxx
#   export GITHUB_CLIENT_SECRET=yyyy
#   export BACKEND_AUTH_SECRET=<random-32-bytes>
#   export POSTGRES_PASSWORD=<db-pass>
#   ./Scripts/create_k8s_backstage_secret.sh backstage
#
# Args:
#   $1: Kubernetes namespace (default: backstage)
#
# Notes:
# - This script intentionally does NOT echo secrets.
# - For rotation, rerun with new env vars; ArgoCD sync will pick updated Deployment after restarting pods.
# - Consider sealing the secret (SOPS / SealedSecrets / ExternalSecrets) for GitOps instead of applying raw.

NAMESPACE="${1:-backstage}"

required=(GITHUB_CLIENT_ID GITHUB_CLIENT_SECRET BACKEND_AUTH_SECRET POSTGRES_PASSWORD)
missing=()
for var in "${required[@]}"; do
  if [ -z "${!var:-}" ]; then
    missing+=("$var")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "[ERROR] Missing required env vars: ${missing[*]}" >&2
  exit 1
fi

echo "[INFO] Creating/Updating secret 'backstage-secret' in namespace '$NAMESPACE'..."

kubectl create namespace "$NAMESPACE" 2>/dev/null || true

kubectl apply -n "$NAMESPACE" -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: backstage-secret
  labels:
    app: backstage
stringData:
  GITHUB_CLIENT_ID: "$GITHUB_CLIENT_ID"
  GITHUB_CLIENT_SECRET: "$GITHUB_CLIENT_SECRET"
  BACKEND_AUTH_SECRET: "$BACKEND_AUTH_SECRET"
  POSTGRES_PASSWORD: "$POSTGRES_PASSWORD"
EOF

echo "[OK] Secret applied. To verify keys present (will not print values):"
echo "kubectl get secret backstage-secret -n $NAMESPACE -o jsonpath='{.data}' | jq 'keys'"
