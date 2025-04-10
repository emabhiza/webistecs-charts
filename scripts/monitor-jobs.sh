#!/bin/bash

# Simple monitoring dashboard
watch -n 5 '
echo "=== RUNNING JOBS ==="
kubectl get jobs -o wide | grep -v "1/1" | awk '\''{print $1,"\t",$2,"\t",$3,"\t",$4}'\''
echo ""
echo "=== COMPLETED JOBS ==="
kubectl get jobs -o wide | grep "1/1" | wc -l | awk '\''{print $1,"jobs completed"}'\''
echo ""
echo "=== FAILED JOBS ==="
kubectl get jobs -o wide | grep "0/1" | awk '\''{print $1}'\''
'