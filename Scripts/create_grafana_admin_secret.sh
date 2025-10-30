#!/usr/bin/env bash

set -euo pipefail

# Script: create_grafana_admin_secret.sh
# Purpose: Generate (or reuse) a strong Grafana admin password and apply/update the grafana-admin secret
# Namespace: monitoring
# Secret Name: grafana-admin
# Keys: admin-user, admin-password
#
# Usage:
#   ./Scripts/create_grafana_admin_secret.sh               # generates new password
#   GRAFANA_PASSWORD="my-strong-pass" ./Scripts/create_grafana_admin_secret.sh  # use provided password
#
# Notes:
# - Avoid committing generated passwords to git.
# - For rotation, just re-run; Grafana will pick up the new secret after pod restart (you can trigger by deleting the pod).
# - Length defaults to 24 chars using openssl if not provided.

NS="monitoring"
SECRET_NAME="grafana-admin"
USER_KEY="admin-user"
PASS_KEY="admin-password"
ADMIN_USER="admin"
PASSWORD_LENGTH="24"

info() { echo -e "[INFO] $*"; }
warn() { echo -e "[WARN] $*"; }
error() { echo -e "[ERROR] $*" >&2; }

command -v kubectl >/dev/null || { error "kubectl not found in PATH"; exit 1; }

if ! kubectl get ns "$NS" >/dev/null 2>&1; then
  error "Namespace '$NS' not found. Create it before running this script."
  exit 1
fi

if [[ -n "${GRAFANA_PASSWORD:-}" ]]; then
  PASSWORD="$GRAFANA_PASSWORD"
  info "Using password from GRAFANA_PASSWORD env var (length: ${#PASSWORD})"
else
  if command -v openssl >/dev/null 2>&1; then
    PASSWORD="$(openssl rand -base64 36 | tr -d '=+' | head -c "$PASSWORD_LENGTH")"
  else
    warn "openssl not found; falling back to /dev/urandom";
    PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9!@#%^*_-' < /dev/urandom | head -c "$PASSWORD_LENGTH")"
  fi
  info "Generated random password (length: ${#PASSWORD})"
fi

# Create or patch secret
if kubectl get secret "$SECRET_NAME" -n "$NS" >/dev/null 2>&1; then
  info "Secret exists; patching password"
  kubectl patch secret "$SECRET_NAME" -n "$NS" --type=strategic -p "{\"stringData\":{\"$USER_KEY\":\"$ADMIN_USER\",\"$PASS_KEY\":\"$PASSWORD\"}}"
else
  info "Creating new secret '$SECRET_NAME' in namespace '$NS'"
  kubectl create secret generic "$SECRET_NAME" -n "$NS" \
    --from-literal="$USER_KEY=$ADMIN_USER" \
    --from-literal="$PASS_KEY=$PASSWORD"
fi

info "Secret applied. You can verify with: kubectl get secret $SECRET_NAME -n $NS -o yaml"
echo "$PASSWORD" > /dev/null # not printing password by default
info "If you need the password again, re-run with GRAFANA_PASSWORD env var or inspect secret (base64 decode)."

echo ""
info "Trigger Grafana pod restart to load new credentials:" 
echo "kubectl delete pod -n $NS -l app.kubernetes.io/name=grafana"
