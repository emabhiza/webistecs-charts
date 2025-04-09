#!/bin/bash

NAMESPACE="default" # or argocd if jobs run there
INTERVAL=10

echo "📡 Monitoring backtester jobs in namespace: $NAMESPACE"
echo "⌛ Refreshing every ${INTERVAL}s..."

while true; do
  echo "--------------------------------------------"
  date
  echo "✅ Completed:"
  kubectl get jobs -n $NAMESPACE --no-headers | grep '1/1' | wc -l

  echo "❌ Failed:"
  kubectl get jobs -n $NAMESPACE --no-headers | grep '0/1' | wc -l

  echo "⏳ Running:"
  kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running | grep backtester | wc -l

  echo "🕐 Pending:"
  kubectl get pods -n $NAMESPACE --field-selector=status.phase=Pending | grep backtester | wc -l

  echo "🧼 Cleaning up completed pods..."
  kubectl delete pod -n $NAMESPACE --field-selector=status.phase==Succeeded --grace-period=0 --force &>/dev/null

  sleep $INTERVAL
done
