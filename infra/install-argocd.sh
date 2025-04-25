#!/bin/bash
set -e

echo "Installing ArgoCD..."

kubectl create namespace argocd || true

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd -n argocd -f argocd-values.yaml

echo "Waiting for ArgoCD pods to be ready..."
kubectl -n argocd rollout status deploy/argocd-server
