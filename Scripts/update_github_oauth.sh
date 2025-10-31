#!/usr/bin/env bash
set -euo pipefail

# update_github_oauth.sh
# Purpose: Safely inject/rotate GitHub OAuth credentials (CLIENT_ID / CLIENT_SECRET) into the
# backstage-secret, optionally rotate backend auth key, and restart the Backstage deployment.
#
# Usage:
#   ./Scripts/update_github_oauth.sh -n backstage-manual -c <github_client_id> -s <github_client_secret> [--rotate-auth]
#
# Requirements:
#   - kubectl configured to target the cluster
#   - jq (optional; used for nicer output if present)
#
# Notes:
#   - Does NOT print secrets back to the console.
#   - If --rotate-auth is used, a new random BACKEND_AUTH_KEYS_0_SECRET is generated.
#   - Ensures secret exists; if missing will create with provided values.
#   - Patches only the provided keys to avoid overwriting other data.

NS="backstage-manual"
CLIENT_ID=""
CLIENT_SECRET=""
ROTATE_AUTH=false

error() { echo "[error] $*" >&2; exit 1; }
info() { echo "[info] $*" >&2; }

rand_auth_key() {
  # 64 bytes base64-url without padding
  openssl rand -base64 48 | tr '+/' '-_' | tr -d '='
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--namespace) NS="$2"; shift 2;;
    -c|--client-id) CLIENT_ID="$2"; shift 2;;
    -s|--client-secret) CLIENT_SECRET="$2"; shift 2;;
    --rotate-auth) ROTATE_AUTH=true; shift;;
    -h|--help)
      sed -n '1,40p' "$0"; exit 0;;
    *) error "Unknown argument: $1";;
  esac
done

[[ -z "$CLIENT_ID" ]] && error "Missing --client-id"
[[ -z "$CLIENT_SECRET" ]] && error "Missing --client-secret"

info "Namespace: $NS"
if ! kubectl get secret backstage-secret -n "$NS" >/dev/null 2>&1; then
  info "Secret backstage-secret not found; creating new one."
  kubectl create secret generic backstage-secret -n "$NS" \
    --from-literal=GITHUB_CLIENT_ID="$CLIENT_ID" \
    --from-literal=GITHUB_CLIENT_SECRET="$CLIENT_SECRET" \
    --from-literal=BACKEND_AUTH_KEYS_0_SECRET="$(rand_auth_key)" \
    --dry-run=client -o yaml | kubectl apply -f -
  CREATED=true
else
  if $ROTATE_AUTH; then
    NEW_AUTH_KEY=$(rand_auth_key)
    PATCH='{"stringData":{"GITHUB_CLIENT_ID":"REDACTED","GITHUB_CLIENT_SECRET":"REDACTED","BACKEND_AUTH_KEYS_0_SECRET":"REDACTED"}}'
  else
    PATCH='{"stringData":{"GITHUB_CLIENT_ID":"REDACTED","GITHUB_CLIENT_SECRET":"REDACTED"}}'
  fi
  # Apply real values (cannot print them). We build the patch twice: once masked for logs, once with actual secrets.
  info "Patching existing secret (masked output). Rotate auth: $ROTATE_AUTH"
  echo "$PATCH" | jq . 2>/dev/null || echo "$PATCH"
  # Real patch
  if $ROTATE_AUTH; then
    kubectl patch secret backstage-secret -n "$NS" --type merge -p "$(printf '{"stringData":{"GITHUB_CLIENT_ID":"%s","GITHUB_CLIENT_SECRET":"%s","BACKEND_AUTH_KEYS_0_SECRET":"%s"}}' "$CLIENT_ID" "$CLIENT_SECRET" "$NEW_AUTH_KEY")"
  else
    kubectl patch secret backstage-secret -n "$NS" --type merge -p "$(printf '{"stringData":{"GITHUB_CLIENT_ID":"%s","GITHUB_CLIENT_SECRET":"%s"}}' "$CLIENT_ID" "$CLIENT_SECRET")"
  fi
  CREATED=false
fi

info "Restarting Backstage deployment to pick up new env vars..."
kubectl -n "$NS" rollout restart deployment backstage
info "Waiting for pod readiness..."
kubectl -n "$NS" rollout status deployment backstage --timeout=120s || error "Deployment did not become ready in time"

POD=$(kubectl -n "$NS" get pods -l app=backstage -o jsonpath='{.items[0].metadata.name}')
info "Checking auth provider initialization logs (partial):"
kubectl -n "$NS" logs "$POD" | grep -i 'Configuring auth provider: github' | tail -n 2 || true
info "Done. Perform login via browser at https://backstage.local"
