#!/bin/bash
set -e

echo "Patching ArgoCD RBAC for full admin..."

kubectl -n argocd patch configmap argocd-rbac-cm --type merge -p '{
  "data": {
    "policy.csv": "p, role:admin, *, *, *, allow\ng, user:admin, role:admin",
    "policy.default": "role:admin",
    "policy.matchMode": "glob",
    "scopes": "[username]"
  }
}'

echo "Restarting ArgoCD server..."
kubectl -n argocd rollout restart deploy argocd-server

echo "Fetching ArgoCD initial admin password..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

echo "Done."
echo "ArgoCD UI -> http://<NodeIP>:30007"
