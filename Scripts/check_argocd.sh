#!/usr/bin/env bash
set -euo pipefail

# Verifica que ArgoCD sólo exista en un namespace (ideal: argocd)
# Opcional: --json para salida estructurada
JSON=false
if [[ "${1:-}" == "--json" ]]; then
  JSON=true
fi

mapfile -t rows < <(kubectl get deploy -A | grep -i argocd || true)

namespaces=()
for r in "${rows[@]}"; do
  ns=$(awk '{print $1}' <<< "$r")
  namespaces+=("$ns")
done

# Eliminar duplicados
mapfile -t unique_namespaces < <(printf '%s\n' "${namespaces[@]}" | sort -u)
count=${#unique_namespaces[@]}

if $JSON; then
  echo '{'
  echo '  "argoNamespaces": ['
  for i in "${!unique_namespaces[@]}"; do
    ns="${unique_namespaces[$i]}"
    comma=','
    if [[ $i -eq $((count-1)) ]]; then comma=''; fi
    echo "    \"$ns\"$comma"
  done
  echo '  ],'
  echo "  \"count\": $count,"
  if [[ $count -gt 1 ]]; then
    echo '  "status": "duplicate"'
  else
    echo '  "status": "single"'
  fi
  echo '}'
else
  echo "Namespaces con deployments ArgoCD: ${unique_namespaces[*]:-<none>}"
fi

if [[ $count -gt 1 ]]; then
  echo "\n⚠️ Se detectó ArgoCD en múltiples namespaces: ${unique_namespaces[*]}"
  echo "Detalle (pods):"
  kubectl get pods -A | grep -i argocd || true
  echo "\nSugerencia de limpieza (ajusta según necesidades):"
  echo "kubectl delete deploy -n default $(kubectl get deploy -n default | awk '/argocd/ {print $1}')"
  echo "kubectl delete statefulset -n default $(kubectl get statefulset -n default | awk '/argocd/ {print $1}') || true"
  exit 2
else
  echo "✅ ArgoCD presente en un único namespace."
fi
